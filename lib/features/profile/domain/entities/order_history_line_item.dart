class OrderHistoryLineItem {
  final String itemName;
  final int quantity;
  final double unitPrice;
  final List<String> selectedModifiers;

  const OrderHistoryLineItem({
    required this.itemName,
    required this.quantity,
    required this.unitPrice,
    required this.selectedModifiers,
  });
}
