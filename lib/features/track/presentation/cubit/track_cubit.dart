import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../home/domain/repositories/home_repository.dart';
import '../../../profile/domain/entities/order_history_entity.dart';
import '../../../profile/presentation/cubit/order_history_cubit.dart';
import '../../domain/entities/active_order_entity.dart';
import '../../domain/entities/rider_summary.dart';
import '../../domain/entities/sub_order_summary.dart';
import '../../domain/enums/order_tracking_status.dart';
import 'track_state.dart';

class TrackCubit extends Cubit<TrackState> {
  TrackCubit(this._orderHistoryCubit, this._homeRepository)
    : super(TrackState.empty());

  final OrderHistoryCubit _orderHistoryCubit;
  final HomeRepository _homeRepository;
  final List<Timer> _timers = [];

  static const _activeStatuses = {
    'PENDING',
    'CONFIRMED',
    'PREPARING',
    'READY',
    'DISPATCHED',
  };

  /// Looks for an order still in flight in [OrderHistoryCubit]'s most recent
  /// `loadOrders()` result and starts the simulated status progression for
  /// it. The real order id/handoff code now come from the backend — only the
  /// status-progression timer is still simulated until WebSocket/polling
  /// support is available.
  Future<void> checkForActiveOrder() async {
    final order = _orderHistoryCubit.state.orders.firstWhereOrNull(
      (o) => _activeStatuses.contains(o.status),
    );
    if (order == null) return;
    await _startTracking(order);
  }

  Future<void> _startTracking(OrderHistoryEntity order) async {
    _cancelTimers();

    final outlets = await _homeRepository.getOutlets();
    final itemSummariesByOutlet = <String, List<String>>{};
    for (final item in order.lineItems) {
      (itemSummariesByOutlet[item.outletId] ??= []).add(
        '${item.quantity}x ${item.itemNameSnapshot}',
      );
    }

    final subOrders = order.subOrders.map((sub) {
      final outletName =
          outlets.firstWhereOrNull((o) => o.id == sub.outletId)?.name ??
          AppStrings.kitchenFallbackName;
      return SubOrderSummary(
        outletEmoji: '🍽️',
        outletName: outletName,
        itemSummaries: itemSummariesByOutlet[sub.outletId] ?? const [],
        status: SubOrderStatus.pending,
      );
    }).toList();

    emit(
      TrackState(
        activeOrder: ActiveOrderEntity(
          orderId: order.displayOrderId,
          deliveryCode: order.deliveryCode,
          status: OrderTrackingStatus.pending,
          subOrders: subOrders,
        ),
      ),
    );

    _timers.add(
      Timer(const Duration(seconds: 8), () {
        if (isClosed) return;
        final o = state.activeOrder;
        if (o == null) return;
        emit(
          TrackState(
            activeOrder: o.copyWith(
              status: OrderTrackingStatus.preparing,
              estimatedMinutes: 5,
              subOrders: o.subOrders
                  .map((s) => s.copyWith(status: SubOrderStatus.preparing))
                  .toList(),
            ),
          ),
        );
      }),
    );

    _timers.add(
      Timer(const Duration(seconds: 16), () {
        if (isClosed) return;
        final o = state.activeOrder;
        if (o == null) return;
        emit(
          TrackState(
            activeOrder: o.copyWith(
              status: OrderTrackingStatus.ready,
              rider: const RiderSummary(
                name: 'Emeka Chukwu',
                rating: 4.95,
                partnerType: 'In-House Partner',
                activeStatus: RiderActiveStatus.assigned,
              ),
              subOrders: o.subOrders
                  .map((s) => s.copyWith(status: SubOrderStatus.ready))
                  .toList(),
            ),
          ),
        );
      }),
    );

    _timers.add(
      Timer(const Duration(seconds: 24), () {
        if (isClosed) return;
        final o = state.activeOrder;
        if (o == null) return;
        emit(
          TrackState(
            activeOrder: o.copyWith(
              status: OrderTrackingStatus.collected,
              rider: o.rider?.copyWith(
                activeStatus: RiderActiveStatus.pickedUp,
              ),
              subOrders: o.subOrders
                  .map((s) => s.copyWith(status: SubOrderStatus.collected))
                  .toList(),
            ),
          ),
        );
      }),
    );

    _timers.add(
      Timer(const Duration(seconds: 32), () {
        if (isClosed) return;
        final o = state.activeOrder;
        if (o == null) return;
        emit(
          TrackState(
            activeOrder: o.copyWith(
              status: OrderTrackingStatus.delivered,
              rider: o.rider?.copyWith(
                activeStatus: RiderActiveStatus.delivered,
              ),
            ),
          ),
        );
        _orderHistoryCubit.loadOrders();
      }),
    );

    _timers.add(
      Timer(const Duration(seconds: 62), () {
        if (isClosed) return;
        emit(TrackState.empty());
      }),
    );
  }

  void _cancelTimers() {
    for (final t in _timers) {
      t.cancel();
    }
    _timers.clear();
  }

  @override
  Future<void> close() {
    _cancelTimers();
    return super.close();
  }
}
