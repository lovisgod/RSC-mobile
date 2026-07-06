import '../../domain/entities/profile.dart';

class ProfileModel extends Profile {
  const ProfileModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    required super.role,
    super.outletId,
    super.avatarUrl,
    super.verificationChannels,
    super.pendingVerificationChannels,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
    id: json['id'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
    phone: json['phone'] as String,
    role: json['role'] as String,
    outletId: json['outletId'] as String?,
    avatarUrl: json['avatarUrl'] as String?,
    verificationChannels: _boolMap(json['verificationChannels']),
    pendingVerificationChannels: _boolMap(json['pendingVerificationChannels']),
  );

  static Map<String, bool> _boolMap(dynamic value) {
    if (value is! Map) return const {};
    return value.map((k, v) => MapEntry(k as String, v as bool));
  }
}
