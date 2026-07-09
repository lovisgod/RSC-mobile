import '../../domain/entities/sub_order_entity.dart';

class SubOrderModel {
  final String id;
  final String masterOrderId;
  final String outletId;
  final String status;
  final double subtotal;
  final String currency;
  final String pickupCode;

  const SubOrderModel({
    required this.id,
    required this.masterOrderId,
    required this.outletId,
    required this.status,
    required this.subtotal,
    required this.currency,
    required this.pickupCode,
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
    );
  }

  SubOrderEntity toEntity() => SubOrderEntity(
    id: id,
    masterOrderId: masterOrderId,
    outletId: outletId,
    status: status,
    subtotal: subtotal,
    pickupCode: pickupCode,
  );
}
