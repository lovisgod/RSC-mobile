abstract class RatingRepository {
  Future<void> rateMenuItem(String menuItemId, int rating, {String? comment});
}
