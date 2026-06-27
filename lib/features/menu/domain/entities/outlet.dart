class Outlet {
  final String id;
  final String name;
  final String description;
  final String cuisineType;
  final String imageUrl;
  final bool isOnline;
  final double rating;
  final int deliveryTimeMins;
  final double minOrder;

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
  });
}
