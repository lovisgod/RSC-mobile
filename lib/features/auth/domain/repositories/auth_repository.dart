import '../../data/models/forgot_password_response_model.dart';
import '../../data/models/resend_otp_response_model.dart';
import '../entities/register_result.dart';
import '../entities/user_entity.dart';
import '../entities/verify_otp_result.dart';

abstract class AuthRepository {
  Future<RegisterResult> register({
    required String name,
    required String phone,
    required String email,
    required String password,
  });

  Future<VerifyOtpResult> verifyOtp({
    required String customerId,
    required String channel,
    String? phone,
    String? email,
    required String code,
  });

  Future<UserEntity> login({
    required String identifier,
    required String password,
  });

  Future<void> logout();

  Future<ForgotPasswordResponseModel> forgotPassword(String identifier);

  Future<void> resetPassword(
    String identifier,
    String otpCode,
    String newPassword,
  );

  Future<void> changePassword(String currentPassword, String newPassword);
  Future<ResendOtpResponseModel> resendVerificationCode(
    String channel,
    String phone,
    String email,
  );
}
