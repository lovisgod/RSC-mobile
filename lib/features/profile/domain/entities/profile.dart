class Profile {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? outletId;
  final String? avatarUrl;
  final Map<String, bool> verificationChannels;
  final Map<String, bool> pendingVerificationChannels;

  const Profile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.outletId,
    this.avatarUrl,
    this.verificationChannels = const {},
    this.pendingVerificationChannels = const {},
  });

  String get initials {
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    return words.take(2).map((w) => w[0].toUpperCase()).join();
  }

  String get displayPhone {
    if (phone.startsWith('0')) return phone;
    if (phone.startsWith('234')) return '0${phone.substring(3)}';
    return phone;
  }
}
