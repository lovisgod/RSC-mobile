class LoginResponseModel {
  final String id;
  final String role;

  const LoginResponseModel({required this.id, required this.role});

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>;
    return LoginResponseModel(
      id: user['id'] as String,
      role: user['role'] as String,
    );
  }
}
