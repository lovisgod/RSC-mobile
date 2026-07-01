import 'dart:io';

import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

class UploadAvatarUseCase {
  final ProfileRepository _repository;

  const UploadAvatarUseCase(this._repository);

  Future<Profile> call(File imageFile) => _repository.uploadAvatar(imageFile);
}
