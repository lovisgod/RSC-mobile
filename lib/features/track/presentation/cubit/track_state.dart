import '../../domain/entities/active_order_entity.dart';

class TrackState {
  final ActiveOrderEntity? activeOrder;

  const TrackState({this.activeOrder});

  factory TrackState.empty() => const TrackState();

  bool get hasActiveOrder => activeOrder != null;

  TrackState copyWith({ActiveOrderEntity? activeOrder}) =>
      TrackState(activeOrder: activeOrder ?? this.activeOrder);
}
