import '../../../menu/domain/entities/outlet.dart';
import '../../../profile/domain/entities/order_history_entity.dart';

class TrackState {
  final bool hasActiveOrder;
  final OrderHistoryEntity? activeOrder;
  final bool isLoading;
  final String? error;
  final bool isPolling;
  final DateTime? lastRefreshedAt;

  /// Cached outlets (name/emoji lookups for the kitchen-breakdowns section).
  final List<Outlet> outlets;

  // Simulation fallback — drives a rough rider-progress animation when no
  // real order data is available yet (e.g. brief gap right after payment).
  // Real API data always takes priority once loaded.
  final int simulationStep;
  final double riderProgress;
  final bool simulationActive;

  const TrackState({
    this.hasActiveOrder = false,
    this.activeOrder,
    this.isLoading = false,
    this.error,
    this.isPolling = false,
    this.lastRefreshedAt,
    this.outlets = const [],
    this.simulationStep = 0,
    this.riderProgress = 0,
    this.simulationActive = false,
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
    int? simulationStep,
    double? riderProgress,
    bool? simulationActive,
  }) {
    return TrackState(
      hasActiveOrder: hasActiveOrder ?? this.hasActiveOrder,
      activeOrder: clearActiveOrder ? null : (activeOrder ?? this.activeOrder),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isPolling: isPolling ?? this.isPolling,
      lastRefreshedAt: lastRefreshedAt ?? this.lastRefreshedAt,
      outlets: outlets ?? this.outlets,
      simulationStep: simulationStep ?? this.simulationStep,
      riderProgress: riderProgress ?? this.riderProgress,
      simulationActive: simulationActive ?? this.simulationActive,
    );
  }
}
