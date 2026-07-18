import '../repositories/rating_repository.dart';

class RateMenuItemUsecase {
  const RateMenuItemUsecase(this._repository);

  final RatingRepository _repository;

  Future<void> call(String menuItemId, int rating, {String? comment}) =>
      _repository.rateMenuItem(menuItemId, rating, comment: comment);
}
