class Profile {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? avatarUrl;
  final String? defaultAddress;

  const Profile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.avatarUrl,
    this.defaultAddress,
  });
}
