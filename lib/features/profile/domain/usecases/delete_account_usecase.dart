import '../repositories/profile_repository.dart';

/// Permanently deletes the user's account (`DELETE /api/v1/users/{id}`) —
/// unlike [DeactivateAccountUsecase] this is irreversible.
class DeleteAccountUsecase {
  const DeleteAccountUsecase(this._repository);

  final ProfileRepository _repository;

  Future<void> call(String userId) => _repository.deleteAccount(userId);
}
