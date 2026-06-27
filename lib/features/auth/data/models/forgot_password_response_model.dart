class ForgotPasswordResponseModel {
  final bool sent;
  final int otpExpiresInSeconds;

  const ForgotPasswordResponseModel({
    required this.sent,
    required this.otpExpiresInSeconds,
  });

  factory ForgotPasswordResponseModel.fromJson(Map<String, dynamic> json) =>
      ForgotPasswordResponseModel(
        sent: json['sent'] as bool? ?? false,
        otpExpiresInSeconds: json['otpExpiresInSeconds'] as int? ?? 600,
      );
}
