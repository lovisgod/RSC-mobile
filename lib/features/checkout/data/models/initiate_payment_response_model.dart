/// Parsed `data` object from a successful `POST /api/v1/payments/initiate`
/// (201) response — the Paystack handoff details used by the follow-up step.
class InitiatePaymentResponseModel {
  final String authorizationUrl;
  final String reference;
  final String accessCode;

  const InitiatePaymentResponseModel({
    required this.authorizationUrl,
    required this.reference,
    required this.accessCode,
  });

  factory InitiatePaymentResponseModel.fromJson(Map<String, dynamic> json) {
    return InitiatePaymentResponseModel(
      authorizationUrl: json['authorizationUrl'] as String? ?? '',
      reference: json['reference'] as String? ?? '',
      accessCode: json['accessCode'] as String? ?? '',
    );
  }

  @override
  String toString() =>
      'InitiatePaymentResponseModel(reference: $reference, '
      'accessCode: $accessCode, authorizationUrl: $authorizationUrl)';
}
