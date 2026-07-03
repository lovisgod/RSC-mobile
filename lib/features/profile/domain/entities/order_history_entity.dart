import 'line_item_entity.dart';
import 'sub_order_entity.dart';

class OrderHistoryEntity {
  final String id;
  final String paymentReference;
  final String deliveryCode;
  final String status;
  final String deliveryMode; // 'DELIVERY' | 'TAKEOUT'
  final String deliveryAddress;
  final double subtotal;
  final double deliveryFee;
  final double vat;
  final double total;
  final DateTime createdAt;
  final List<SubOrderEntity> subOrders;
  final List<LineItemEntity> lineItems;
  final bool isCompleted;

  const OrderHistoryEntity({
    required this.id,
    required this.paymentReference,
    required this.deliveryCode,
    required this.status,
    required this.deliveryMode,
    required this.deliveryAddress,
    required this.subtotal,
    required this.deliveryFee,
    required this.vat,
    required this.total,
    required this.createdAt,
    required this.subOrders,
    required this.lineItems,
    required this.isCompleted,
  });

  static const Set<String> activeStatuses = {
    'PENDING',
    'CONFIRMED',
    'PREPARING',
    'READY',
    'DISPATCHED',
  };

  bool get isActive => activeStatuses.contains(status);

  OrderHistoryEntity copyWith({
    String? status,
    List<SubOrderEntity>? subOrders,
    bool? isCompleted,
  }) {
    return OrderHistoryEntity(
      id: id,
      paymentReference: paymentReference,
      deliveryCode: deliveryCode,
      status: status ?? this.status,
      deliveryMode: deliveryMode,
      deliveryAddress: deliveryAddress,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      vat: vat,
      total: total,
      createdAt: createdAt,
      subOrders: subOrders ?? this.subOrders,
      lineItems: lineItems,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  /// "RSC-fe1c320b-08ab-..." → "#RSC-FE1C320B" (first 8 chars after "RSC-").
  String get displayOrderId {
    final withoutPrefix = paymentReference.startsWith('RSC-')
        ? paymentReference.substring(4)
        : paymentReference;
    final shortened = withoutPrefix.length > 8
        ? withoutPrefix.substring(0, 8)
        : withoutPrefix;
    return '#RSC-${shortened.toUpperCase()}';
  }

  String get firstItemSummary {
    if (lineItems.isEmpty) return '';
    final first = lineItems.first;
    return '${first.quantity}x ${first.itemNameSnapshot}';
  }

  int get additionalItemsCount => lineItems.isEmpty ? 0 : lineItems.length - 1;
}
