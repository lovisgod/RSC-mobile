import '../repositories/auth_repository.dart';

class ResetPasswordUseCase {
  const ResetPasswordUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call(
    String identifier,
    String otpCode,
    String newPassword,
  ) =>
      _repository.resetPassword(identifier, otpCode, newPassword);
}
