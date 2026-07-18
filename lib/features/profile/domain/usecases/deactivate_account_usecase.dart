import '../repositories/profile_repository.dart';

class DeactivateAccountUsecase {
  const DeactivateAccountUsecase(this._repository);

  final ProfileRepository _repository;

  Future<void> call() => _repository.deactivateAccount();
}
