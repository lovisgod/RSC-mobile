class OrderLineItem {
  final String id;
  final String subOrderId;
  final String menuItemId;
  final String itemNameSnapshot;
  final double unitPrice;
  final int quantity;
  // groupName -> modifierName snapshot at time of order
  final Map<String, String> selectedModifiers;
  final double lineTotal;

  const OrderLineItem({
    required this.id,
    required this.subOrderId,
    required this.menuItemId,
    required this.itemNameSnapshot,
    required this.unitPrice,
    required this.quantity,
    required this.selectedModifiers,
    required this.lineTotal,
  });
}
