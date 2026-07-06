import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

class VerifyProfileChangeUseCase {
  final ProfileRepository _repository;

  const VerifyProfileChangeUseCase(this._repository);

  Future<Profile> call(String code) => _repository.verifyProfileChange(code);
}
