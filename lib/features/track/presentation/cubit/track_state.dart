import '../../../menu/domain/entities/outlet.dart';
import '../../../profile/domain/entities/order_history_entity.dart';
import '../../domain/entities/order_event_entity.dart';

class TrackState {
  final bool hasActiveOrder;
  final OrderHistoryEntity? activeOrder;
  final bool isLoading;
  final String? error;
  final bool isPolling;
  final DateTime? lastRefreshedAt;

  /// Cached outlets (name/emoji lookups for the kitchen-breakdowns section).
  final List<Outlet> outlets;

  /// activeOrder.events, sorted newest first.
  final List<OrderEventEntity> orderEvents;

  /// Drives the motorcycle position (0.0 → 1.0) while OUT_FOR_DELIVERY. The
  /// actual animation is owned by the screen's AnimationController — this
  /// just mirrors its target value for the rest of the UI.
  final double riderProgress;

  const TrackState({
    this.hasActiveOrder = false,
    this.activeOrder,
    this.isLoading = false,
    this.error,
    this.isPolling = false,
    this.lastRefreshedAt,
    this.outlets = const [],
    this.orderEvents = const [],
    this.riderProgress = 0,
  });

  factory TrackState.empty() => const TrackState();

  TrackState copyWith({
    bool? hasActiveOrder,
    OrderHistoryEntity? activeOrder,
    bool clearActiveOrder = false,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool? isPolling,
    DateTime? lastRefreshedAt,
    List<Outlet>? outlets,
    List<OrderEventEntity>? orderEvents,
    double? riderProgress,
  }) {
    return TrackState(
      hasActiveOrder: hasActiveOrder ?? this.hasActiveOrder,
      activeOrder: clearActiveOrder ? null : (activeOrder ?? this.activeOrder),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isPolling: isPolling ?? this.isPolling,
      lastRefreshedAt: lastRefreshedAt ?? this.lastRefreshedAt,
      outlets: outlets ?? this.outlets,
      orderEvents: orderEvents ?? this.orderEvents,
      riderProgress: riderProgress ?? this.riderProgress,
    );
  }
}
