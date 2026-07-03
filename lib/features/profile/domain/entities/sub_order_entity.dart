class SubOrderEntity {
  final String id;
  final String masterOrderId;
  final String outletId;
  final String status;
  final double subtotal;

  const SubOrderEntity({
    required this.id,
    required this.masterOrderId,
    required this.outletId,
    required this.status,
    required this.subtotal,
  });
}
