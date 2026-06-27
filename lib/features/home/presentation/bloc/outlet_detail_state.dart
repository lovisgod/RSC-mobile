import 'package:equatable/equatable.dart';

import '../../../menu/domain/entities/category.dart';
import '../../../menu/domain/entities/menu_item.dart';

abstract class OutletDetailState extends Equatable {
  const OutletDetailState();

  @override
  List<Object?> get props => [];
}

class OutletDetailInitial extends OutletDetailState {
  const OutletDetailInitial();
}

class OutletDetailLoading extends OutletDetailState {
  const OutletDetailLoading();
}

class OutletDetailLoaded extends OutletDetailState {
  final List<MenuCategory> categories;
  final Map<String, List<MenuItem>> itemsByCategory;
  final String selectedCategoryId;

  const OutletDetailLoaded({
    required this.categories,
    required this.itemsByCategory,
    required this.selectedCategoryId,
  });

  List<MenuItem> get selectedItems => itemsByCategory[selectedCategoryId] ?? [];

  OutletDetailLoaded copyWithSelectedCategory(String categoryId) =>
      OutletDetailLoaded(
        categories: categories,
        itemsByCategory: itemsByCategory,
        selectedCategoryId: categoryId,
      );

  @override
  List<Object?> get props => [categories, selectedCategoryId];
}

class OutletDetailError extends OutletDetailState {
  final String message;

  const OutletDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
