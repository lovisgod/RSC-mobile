import 'modifier_group.dart';

class MenuItem {
  final String id;
  final String categoryId;
  final String outletId;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final bool isAvailable;
  final List<ModifierGroup> modifierGroups;

  const MenuItem({
    required this.id,
    required this.categoryId,
    required this.outletId,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.isAvailable,
    this.modifierGroups = const [],
  });
}
