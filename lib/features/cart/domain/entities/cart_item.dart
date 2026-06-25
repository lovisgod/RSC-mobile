class CartItem {
  final String id;
  final String menuItemId;
  final String menuItemName;
  final String outletId;
  final String outletName;
  final double basePrice;
  final int quantity;
  // groupId -> modifier name snapshot at time of add
  final Map<String, String> selectedModifiers;
  final double totalPrice;

  const CartItem({
    required this.id,
    required this.menuItemId,
    required this.menuItemName,
    required this.outletId,
    required this.outletName,
    required this.basePrice,
    required this.quantity,
    required this.selectedModifiers,
    required this.totalPrice,
  });
}
