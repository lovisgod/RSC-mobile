class RegisterResponseModel {
  final String customerId;
  final int otpExpiresInSeconds;
  final Map<String, bool> verificationChannels;

  const RegisterResponseModel({
    required this.customerId,
    required this.otpExpiresInSeconds,
    required this.verificationChannels,
  });

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    final channels = (json['verificationChannels'] as Map<String, dynamic>? ?? {})
        .map((k, v) => MapEntry(k, v as bool));
    return RegisterResponseModel(
      customerId: json['customerId'] as String,
      otpExpiresInSeconds: json['otpExpiresInSeconds'] as int,
      verificationChannels: channels,
    );
  }
}
