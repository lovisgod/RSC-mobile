class VerifyProfileChangeRequestModel {
  final String code;

  const VerifyProfileChangeRequestModel({required this.code});

  Map<String, dynamic> toJson() => {'code': code};
}
