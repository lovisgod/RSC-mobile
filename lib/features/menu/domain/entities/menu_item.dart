import 'modifier_group.dart';

class MenuItem {
  final String id;
  final String categoryId;
  final String outletId;
  final String name;
  final String description;

  /// Major-unit price (already converted from `priceMinor / 100` in the model).
  final double price;

  /// Null when the backend has no image for this item — the UI falls back to a
  /// deterministic placeholder emoji (see PlaceholderImageUtil / emojiForItemName).
  final String? imageUrl;
  final bool isAvailable;
  final int sortOrder;
  final List<ModifierGroup> modifierGroups;

  final String? allergenNote;

  const MenuItem({
    required this.id,
    required this.categoryId,
    required this.outletId,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.isAvailable,
    this.sortOrder = 0,
    this.modifierGroups = const [],
    this.allergenNote,
  });
}
