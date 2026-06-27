import 'package:equatable/equatable.dart';

abstract class OutletDetailEvent extends Equatable {
  const OutletDetailEvent();

  @override
  List<Object?> get props => [];
}

class OutletDetailFetchRequested extends OutletDetailEvent {
  final String outletId;

  const OutletDetailFetchRequested(this.outletId);

  @override
  List<Object?> get props => [outletId];
}

class OutletDetailCategorySelected extends OutletDetailEvent {
  final String categoryId;

  const OutletDetailCategorySelected(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}
