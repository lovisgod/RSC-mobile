class Outlet {
  final String id;
  final String name;
  final String description;
  final String cuisineType;
  final String imageUrl;
  final bool isOnline;

  // TODO: Backend needs to add rating, deliveryTimeMins (range), and
  // deliveryFee/minOrder to the outlets API response — these are populated
  // with hardcoded placeholders in OutletModel until then.
  final double rating;
  final int deliveryTimeMins;
  final double minOrder;

  /// Simulates a "Popular" badge — true for the first outlet in the list only
  /// (placeholder until the backend exposes a featured flag).
  final bool isFeatured;

  const Outlet({
    required this.id,
    required this.name,
    required this.description,
    required this.cuisineType,
    required this.imageUrl,
    required this.isOnline,
    required this.rating,
    required this.deliveryTimeMins,
    required this.minOrder,
    this.isFeatured = false,
  });
}
