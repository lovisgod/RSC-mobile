import 'package:equatable/equatable.dart';

import '../../../menu/domain/entities/outlet.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final List<Outlet> outlets;

  const HomeLoaded(this.outlets);

  @override
  List<Object?> get props => [outlets];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
