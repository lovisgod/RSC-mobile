import 'selected_modifier_entity.dart';

class CartItemEntity {
  final String id;
  final String menuItemId;
  final String outletId;
  final String outletName;
  final String outletEmoji;
  final String itemNameSnapshot;
  final String itemImageUrl;
  final double unitPrice;
  final double basePrice;
  final int quantity;
  final List<SelectedModifierEntity> selectedModifiers;

  const CartItemEntity({
    required this.id,
    required this.menuItemId,
    required this.outletId,
    required this.outletName,
    required this.outletEmoji,
    required this.itemNameSnapshot,
    required this.itemImageUrl,
    required this.unitPrice,
    required this.basePrice,
    required this.quantity,
    required this.selectedModifiers,
  });

  CartItemEntity copyWith({
    int? quantity,
    double? unitPrice,
    List<SelectedModifierEntity>? selectedModifiers,
  }) =>
      CartItemEntity(
        id: id,
        menuItemId: menuItemId,
        outletId: outletId,
        outletName: outletName,
        outletEmoji: outletEmoji,
        itemNameSnapshot: itemNameSnapshot,
        itemImageUrl: itemImageUrl,
        unitPrice: unitPrice ?? this.unitPrice,
        basePrice: basePrice,
        quantity: quantity ?? this.quantity,
        selectedModifiers: selectedModifiers ?? this.selectedModifiers,
      );
}
