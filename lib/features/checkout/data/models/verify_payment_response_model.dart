/// Parsed `data` object from `GET /api/v1/payments/verify/{reference}`.
class VerifyPaymentResponseModel {
  final String status;
  final String orderStatus;

  const VerifyPaymentResponseModel({
    required this.status,
    required this.orderStatus,
  });

  factory VerifyPaymentResponseModel.fromJson(Map<String, dynamic> json) {
    return VerifyPaymentResponseModel(
      status: json['status'] as String? ?? '',
      orderStatus: json['orderStatus'] as String? ?? '',
    );
  }

  bool get isSuccess => status.toUpperCase() == 'SUCCESS';
  bool get isPending => status.toUpperCase() == 'PENDING';

  @override
  String toString() =>
      'VerifyPaymentResponseModel(status: $status, orderStatus: $orderStatus)';
}
