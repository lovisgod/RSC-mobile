class DeliveryLocationFee {
  final String zoneId;
  final int feeMinor;
  final String locationName;

  const DeliveryLocationFee({
    required this.zoneId,
    required this.feeMinor,
    required this.locationName,
  });

  double get fee => feeMinor / 100;
}

class Outlet {
  final String id;
  final String name;
  final String description;
  final String? address;
  final String cuisineType;
  final String imageUrl;
  final String? logoUrl;
  final String? bannerUrl;
  final bool isOnline;
  final String? settlementSubaccountCode;
  final int vatBps;

  final double ratingAverage;
  final int ratingCount;
  final double? deliveryRadiusKm;
  final double? latitude;
  final double? longitude;
  final String? deliveryPricingModel;
  final int deliveryFeeMinor;
  final int? deliveryBaseFeeMinor;
  final int? deliveryPricePerKmMinor;
  final List<DeliveryLocationFee> deliveryLocationFees;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  /// Aggregated across the outlet's menu items (min lower bound, max upper
  /// bound of each item's `deliveryTimeRange`), computed in OutletModel. Null
  /// when none of the outlet's items have a delivery-time estimate.
  final String? deliveryTimeRange;

  /// Kept for existing UI compatibility. The outlets payload does not expose a
  /// minimum order, so this currently mirrors the outlet delivery fee in major
  /// units.
  final double minOrder;

  double get deliveryFee => deliveryFeeMinor / 100;

  /// Simulates a "Popular" badge — true for the first outlet in the list only
  /// (placeholder until the backend exposes a featured flag).
  final bool isFeatured;

  const Outlet({
    required this.id,
    required this.name,
    required this.description,
    this.address,
    required this.cuisineType,
    required this.imageUrl,
    this.logoUrl,
    this.bannerUrl,
    required this.isOnline,
    this.settlementSubaccountCode,
    this.vatBps = 0,
    required this.ratingAverage,
    required this.ratingCount,
    this.deliveryRadiusKm,
    this.latitude,
    this.longitude,
    this.deliveryPricingModel,
    this.deliveryFeeMinor = 0,
    this.deliveryBaseFeeMinor,
    this.deliveryPricePerKmMinor,
    this.deliveryLocationFees = const [],
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.deliveryTimeRange,
    required this.minOrder,
    this.isFeatured = false,
  });

  Outlet copyWith({bool? isOnline}) => Outlet(
    id: id,
    name: name,
    description: description,
    address: address,
    cuisineType: cuisineType,
    imageUrl: imageUrl,
    logoUrl: logoUrl,
    bannerUrl: bannerUrl,
    isOnline: isOnline ?? this.isOnline,
    settlementSubaccountCode: settlementSubaccountCode,
    vatBps: vatBps,
    ratingAverage: ratingAverage,
    ratingCount: ratingCount,
    deliveryRadiusKm: deliveryRadiusKm,
    latitude: latitude,
    longitude: longitude,
    deliveryPricingModel: deliveryPricingModel,
    deliveryFeeMinor: deliveryFeeMinor,
    deliveryBaseFeeMinor: deliveryBaseFeeMinor,
    deliveryPricePerKmMinor: deliveryPricePerKmMinor,
    deliveryLocationFees: deliveryLocationFees,
    createdAt: createdAt,
    updatedAt: updatedAt,
    deletedAt: deletedAt,
    deliveryTimeRange: deliveryTimeRange,
    minOrder: minOrder,
    isFeatured: isFeatured,
  );
}
