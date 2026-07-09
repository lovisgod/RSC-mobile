import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../home/domain/repositories/home_repository.dart';
import '../../../profile/domain/entities/order_history_entity.dart';
import '../../../profile/domain/usecases/get_order_by_id_usecase.dart';
import '../../../profile/presentation/cubit/order_history_cubit.dart';
import '../../domain/entities/order_event_entity.dart';
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

  static const _pollInterval = Duration(seconds: 10);
  static const _deliveredResetDelay = Duration(seconds: 30);
  static const _cancelledResetDelay = Duration(seconds: 10);

  Future<void> loadActiveOrder() async {
    emit(state.copyWith(isLoading: true, clearError: true));

    var orders = _orderHistoryCubit.state.orders;
    if (orders.isEmpty) {
      await _orderHistoryCubit.loadOrders();
      orders = _orderHistoryCubit.state.orders;
    }

    final summary = orders.firstWhereOrNull((o) => o.isActive);

    if (summary == null) {
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
      emit(
        state.copyWith(
          hasActiveOrder: true,
          activeOrder: detail,
          orderEvents: _sortedEvents(detail),
          isLoading: false,
          outlets: outlets,
          lastRefreshedAt: DateTime.now(),
          riderInfo: detail.rider,
          clearRiderInfo: detail.rider == null,
          riderLocation: detail.latestRiderLocation,
          clearRiderLocation: detail.latestRiderLocation == null,
        ),
      );
      _applyStatusTransition(detail.status);
    } catch (_) {
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

  /// Runs on every 10s poll tick. All status-driven UI (ETA card, rider
  /// section, motorcycle animation) reacts to the fresh [activeOrder] this
  /// emits — there is no simulated status progression anymore.
  Future<void> refreshActiveOrder() async {
    final current = state.activeOrder;
    if (current == null) return;

    try {
      final detail = await _getOrderByIdUseCase(current.id);
      emit(
        state.copyWith(
          activeOrder: detail,
          orderEvents: _sortedEvents(detail),
          lastRefreshedAt: DateTime.now(),
          riderInfo: detail.rider,
          clearRiderInfo: detail.rider == null,
          riderLocation: detail.latestRiderLocation,
          clearRiderLocation: detail.latestRiderLocation == null,
        ),
      );

      if (detail.status == 'DELIVERED' || detail.status == 'CANCELLED') {
        _applyStatusTransition(detail.status);
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

  void cancelTracking() {
    _pollTimer?.cancel();
    emit(TrackState.empty());
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  List<OrderEventEntity> _sortedEvents(OrderHistoryEntity order) =>
      [...order.events]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  /// DELIVERED/CANCELLED stop polling and schedule the state reset; any
  /// other status just (re)starts the 10s poll.
  void _applyStatusTransition(String status) {
    switch (status) {
      case 'DELIVERED':
        _scheduleReset(_deliveredResetDelay);
      case 'CANCELLED':
        _scheduleReset(_cancelledResetDelay);
      default:
        startPolling();
    }
  }

  void _scheduleReset(Duration delay) {
    _pollTimer?.cancel();
    emit(state.copyWith(isPolling: false));
    Timer(delay, () {
      if (isClosed) return;
      emit(TrackState.empty());
    });
  }

  @override
  Future<void> close() {
    _pollTimer?.cancel();
    return super.close();
  }
}
