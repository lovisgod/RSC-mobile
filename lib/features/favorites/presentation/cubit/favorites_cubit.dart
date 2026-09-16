import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/storage/local_storage.dart';
import '../../domain/entities/favorite_menu_item.dart';
import 'favorites_state.dart';

/// App-wide singleton — favorites are local-only for now (no backend
/// endpoint exists yet), persisted as a list of menu-item snapshots so the
/// Favorites tab can render and quick-add without re-fetching an outlet's
/// menu.
class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit(this._localStorage) : super(const FavoritesState());

  final LocalStorage _localStorage;

  Future<void> loadFavorites() async {
    emit(state.copyWith(isLoading: true));
    final items = await _localStorage.getFavoriteMenuItems();
    emit(FavoritesState(items: items, isLoading: false));
  }

  void toggleFavorite(FavoriteMenuItem item) {
    final items = List<FavoriteMenuItem>.from(state.items);
    final idx = items.indexWhere((i) => i.itemId == item.itemId);
    if (idx >= 0) {
      items.removeAt(idx);
    } else {
      items.add(item);
    }
    emit(state.copyWith(items: items));
    unawaited(_localStorage.saveFavoriteMenuItems(items));
  }
}
