class CheckoutOrder {
  final String id;
  final String userId;
  final String deliveryAddress;
  final double deliveryFee;
  final double subtotal;
  final double total;
  final String status;
  final String createdAt; // ISO 8601

  const CheckoutOrder({
    required this.id,
    required this.userId,
    required this.deliveryAddress,
    required this.deliveryFee,
    required this.subtotal,
    required this.total,
    required this.status,
    required this.createdAt,
  });
}
