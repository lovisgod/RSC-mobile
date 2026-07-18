import '../../../track/domain/entities/order_event_entity.dart';
import '../../../track/domain/entities/rider_info_entity.dart';
import '../../../track/domain/entities/rider_location_entity.dart';
import '../../domain/entities/line_item_entity.dart';
import '../../domain/entities/order_history_entity.dart';
import '../../domain/entities/sub_order_entity.dart';

class OrderSummaryModel {
  final String id;
  final String customerId;
  final String? riderId;
  final String status;
  final double subtotal;
  final double deliveryFee;
  final double serviceFee;
  final double vat;
  final double discount;
  final double total;
  final int totalMinor;
  final String currency;
  final String deliveryMode;
  final String deliveryAddress;
  final double? deliveryLatitude;
  final double? deliveryLongitude;
  final String paymentReference;
  final String deliveryCode;
  final String? recipientPhone;

  /// Minutes, from the backend — int or null, never a string.
  final int? preparationTime;
  final String? customerViewId;
  final String? sourceMasterOrderId;
  final int refundableMinor;
  final List<String> refundSubOrderIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  const OrderSummaryModel({
    required this.id,
    required this.customerId,
    this.riderId,
    required this.status,
    required this.subtotal,
    required this.deliveryFee,
    required this.serviceFee,
    required this.vat,
    required this.discount,
    required this.total,
    this.totalMinor = 0,
    required this.currency,
    required this.deliveryMode,
    required this.deliveryAddress,
    this.deliveryLatitude,
    this.deliveryLongitude,
    required this.paymentReference,
    required this.deliveryCode,
    this.recipientPhone,
    this.preparationTime,
    this.customerViewId,
    this.sourceMasterOrderId,
    this.refundableMinor = 0,
    this.refundSubOrderIds = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderSummaryModel.fromJson(Map<String, dynamic> json) {
    return OrderSummaryModel(
      id: json['id'] as String? ?? '',
      customerId: json['customerId'] as String? ?? '',
      riderId: json['riderId'] as String?,
      status: json['status'] as String? ?? '',
      subtotal: ((json['subtotalMinor'] as num?) ?? 0) / 100,
      deliveryFee: ((json['deliveryFeeMinor'] as num?) ?? 0) / 100,
      serviceFee: ((json['serviceFeeMinor'] as num?) ?? 0) / 100,
      vat: ((json['vatMinor'] as num?) ?? 0) / 100,
      discount: ((json['discountMinor'] as num?) ?? 0) / 100,
      total: ((json['totalMinor'] as num?) ?? 0) / 100,
      totalMinor: (json['totalMinor'] as num?)?.toInt() ?? 0,
      currency: json['currency'] as String? ?? 'NGN',
      deliveryMode: json['deliveryMode'] as String? ?? 'DELIVERY',
      deliveryAddress: json['deliveryAddress'] as String? ?? '',
      deliveryLatitude: (json['deliveryLatitude'] as num?)?.toDouble(),
      deliveryLongitude: (json['deliveryLongitude'] as num?)?.toDouble(),
      paymentReference: json['paymentReference'] as String? ?? '',
      deliveryCode: json['deliveryCode'] as String? ?? '',
      recipientPhone: json['recipientPhone'] as String?,
      preparationTime: (json['preparationTime'] as num?)?.toInt(),
      customerViewId: json['customerViewId'] as String?,
      sourceMasterOrderId: json['sourceMasterOrderId'] as String?,
      refundableMinor: (json['refundableMinor'] as num?)?.toInt() ?? 0,
      refundSubOrderIds: ((json['refundSubOrderIds'] as List?) ?? [])
          .whereType<String>()
          .toList(),
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  OrderHistoryEntity toEntity({
    List<SubOrderEntity> subOrders = const [],
    List<LineItemEntity> lineItems = const [],
    List<OrderEventEntity> events = const [],
    RiderInfoEntity? rider,
    RiderLocationEntity? latestRiderLocation,
  }) => OrderHistoryEntity(
    id: id,
    paymentReference: paymentReference,
    deliveryCode: deliveryCode,
    status: status,
    deliveryMode: deliveryMode,
    deliveryAddress: deliveryAddress,
    subtotal: subtotal,
    deliveryFee: deliveryFee,
    vat: vat,
    total: total,
    totalMinor: totalMinor,
    preparationTime: preparationTime,
    createdAt: createdAt,
    subOrders: subOrders,
    lineItems: lineItems,
    events: events,
    rider: rider,
    latestRiderLocation: latestRiderLocation,
  );
}
