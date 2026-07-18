import '../../../track/domain/entities/order_event_entity.dart';
import '../../../track/domain/entities/rider_info_entity.dart';
import '../../../track/domain/entities/rider_location_entity.dart';
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

  /// Raw order total in minor units (kobo), exactly as the API sent it —
  /// refund requests must pass this through untouched.
  final int totalMinor;

  /// Preparation time in minutes, when the backend has estimated one.
  final int? preparationTime;
  final DateTime createdAt;
  final List<SubOrderEntity> subOrders;
  final List<LineItemEntity> lineItems;
  final List<OrderEventEntity> events;
  final RiderInfoEntity? rider;
  final RiderLocationEntity? latestRiderLocation;

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
    this.totalMinor = 0,
    this.preparationTime,
    required this.createdAt,
    required this.subOrders,
    required this.lineItems,
    this.events = const [],
    this.rider,
    this.latestRiderLocation,
  });

  /// Real master-order statuses from the API for an order still in progress.
  /// PENDING_PAYMENT counts as active — it needs immediate user action.
  static const Set<String> activeStatuses = {
    'PENDING_PAYMENT',
    'PENDING',
    'CONFIRMED',
    'PARTIALLY_READY',
    'READY',
    'OUT_FOR_DELIVERY',
  };

  bool get isActive => activeStatuses.contains(status.toUpperCase());

  bool get isPendingPayment => status.toUpperCase() == 'PENDING_PAYMENT';

  bool get isCompleted =>
      status.toUpperCase() == 'DELIVERED' ||
      status.toUpperCase() == 'CANCELLED';

  bool get isDelivered => status.toUpperCase() == 'DELIVERED';

  bool get isCancelled => status.toUpperCase() == 'CANCELLED';

  OrderHistoryEntity copyWith({
    String? status,
    List<SubOrderEntity>? subOrders,
    List<OrderEventEntity>? events,
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
      totalMinor: totalMinor,
      preparationTime: preparationTime,
      createdAt: createdAt,
      subOrders: subOrders ?? this.subOrders,
      lineItems: lineItems,
      events: events ?? this.events,
      rider: rider,
      latestRiderLocation: latestRiderLocation,
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
