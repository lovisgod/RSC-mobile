import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/exceptions.dart';
import '../../domain/usecases/rate_menu_item_usecase.dart';
import 'rating_state.dart';

class RatingCubit extends Cubit<RatingState> {
  RatingCubit(this._rateMenuItemUsecase) : super(const RatingState());

  final RateMenuItemUsecase _rateMenuItemUsecase;

  Future<void> submitRating(
    String menuItemId,
    int rating, {
    String? comment,
  }) async {
    if (state.ratedItemIds.contains(menuItemId)) return;

    emit(state.copyWith(isSubmitting: true, clearError: true));
    try {
      await _rateMenuItemUsecase(menuItemId, rating, comment: comment);
      emit(
        state.copyWith(
          isSubmitting: false,
          isSubmitted: true,
          ratedItemIds: [...state.ratedItemIds, menuItemId],
        ),
      );
    } on AuthException catch (e) {
      emit(state.copyWith(isSubmitting: false, error: e.message));
    } catch (_) {
      emit(
        state.copyWith(
          isSubmitting: false,
          error: 'Failed to submit rating. Please try again.',
        ),
      );
    }
  }
}
