class ResendOtpRequestModel {
  final String channel;
  final String phone;
  final String email;

  const ResendOtpRequestModel({
    required this.channel,
    required this.phone,
    required this.email,
  });

  Map<String, dynamic> toJson() {
    if (channel == 'phone') {
      return {'channel': channel, 'phone': phone};
    }
    return {'channel': channel, 'email': email};
  }
}
