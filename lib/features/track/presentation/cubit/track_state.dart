import '../../../menu/domain/entities/outlet.dart';
import '../../../profile/domain/entities/order_history_entity.dart';
import '../../domain/entities/order_event_entity.dart';
import '../../domain/entities/rider_info_entity.dart';
import '../../domain/entities/rider_location_entity.dart';

class TrackState {
  final bool hasActiveOrder;
  final OrderHistoryEntity? activeOrder;
  final bool isLoading;
  final String? error;

  /// Cached outlets (name/emoji lookups for the kitchen-breakdowns section).
  final List<Outlet> outlets;

  /// activeOrder.events, sorted newest first.
  final List<OrderEventEntity> orderEvents;

  /// Drives the motorcycle position (0.0 → 1.0) while OUT_FOR_DELIVERY. The
  /// actual animation is owned by the screen's AnimationController — this
  /// just mirrors its target value for the rest of the UI.
  final double riderProgress;

  /// Real rider assigned to the active order, from activeOrder.rider.
  final RiderInfoEntity? riderInfo;

  /// Rider's last reported GPS ping, from activeOrder.latestRiderLocation.
  /// Refreshed on every socket-triggered order refresh while OUT_FOR_DELIVERY.
  final RiderLocationEntity? riderLocation;

  const TrackState({
    this.hasActiveOrder = false,
    this.activeOrder,
    this.isLoading = false,
    this.error,
    this.outlets = const [],
    this.orderEvents = const [],
    this.riderProgress = 0,
    this.riderInfo,
    this.riderLocation,
  });

  factory TrackState.empty() => const TrackState();

  TrackState copyWith({
    bool? hasActiveOrder,
    OrderHistoryEntity? activeOrder,
    bool clearActiveOrder = false,
    bool? isLoading,
    String? error,
    bool clearError = false,
    List<Outlet>? outlets,
    List<OrderEventEntity>? orderEvents,
    double? riderProgress,
    RiderInfoEntity? riderInfo,
    bool clearRiderInfo = false,
    RiderLocationEntity? riderLocation,
    bool clearRiderLocation = false,
  }) {
    return TrackState(
      hasActiveOrder: hasActiveOrder ?? this.hasActiveOrder,
      activeOrder: clearActiveOrder ? null : (activeOrder ?? this.activeOrder),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      outlets: outlets ?? this.outlets,
      orderEvents: orderEvents ?? this.orderEvents,
      riderProgress: riderProgress ?? this.riderProgress,
      riderInfo: clearRiderInfo ? null : (riderInfo ?? this.riderInfo),
      riderLocation: clearRiderLocation
          ? null
          : (riderLocation ?? this.riderLocation),
    );
  }
}
