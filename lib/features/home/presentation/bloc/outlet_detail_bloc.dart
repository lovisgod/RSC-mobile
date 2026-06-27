import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_outlet_menu_usecase.dart';
import 'outlet_detail_event.dart';
import 'outlet_detail_state.dart';

class OutletDetailBloc extends Bloc<OutletDetailEvent, OutletDetailState> {
  final GetOutletMenuUseCase _getOutletMenu;

  OutletDetailBloc(this._getOutletMenu) : super(const OutletDetailInitial()) {
    on<OutletDetailFetchRequested>(_onFetch);
    on<OutletDetailCategorySelected>(_onCategorySelected);
  }

  Future<void> _onFetch(
    OutletDetailFetchRequested event,
    Emitter<OutletDetailState> emit,
  ) async {
    emit(const OutletDetailLoading());
    try {
      final menu = await _getOutletMenu(event.outletId);
      if (menu.categories.isEmpty) {
        emit(const OutletDetailError('No categories found for this outlet'));
        return;
      }
      emit(OutletDetailLoaded(
        categories: menu.categories,
        itemsByCategory: menu.itemsByCategory,
        selectedCategoryId: menu.categories.first.id,
      ));
    } catch (e) {
      emit(OutletDetailError(e.toString()));
    }
  }

  void _onCategorySelected(
    OutletDetailCategorySelected event,
    Emitter<OutletDetailState> emit,
  ) {
    if (state is OutletDetailLoaded) {
      emit(
        (state as OutletDetailLoaded).copyWithSelectedCategory(event.categoryId),
      );
    }
  }
}
