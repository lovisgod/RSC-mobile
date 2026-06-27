import '../../domain/entities/register_result.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/verify_otp_result.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/change_password_request_model.dart';
import '../models/forgot_password_request_model.dart';
import '../models/forgot_password_response_model.dart';
import '../models/login_request_model.dart';
import '../models/register_request_model.dart';
import '../models/resend_otp_request_model.dart';
import '../models/resend_otp_response_model.dart';
import '../models/reset_password_request_model.dart';
import '../models/verify_otp_request_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;

  const AuthRepositoryImpl(this._remote);

  @override
  Future<RegisterResult> register({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    final model = await _remote.register(
      RegisterRequestModel(
        name: name,
        phone: phone,
        email: email,
        password: password,
      ),
    );
    return RegisterResult(
      customerId: model.customerId,
      otpExpiresInSeconds: model.otpExpiresInSeconds,
      verificationChannels: model.verificationChannels,
    );
  }

  @override
  Future<VerifyOtpResult> verifyOtp({
    required String customerId,
    required String channel,
    String? phone,
    String? email,
    required String code,
  }) async {
    final model = await _remote.verifyOtp(
      VerifyOtpRequestModel(
        channel: channel,
        phone: phone,
        email: email,
        code: code,
      ),
    );
    return VerifyOtpResult(
      customerId: model.customerId,
      verificationChannels: model.verificationChannels,
    );
  }

  @override
  Future<UserEntity> login({
    required String identifier,
    required String password,
  }) async {
    final model = await _remote.login(
      LoginRequestModel(identifier: identifier, password: password),
    );
    return UserEntity(id: model.id, role: model.role);
  }

  @override
  Future<void> logout() => _remote.logout();

  @override
  Future<ForgotPasswordResponseModel> forgotPassword(
    String identifier,
  ) =>
      _remote.forgotPassword(ForgotPasswordRequestModel(identifier: identifier));

  @override
  Future<void> resetPassword(
    String identifier,
    String otpCode,
    String newPassword,
  ) =>
      _remote.resetPassword(
        ResetPasswordRequestModel(
          identifier: identifier,
          phoneCode: otpCode,
          emailCode: otpCode,
          newPassword: newPassword,
        ),
      );

  @override
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) =>
      _remote.changePassword(
        ChangePasswordRequestModel(
          currentPassword: currentPassword,
          newPassword: newPassword,
        ),
      );

  @override
  Future<ResendOtpResponseModel> resendVerificationCode(
    String channel,
    String phone,
    String email,
  ) =>
      _remote.resendVerificationCode(
        ResendOtpRequestModel(channel: channel, phone: phone, email: email),
      );
}
