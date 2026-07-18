import 'initiate_payment_item_model.dart';

/// Request body for `POST /api/v1/payments/initiate`.
class InitiatePaymentRequestModel {
  final List<InitiatePaymentItemModel> items;

  /// "DELIVERY" or "TAKEOUT" (backend enum values).
  final String deliveryMode;
  final String deliveryAddress;
  final double deliveryLatitude;
  final double deliveryLongitude;

  /// Optional phone number for the recipient (used when ordering for someone else).
  final String? recipientPhone;

  /// Optional top-level preparation note that applies to the whole order.
  final String? preparationNote;

  final int subtotalMinor;
  final int deliveryFeeMinor;
  final int serviceFeeMinor;
  final int vatMinor;
  final int platformCommissionMinor;
  final int totalMinor;

  const InitiatePaymentRequestModel({
    required this.items,
    required this.deliveryMode,
    required this.deliveryAddress,
    required this.deliveryLatitude,
    required this.deliveryLongitude,
    this.recipientPhone,
    this.preparationNote,
    required this.subtotalMinor,
    required this.deliveryFeeMinor,
    required this.serviceFeeMinor,
    required this.vatMinor,
    required this.platformCommissionMinor,
    required this.totalMinor,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'items': items.map((i) => i.toJson()).toList(),
      'deliveryMode': deliveryMode,
      'deliveryAddress': deliveryAddress,
      'deliveryLatitude': deliveryLatitude,
      'deliveryLongitude': deliveryLongitude,
      'subtotalMinor': subtotalMinor,
      'deliveryFeeMinor': deliveryFeeMinor,
      'serviceFeeMinor': serviceFeeMinor,
      'vatMinor': vatMinor,
      'platformCommissionMinor': platformCommissionMinor,
      'totalMinor': totalMinor,
    };
    // Only include optional fields when they have meaningful values so the
    // backend doesn't receive empty strings or null keys it doesn't expect.
    if (recipientPhone != null && recipientPhone!.isNotEmpty) {
      map['recipientPhone'] = recipientPhone;
    }
    if (preparationNote != null && preparationNote!.isNotEmpty) {
      map['preparationNote'] = preparationNote;
    }
    return map;
  }
}
