import 'initiate_payment_item_model.dart';

/// Request body for `POST /api/v1/payments/initiate`.
class InitiatePaymentRequestModel {
  final List<InitiatePaymentItemModel> items;

  /// "DELIVERY" or "TAKEOUT" (backend enum values).
  final String deliveryMode;
  final String deliveryAddress;

  /// Null for takeout orders — there is no delivery point, so no coordinates
  /// are sent. Always present (and real) for delivery orders.
  final double? deliveryLatitude;
  final double? deliveryLongitude;

  /// Optional landmark to help the rider find the address (delivery only).
  final String? landmark;

  /// Optional phone number for the recipient (used when ordering for someone else).
  final String? recipientPhone;

  /// Optional top-level preparation note that applies to the whole order.
  final String? preparationNote;

  /// Deep link Moment redirects to after checkout completes.
  final String? returnUrl;

  final int subtotalMinor;
  final int deliveryFeeMinor;
  final int serviceFeeMinor;
  final int vatMinor;
  final int discountMinor;
  final int platformCommissionMinor;
  final int totalMinor;

  /// Unique per checkout attempt — sent as the `Idempotency-Key` header (see
  /// [PaymentRepositoryImpl.initiatePayment]), not part of the JSON body.
  final String idempotencyKey;

  const InitiatePaymentRequestModel({
    required this.items,
    required this.deliveryMode,
    required this.deliveryAddress,
    this.deliveryLatitude,
    this.deliveryLongitude,
    this.landmark,
    this.recipientPhone,
    this.preparationNote,
    this.returnUrl,
    required this.subtotalMinor,
    required this.deliveryFeeMinor,
    required this.serviceFeeMinor,
    required this.vatMinor,
    this.discountMinor = 0,
    required this.platformCommissionMinor,
    required this.totalMinor,
    required this.idempotencyKey,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'items': items.map((i) => i.toJson()).toList(),
      'deliveryMode': deliveryMode,
      'deliveryAddress': deliveryAddress,
      if (deliveryLatitude != null) 'deliveryLatitude': deliveryLatitude,
      if (deliveryLongitude != null) 'deliveryLongitude': deliveryLongitude,
      'subtotalMinor': subtotalMinor,
      'deliveryFeeMinor': deliveryFeeMinor,
      'serviceFeeMinor': serviceFeeMinor,
      'vatMinor': vatMinor,
      'discountMinor': discountMinor,
      'platformCommissionMinor': platformCommissionMinor,
      'totalMinor': totalMinor,
      'idempotencyKey': idempotencyKey,
    };
    // Only include optional fields when they have meaningful values so the
    // backend doesn't receive empty strings or null keys it doesn't expect.
    if (landmark != null && landmark!.isNotEmpty) {
      map['landmark'] = landmark;
    }
    if (recipientPhone != null && recipientPhone!.isNotEmpty) {
      map['recipientPhone'] = recipientPhone;
    }
    if (preparationNote != null && preparationNote!.isNotEmpty) {
      map['preparationNote'] = preparationNote;
    }
    if (returnUrl != null && returnUrl!.isNotEmpty) {
      map['returnUrl'] = returnUrl;
    }
    return map;
  }
}
