import 'dart:io';

import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';
import '../models/update_profile_request_model.dart';
import '../models/update_profile_response_model.dart';
import '../models/verify_profile_change_request_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remote;

  const ProfileRepositoryImpl(this._remote);

  @override
  Future<Profile> getProfile() => _remote.getProfile();

  @override
  Future<UpdateProfileResponseModel> updateProfile(
    String name,
    String phone,
    String email,
  ) => _remote.updateProfile(
    UpdateProfileRequestModel(name: name, phone: phone, email: email),
  );

  @override
  Future<Profile> uploadAvatar(File imageFile) =>
      _remote.uploadAvatar(imageFile);

  @override
  Future<Profile> verifyProfileChange(String code) =>
      _remote.verifyProfileChange(VerifyProfileChangeRequestModel(code: code));

  @override
  Future<void> deactivateAccount() => _remote.deactivateAccount();
}
