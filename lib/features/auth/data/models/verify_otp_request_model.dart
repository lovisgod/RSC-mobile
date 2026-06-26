class VerifyOtpRequestModel {
  final String channel;
  final String? phone;
  final String? email;
  final String code;

  const VerifyOtpRequestModel({
    required this.channel,
    this.phone,
    this.email,
    required this.code,
  });

  Map<String, dynamic> toJson() {
    return {
      'channel': channel,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      'code': code,
    };
  }
}
