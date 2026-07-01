import 'initiate_payment_item_model.dart';

/// Request body for `POST /api/v1/payments/initiate`.
class InitiatePaymentRequestModel {
  final List<InitiatePaymentItemModel> items;

  /// "DELIVERY" or "TAKEOUT" (backend enum values).
  final String deliveryMode;
  final String deliveryAddress;
  final double deliveryLatitude;
  final double deliveryLongitude;

  const InitiatePaymentRequestModel({
    required this.items,
    required this.deliveryMode,
    required this.deliveryAddress,
    required this.deliveryLatitude,
    required this.deliveryLongitude,
  });

  Map<String, dynamic> toJson() => {
        'items': items.map((i) => i.toJson()).toList(),
        'deliveryMode': deliveryMode,
        'deliveryAddress': deliveryAddress,
        'deliveryLatitude': deliveryLatitude,
        'deliveryLongitude': deliveryLongitude,
      };
}
