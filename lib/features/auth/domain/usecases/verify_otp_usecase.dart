import '../entities/verify_otp_result.dart';
import '../repositories/auth_repository.dart';

class VerifyOtpUseCase {
  final AuthRepository _repository;

  const VerifyOtpUseCase(this._repository);

  Future<VerifyOtpResult> call({
    required String customerId,
    required String channel,
    String? phone,
    String? email,
    required String code,
  }) =>
      _repository.verifyOtp(
        customerId: customerId,
        channel: channel,
        phone: phone,
        email: email,
        code: code,
      );
}
