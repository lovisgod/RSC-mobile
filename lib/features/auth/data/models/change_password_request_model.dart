class ChangePasswordRequestModel {
  final String currentPassword;
  final String newPassword;

  const ChangePasswordRequestModel({
    required this.currentPassword,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      };
}
