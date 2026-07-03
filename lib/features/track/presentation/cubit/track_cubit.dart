import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../cart/domain/entities/cart_item_entity.dart';
import '../../../home/domain/repositories/home_repository.dart';
import '../../../menu/domain/entities/outlet.dart';
import '../../../profile/domain/entities/line_item_entity.dart';
import '../../../profile/domain/entities/order_history_entity.dart';
import '../../../profile/domain/entities/sub_order_entity.dart';
import '../../../profile/domain/usecases/get_order_by_id_usecase.dart';
import '../../../profile/presentation/cubit/order_history_cubit.dart';
import 'track_state.dart';

class TrackCubit extends Cubit<TrackState> {
  TrackCubit(
    this._orderHistoryCubit,
    this._getOrderByIdUseCase,
    this._homeRepository,
  ) : super(TrackState.empty());

  final OrderHistoryCubit _orderHistoryCubit;
  final GetOrderByIdUseCase _getOrderByIdUseCase;
  final HomeRepository _homeRepository;

  Timer? _pollTimer;
  final List<Timer> _simulationTimers = [];

  static const _pollInterval = Duration(seconds: 10);
  static const _resetDelay = Duration(seconds: 30);

  Future<void> loadActiveOrder() async {
    emit(state.copyWith(isLoading: true, clearError: true));

    var orders = _orderHistoryCubit.state.orders;
    if (orders.isEmpty) {
      await _orderHistoryCubit.loadOrders();
      orders = _orderHistoryCubit.state.orders;
    }

    final summary = orders.firstWhereOrNull((o) => o.isActive);

    if (summary == null) {
      // Don't stomp on an already-running simulation — the real order may
      // just not have landed in the backend yet.
      if (state.simulationActive) {
        emit(state.copyWith(isLoading: false));
        return;
      }
      emit(
        state.copyWith(
          hasActiveOrder: false,
          isLoading: false,
          clearActiveOrder: true,
        ),
      );
      return;
    }

    await _loadOrderDetail(summary.id);
  }

  /// Explicitly loads one chosen order (e.g. the user tapped "Track" on a
  /// specific order in their history) rather than auto-detecting the most
  /// recent active one. Polling continues for that order until it reaches a
  /// completed status.
  Future<void> loadSpecificOrder(String orderId) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    _pollTimer?.cancel();
    await _loadOrderDetail(orderId);
  }

  Future<void> _loadOrderDetail(String orderId) async {
    try {
      final detail = await _getOrderByIdUseCase(orderId);
      final outlets = await _homeRepository.getOutlets();
      _cancelSimulation();
      emit(
        state.copyWith(
          hasActiveOrder: true,
          activeOrder: detail,
          isLoading: false,
          outlets: outlets,
          simulationActive: false,
          lastRefreshedAt: DateTime.now(),
        ),
      );
      startPolling();
    } catch (_) {
      if (state.simulationActive) {
        emit(state.copyWith(isLoading: false));
        return;
      }
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Failed to load your active order.',
        ),
      );
    }
  }

  void startPolling() {
    _pollTimer?.cancel();
    emit(state.copyWith(isPolling: true));
    _pollTimer = Timer.periodic(_pollInterval, (_) => refreshActiveOrder());
  }

  Future<void> refreshActiveOrder() async {
    final current = state.activeOrder;
    if (current == null) return;

    try {
      final detail = await _getOrderByIdUseCase(current.id);
      emit(
        state.copyWith(activeOrder: detail, lastRefreshedAt: DateTime.now()),
      );

      if (detail.status == 'DELIVERED' || detail.status == 'CANCELLED') {
        _pollTimer?.cancel();
        emit(state.copyWith(isPolling: false));
        Timer(_resetDelay, () {
          if (isClosed) return;
          emit(TrackState.empty());
        });
      }
    } catch (_) {
      // Silent failure on a failed poll — never disrupt the active
      // tracking UI over one bad request.
    }
  }

  Future<void> manualRefresh() async {
    _pollTimer?.cancel();
    emit(state.copyWith(isPolling: false));
    await loadActiveOrder();
  }

  /// Optimistic fallback: shows a placeholder order immediately after
  /// payment while [loadActiveOrder] confirms the real backend record. Real
  /// data always overrides this once it arrives.
  Future<void> startOrderTracking(
    List<CartItemEntity> cartItems,
    List<Outlet> outlets,
  ) async {
    _cancelSimulation();

    final byOutlet = <String, List<CartItemEntity>>{};
    for (final item in cartItems) {
      (byOutlet[item.outletId] ??= []).add(item);
    }

    final subOrders = byOutlet.entries.map((entry) {
      final subtotal = entry.value.fold<double>(
        0,
        (sum, i) => sum + i.unitPrice * i.quantity,
      );
      return SubOrderEntity(
        id: 'sim-${entry.key}',
        masterOrderId: 'sim',
        outletId: entry.key,
        status: 'PENDING',
        subtotal: subtotal,
      );
    }).toList();

    final lineItems = cartItems.map((item) {
      return LineItemEntity(
        id: 'sim-${item.id}',
        menuItemId: item.menuItemId,
        outletId: item.outletId,
        subOrderId: 'sim-${item.outletId}',
        itemNameSnapshot: item.itemNameSnapshot,
        unitPrice: item.unitPrice,
        quantity: item.quantity,
        lineTotal: item.unitPrice * item.quantity,
        modifiers: const [],
      );
    }).toList();

    final simulatedOrder = OrderHistoryEntity(
      id: 'sim',
      paymentReference: 'RSC-SIMULATED',
      deliveryCode: '------',
      status: 'PENDING',
      deliveryMode: 'DELIVERY',
      deliveryAddress: '',
      subtotal: 0,
      deliveryFee: 0,
      vat: 0,
      total: 0,
      createdAt: DateTime.now(),
      subOrders: subOrders,
      lineItems: lineItems,
      isCompleted: false,
    );

    emit(
      state.copyWith(
        hasActiveOrder: true,
        activeOrder: simulatedOrder,
        outlets: outlets,
        simulationActive: true,
        simulationStep: 0,
        riderProgress: 0,
      ),
    );

    const steps = [
      ('PREPARING', 0.0),
      ('READY', 0.3),
      ('DISPATCHED', 0.6),
      ('DELIVERED', 1.0),
    ];

    for (var i = 0; i < steps.length; i++) {
      final (status, progress) = steps[i];
      _simulationTimers.add(
        Timer(Duration(seconds: 8 * (i + 1)), () {
          if (isClosed || !state.simulationActive) return;
          final order = state.activeOrder;
          if (order == null) return;
          emit(
            state.copyWith(
              simulationStep: i + 1,
              riderProgress: progress,
              activeOrder: order.copyWith(
                status: status,
                subOrders: order.subOrders
                    .map(
                      (s) => SubOrderEntity(
                        id: s.id,
                        masterOrderId: s.masterOrderId,
                        outletId: s.outletId,
                        status: status,
                        subtotal: s.subtotal,
                      ),
                    )
                    .toList(),
                isCompleted: status == 'DELIVERED',
              ),
            ),
          );
        }),
      );
    }

    // Real order data, once it lands in the backend, always overrides this.
    unawaited(loadActiveOrder());
  }

  void cancelTracking() {
    _pollTimer?.cancel();
    _cancelSimulation();
    emit(TrackState.empty());
  }

  void _cancelSimulation() {
    for (final t in _simulationTimers) {
      t.cancel();
    }
    _simulationTimers.clear();
  }

  @override
  Future<void> close() {
    _pollTimer?.cancel();
    _cancelSimulation();
    return super.close();
  }
}
