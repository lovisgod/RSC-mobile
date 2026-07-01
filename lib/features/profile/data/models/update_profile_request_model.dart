class UpdateProfileRequestModel {
  final String name;
  final String phone;
  final String email;

  const UpdateProfileRequestModel({
    required this.name,
    required this.phone,
    required this.email,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'phone': phone,
    'email': email,
    'avatarUrl': null,
  };
}
