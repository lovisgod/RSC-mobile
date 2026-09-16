import 'package:equatable/equatable.dart';

import '../../domain/entities/favorite_menu_item.dart';

class FavoritesState extends Equatable {
  final List<FavoriteMenuItem> items;
  final bool isLoading;

  const FavoritesState({this.items = const [], this.isLoading = false});

  bool isFavorite(String itemId) => items.any((i) => i.itemId == itemId);

  FavoritesState copyWith({List<FavoriteMenuItem>? items, bool? isLoading}) {
    return FavoritesState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [items, isLoading];
}
