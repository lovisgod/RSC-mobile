import '../entities/verify_otp_result.dart';
import '../repositories/auth_repository.dart';

class VerifyOtpUseCase {
  final AuthRepository _repository;

  const VerifyOtpUseCase(this._repository);

  Future<VerifyOtpResult> call(String code) => _repository.verifyOtp(code);
}
