import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/socket_service.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../home/domain/repositories/home_repository.dart';
import '../../../profile/domain/entities/order_history_entity.dart';
import '../../../profile/domain/usecases/get_order_by_id_usecase.dart';
import '../../../profile/presentation/cubit/order_history_cubit.dart';
import '../../domain/entities/order_event_entity.dart';
import '../../domain/usecases/get_rider_location_usecase.dart';
import 'track_state.dart';

class TrackCubit extends Cubit<TrackState> {
  TrackCubit(
    this._orderHistoryCubit,
    this._getOrderByIdUseCase,
    this._homeRepository,
    this._socketService,
    this._getRiderLocationUsecase,
    this._localStorage,
  ) : super(TrackState.empty()) {
    _socketService.isConnectedNotifier.addListener(_onSocketConnectionChanged);
  }

  final OrderHistoryCubit _orderHistoryCubit;
  final GetOrderByIdUseCase _getOrderByIdUseCase;
  final HomeRepository _homeRepository;
  final SocketService _socketService;
  final GetRiderLocationUsecase _getRiderLocationUsecase;
  final LocalStorage _localStorage;

  /// Order currently subscribed to on the socket, if any.
  String? _trackedOrderId;
  Timer? _resetTimer;

  /// REST fallback — runs only while the socket is disconnected, never
  /// alongside it.
  Timer? _riderLocationTimer;

  static const _deliveredResetDelay = Duration(seconds: 30);
  static const _cancelledResetDelay = Duration(seconds: 10);
  static const _riderLocationPollInterval = Duration(seconds: 10);

  Future<void> loadActiveOrder() async {
    emit(state.copyWith(isLoading: true, clearError: true));

    var orders = _orderHistoryCubit.state.orders;
    if (orders.isEmpty) {
      await _orderHistoryCubit.loadOrders();
      orders = _orderHistoryCubit.state.orders;
    }

    debugPrint(
      '[RSC Track] Looking for active order in ${orders.length} orders',
    );
    final summary = orders.firstWhereOrNull((o) => o.isActive);
    debugPrint('[RSC Track] Active order found: ${summary?.id ?? 'none'}');

    if (summary == null) {
      stopTrackingOrder();
      emit(
        state.copyWith(
          hasActiveOrder: false,
          isLoading: false,
          clearActiveOrder: true,
        ),
      );
      return;
    }

    await startTrackingOrder(summary.id);
  }

  /// Explicitly loads one chosen order (e.g. the user tapped "Track" on a
  /// specific order in their history) rather than auto-detecting the most
  /// recent active one. Tracking continues for that order via the socket
  /// until it reaches a completed status.
  Future<void> loadSpecificOrder(String orderId) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    await startTrackingOrder(orderId);
  }

  /// Subscribes to the order's socket room (if not already tracking it) and
  /// loads its current state via REST.
  Future<void> startTrackingOrder(String orderId) async {
    if (_trackedOrderId != orderId) {
      stopTrackingOrder();
      _trackedOrderId = orderId;
      _socketService.subscribeToRoom('order:$orderId');
      _socketService.on('order:status_update', _onOrderStatusUpdate);
      if (!_socketService.isConnected) {
        startRiderLocationPolling(orderId);
      }
    }
    await _loadOrderDetail(orderId);
  }

  void stopTrackingOrder() {
    _resetTimer?.cancel();
    stopRiderLocationPolling();
    final orderId = _trackedOrderId;
    if (orderId == null) return;
    _socketService.unsubscribeFromRoom('order:$orderId');
    _socketService.off('order:status_update');
    _trackedOrderId = null;
  }

  // ── Rider-location REST fallback ───────────────────────────────────────────

  /// Socket dropped → poll; socket back → the socket-triggered order refresh
  /// takes over again.
  void _onSocketConnectionChanged() {
    final orderId = _trackedOrderId;
    if (orderId == null) return;
    if (_socketService.isConnectedNotifier.value) {
      stopRiderLocationPolling();
    } else {
      startRiderLocationPolling(orderId);
    }
  }

  void startRiderLocationPolling(String orderId) {
    if (_riderLocationTimer != null) return;
    debugPrint('[RSC Track] Socket down — polling rider location via REST');
    _riderLocationTimer = Timer.periodic(_riderLocationPollInterval, (_) async {
      final location = await _getRiderLocationUsecase(orderId);
      if (isClosed || _trackedOrderId != orderId || location == null) return;
      emit(state.copyWith(riderLocation: location));
    });
  }

  void stopRiderLocationPolling() {
    _riderLocationTimer?.cancel();
    _riderLocationTimer = null;
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

  /// Handles a live `order:status_update` push. Applies the new status
  /// immediately for a snappy UI, then silently refetches the full order via
  /// REST to pick up the fresh events timeline / rider info.
  void _onOrderStatusUpdate(dynamic data) {
    if (isClosed || data is! Map<String, dynamic>) return;

    final masterOrderId = data['masterOrderId'] as String?;
    final newStatus = data['status'] as String?;
    if (masterOrderId == null || masterOrderId != _trackedOrderId) return;
    if (newStatus == null) return;

    debugPrint('[RSC Socket] Order status: $newStatus');

    final current = state.activeOrder;

    // A real transition into DELIVERED (not a re-load of an already-delivered
    // order) schedules the 15-minute rating prompt.
    if (newStatus == 'DELIVERED' &&
        current != null &&
        current.status.toUpperCase() != 'DELIVERED') {
      unawaited(
        _localStorage.savePendingRating(
          masterOrderId,
          DateTime.now(),
          current.totalMinor,
        ),
      );
    }

    if (current != null) {
      emit(state.copyWith(activeOrder: current.copyWith(status: newStatus)));
      _applyStatusTransition(newStatus);
    }

    _refreshOrderData(masterOrderId);
  }

  /// Silent background refresh — no loading state, no UI flicker.
  Future<void> _refreshOrderData(String orderId) async {
    try {
      final detail = await _getOrderByIdUseCase(orderId);
      if (isClosed || _trackedOrderId != orderId) return;
      emit(
        state.copyWith(
          activeOrder: detail,
          orderEvents: _sortedEvents(detail),
          riderInfo: detail.rider,
          clearRiderInfo: detail.rider == null,
          riderLocation: detail.latestRiderLocation,
          clearRiderLocation: detail.latestRiderLocation == null,
        ),
      );
    } catch (_) {
      // Silent failure — never disrupt the active tracking UI over one bad
      // background refresh.
    }
  }

  Future<void> manualRefresh() async {
    _resetTimer?.cancel();
    await loadActiveOrder();
  }

  void cancelTracking() {
    stopTrackingOrder();
    emit(TrackState.empty());
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  List<OrderEventEntity> _sortedEvents(OrderHistoryEntity order) =>
      [...order.events]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  /// DELIVERED/CANCELLED schedule the state reset; any other status is a
  /// no-op — the socket subscription keeps pushing updates.
  void _applyStatusTransition(String status) {
    switch (status) {
      case 'DELIVERED':
        _scheduleReset(_deliveredResetDelay);
      case 'CANCELLED':
        _scheduleReset(_cancelledResetDelay);
    }
  }

  void _scheduleReset(Duration delay) {
    _resetTimer?.cancel();
    _resetTimer = Timer(delay, () {
      if (isClosed) return;
      stopTrackingOrder();
      emit(TrackState.empty());
    });
  }

  @override
  Future<void> close() {
    _socketService.isConnectedNotifier.removeListener(
      _onSocketConnectionChanged,
    );
    stopTrackingOrder();
    return super.close();
  }
}
