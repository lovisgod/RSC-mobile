class OrderEventEntity {
  final String id;
  final String masterOrderId;
  final String masterStatus;
  final String note;
  final DateTime createdAt;

  const OrderEventEntity({
    required this.id,
    required this.masterOrderId,
    required this.masterStatus,
    required this.note,
    required this.createdAt,
  });
}
