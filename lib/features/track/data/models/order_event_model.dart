import '../../domain/entities/order_event_entity.dart';

class OrderEventModel {
  final String id;
  final String masterOrderId;
  final String masterStatus;
  final String note;
  final DateTime createdAt;

  const OrderEventModel({
    required this.id,
    required this.masterOrderId,
    required this.masterStatus,
    required this.note,
    required this.createdAt,
  });

  factory OrderEventModel.fromJson(Map<String, dynamic> json) {
    return OrderEventModel(
      id: json['id'] as String? ?? '',
      masterOrderId: json['masterOrderId'] as String? ?? '',
      masterStatus: json['masterStatus'] as String? ?? '',
      note: json['note'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  OrderEventEntity toEntity() => OrderEventEntity(
    id: id,
    masterOrderId: masterOrderId,
    masterStatus: masterStatus,
    note: note,
    createdAt: createdAt,
  );
}
