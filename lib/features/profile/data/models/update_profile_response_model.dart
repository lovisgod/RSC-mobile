import 'profile_model.dart';

class UpdateProfileResponseModel extends ProfileModel {
  const UpdateProfileResponseModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    required super.role,
    super.outletId,
    super.avatarUrl,
    super.verificationChannels,
  });

  factory UpdateProfileResponseModel.fromJson(Map<String, dynamic> json) {
    final profile = ProfileModel.fromJson(json);
    return UpdateProfileResponseModel(
      id: profile.id,
      name: profile.name,
      email: profile.email,
      phone: profile.phone,
      role: profile.role,
      outletId: profile.outletId,
      avatarUrl: profile.avatarUrl,
      verificationChannels: profile.verificationChannels,
    );
  }
}
