class FavoriteMenuItem {
  final String itemId;
  final String outletId;
  final String outletName;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;

  const FavoriteMenuItem({
    required this.itemId,
    required this.outletId,
    required this.outletName,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() => {
    'itemId': itemId,
    'outletId': outletId,
    'outletName': outletName,
    'name': name,
    'description': description,
    'price': price,
    'imageUrl': imageUrl,
  };

  factory FavoriteMenuItem.fromJson(Map<String, dynamic> json) =>
      FavoriteMenuItem(
        itemId: json['itemId'] as String,
        outletId: json['outletId'] as String,
        outletName: json['outletName'] as String,
        name: json['name'] as String,
        description: json['description'] as String? ?? '',
        price: (json['price'] as num).toDouble(),
        imageUrl: json['imageUrl'] as String?,
      );
}
