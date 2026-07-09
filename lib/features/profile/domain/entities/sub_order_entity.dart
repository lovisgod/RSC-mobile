class SubOrderEntity {
  final String id;
  final String masterOrderId;
  final String outletId;
  final String status;
  final double subtotal;
  final String pickupCode;

  const SubOrderEntity({
    required this.id,
    required this.masterOrderId,
    required this.outletId,
    required this.status,
    required this.subtotal,
    required this.pickupCode,
  });
}
