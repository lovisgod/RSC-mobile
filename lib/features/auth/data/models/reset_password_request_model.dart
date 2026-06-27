class ResetPasswordRequestModel {
  final String identifier;
  final String phoneCode;
  final String emailCode;
  final String newPassword;

  const ResetPasswordRequestModel({
    required this.identifier,
    required this.phoneCode,
    required this.emailCode,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => {
        'identifier': identifier,
        'phoneCode': phoneCode,
        'emailCode': emailCode,
        'newPassword': newPassword,
      };
}
