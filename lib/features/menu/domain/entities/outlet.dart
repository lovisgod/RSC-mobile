class Outlet {
  final String id;
  final String name;
  final String description;
  final String cuisineType;
  final String imageUrl;
  final bool isOnline;

  final double ratingAverage;
  final int ratingCount;
  final double? deliveryRadiusKm;
  final double? latitude;
  final double? longitude;

  /// Aggregated across the outlet's menu items (min lower bound, max upper
  /// bound of each item's `deliveryTimeRange`), computed in OutletModel. Null
  /// when none of the outlet's items have a delivery-time estimate.
  final String? deliveryTimeRange;

  // TODO: Backend needs to add deliveryFee/minOrder to the outlets API
  // response — this is populated with a hardcoded placeholder in OutletModel
  // until then.
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
    required this.ratingAverage,
    required this.ratingCount,
    this.deliveryRadiusKm,
    this.latitude,
    this.longitude,
    this.deliveryTimeRange,
    required this.minOrder,
    this.isFeatured = false,
  });
}
