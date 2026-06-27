class OrderSummary {
  final String id;
  final String status; // master_order status
  final double totalAmount;
  final String createdAt; // ISO 8601
  final List<String> outletNames;
  final int itemCount;

  const OrderSummary({
    required this.id,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
    required this.outletNames,
    required this.itemCount,
  });
}
