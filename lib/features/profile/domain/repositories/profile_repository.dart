import 'dart:io';

import '../../data/models/update_profile_response_model.dart';
import '../entities/profile.dart';

abstract class ProfileRepository {
  Future<Profile> getProfile();

  Future<UpdateProfileResponseModel> updateProfile(
    String name,
    String phone,
    String email,
  );

  Future<Profile> uploadAvatar(File imageFile);
}
