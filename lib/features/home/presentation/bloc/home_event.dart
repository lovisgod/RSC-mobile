import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class HomeFetchRequested extends HomeEvent {
  const HomeFetchRequested();
}

/// Dispatched when the socket delivers an `outlet:status_update` event.
class OutletStatusChanged extends HomeEvent {
  final String outletId;
  final bool isOnline;

  const OutletStatusChanged({required this.outletId, required this.isOnline});

  @override
  List<Object?> get props => [outletId, isOnline];
}
