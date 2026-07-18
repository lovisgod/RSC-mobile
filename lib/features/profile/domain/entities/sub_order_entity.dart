class SubOrderEntity {
  final String id;
  final String masterOrderId;
  final String outletId;
  final String status;
  final double subtotal;
  final String pickupCode;
  final String? preparationNote;

  /// Preparation time in minutes, when the outlet has estimated one.
  final int? preparationTime;
  final String? rejectionReason;

  const SubOrderEntity({
    required this.id,
    required this.masterOrderId,
    required this.outletId,
    required this.status,
    required this.subtotal,
    required this.pickupCode,
    this.preparationNote,
    this.preparationTime,
    this.rejectionReason,
  });
}
