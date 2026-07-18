/// Parsed `data` object from a successful `POST /api/v1/payments/initiate`
/// (201) response.
class InitiatePaymentResponseModel {
  final String checkoutUrl;
  final String reference;
  final String? masterOrderId;
  final String? paymentId;

  // Compatibility getters for legacy fields
  String get authorizationUrl => checkoutUrl;
  String get accessCode => '';

  const InitiatePaymentResponseModel({
    required this.checkoutUrl,
    required this.reference,
    this.masterOrderId,
    this.paymentId,
  });

  factory InitiatePaymentResponseModel.fromJson(Map<String, dynamic> json) {
    return InitiatePaymentResponseModel(
      checkoutUrl: json['checkoutUrl'] as String? ?? json['authorizationUrl'] as String? ?? '',
      reference: json['reference'] as String? ?? '',
      masterOrderId: json['masterOrderId'] as String?,
      paymentId: json['paymentId'] as String?,
    );
  }

  @override
  String toString() =>
      'InitiatePaymentResponseModel(reference: $reference, '
      'checkoutUrl: $checkoutUrl, masterOrderId: $masterOrderId, paymentId: $paymentId)';
}
