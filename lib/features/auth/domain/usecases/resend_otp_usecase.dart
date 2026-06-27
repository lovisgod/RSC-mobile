import '../../data/models/resend_otp_response_model.dart';
import '../repositories/auth_repository.dart';

class ResendOtpUseCase {
  const ResendOtpUseCase(this._repository);

  final AuthRepository _repository;

  Future<ResendOtpResponseModel> call(
    String channel,
    String phone,
    String email,
  ) =>
      _repository.resendVerificationCode(channel, phone, email);
}
