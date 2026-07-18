import '../../domain/entities/sub_order_entity.dart';

class SubOrderModel {
  final String id;
  final String masterOrderId;
  final String outletId;
  final String status;
  final double subtotal;
  final String currency;
  final String pickupCode;
  final String? preparationNote;

  /// Minutes, from the backend — int or null, never a string.
  final int? preparationTime;
  final String? rejectionReason;

  const SubOrderModel({
    required this.id,
    required this.masterOrderId,
    required this.outletId,
    required this.status,
    required this.subtotal,
    required this.currency,
    required this.pickupCode,
    this.preparationNote,
    this.preparationTime,
    this.rejectionReason,
  });

  factory SubOrderModel.fromJson(Map<String, dynamic> json) {
    return SubOrderModel(
      id: json['id'] as String? ?? '',
      masterOrderId: json['masterOrderId'] as String? ?? '',
      outletId: json['outletId'] as String? ?? '',
      status: json['status'] as String? ?? '',
      subtotal: ((json['subtotalMinor'] as num?) ?? 0) / 100,
      currency: json['currency'] as String? ?? 'NGN',
      pickupCode: json['pickupCode'] as String? ?? '',
      preparationNote: json['preparationNote'] as String?,
      preparationTime: (json['preparationTime'] as num?)?.toInt(),
      rejectionReason: json['rejectionReason'] as String?,
    );
  }

  SubOrderEntity toEntity() => SubOrderEntity(
    id: id,
    masterOrderId: masterOrderId,
    outletId: outletId,
    status: status,
    subtotal: subtotal,
    pickupCode: pickupCode,
    preparationNote: preparationNote,
    preparationTime: preparationTime,
    rejectionReason: rejectionReason,
  );
}
