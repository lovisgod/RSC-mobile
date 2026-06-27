class ResendOtpResponseModel {
  final bool sent;
  final String channel;
  final int otpExpiresInSeconds;

  const ResendOtpResponseModel({
    required this.sent,
    required this.channel,
    required this.otpExpiresInSeconds,
  });

  factory ResendOtpResponseModel.fromJson(Map<String, dynamic> json) =>
      ResendOtpResponseModel(
        sent: json['sent'] as bool? ?? false,
        channel: json['channel'] as String? ?? '',
        otpExpiresInSeconds: json['otpExpiresInSeconds'] as int? ?? 600,
      );
}
