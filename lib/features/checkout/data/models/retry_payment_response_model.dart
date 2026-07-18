/// Parsed `data` object from a successful
/// `POST /api/v1/payments/orders/{orderId}/retry` (201) response — the same
/// shape as the initiate-payment response.
class RetryPaymentResponseModel {
  final String masterOrderId;
  final String reference;
  final String checkoutUrl;
  final String status;

  const RetryPaymentResponseModel({
    required this.masterOrderId,
    required this.reference,
    required this.checkoutUrl,
    required this.status,
  });

  factory RetryPaymentResponseModel.fromJson(Map<String, dynamic> json) {
    return RetryPaymentResponseModel(
      masterOrderId: json['masterOrderId'] as String? ?? '',
      reference: json['reference'] as String? ?? '',
      checkoutUrl:
          json['checkoutUrl'] as String? ??
          json['authorizationUrl'] as String? ??
          '',
      status: json['status'] as String? ?? '',
    );
  }

  @override
  String toString() =>
      'RetryPaymentResponseModel(reference: $reference, '
      'checkoutUrl: $checkoutUrl, masterOrderId: $masterOrderId, '
      'status: $status)';
}
