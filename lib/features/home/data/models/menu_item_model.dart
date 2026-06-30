import '../../../menu/domain/entities/menu_item.dart';
import '../../../menu/domain/entities/modifier_group.dart';

/// Maps a single object from the outlet response's `menuItems` array.
///
/// `priceMinor` is converted to a major-unit [price] here in the model layer —
/// the UI never divides by 100 itself.
class MenuItemModel {
  final String id;
  final String outletId;
  final String categoryId;
  final String name;
  final String description;
  final String? imageUrl;
  final double price;
  final bool isAvailable;
  final int sortOrder;

  const MenuItemModel({
    required this.id,
    required this.outletId,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.isAvailable,
    required this.sortOrder,
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModel(
      id: json['id'] as String? ?? '',
      outletId: json['outletId'] as String? ?? '',
      categoryId: json['categoryId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      price: ((json['priceMinor'] as num?)?.toDouble() ?? 0) / 100,
      isAvailable: json['isAvailable'] as bool? ?? true,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }

  MenuItem toEntity({List<ModifierGroup> modifierGroups = const []}) => MenuItem(
        id: id,
        categoryId: categoryId,
        outletId: outletId,
        name: name,
        description: description,
        price: price,
        imageUrl: imageUrl,
        isAvailable: isAvailable,
        sortOrder: sortOrder,
        modifierGroups: modifierGroups,
      );
}
