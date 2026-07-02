class VerifyOtpRequestModel {
  final String code;

  const VerifyOtpRequestModel({required this.code});

  Map<String, dynamic> toJson() => {'code': code};
}
