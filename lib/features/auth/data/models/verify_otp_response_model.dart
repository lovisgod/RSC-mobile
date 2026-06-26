class VerifyOtpResponseModel {
  final String customerId;
  final Map<String, bool> verificationChannels;

  const VerifyOtpResponseModel({
    required this.customerId,
    required this.verificationChannels,
  });

  factory VerifyOtpResponseModel.fromJson(Map<String, dynamic> json) {
    final channels = (json['verificationChannels'] as Map<String, dynamic>? ?? {})
        .map((k, v) => MapEntry(k, v as bool));
    return VerifyOtpResponseModel(
      customerId: json['customerId'] as String,
      verificationChannels: channels,
    );
  }
}
