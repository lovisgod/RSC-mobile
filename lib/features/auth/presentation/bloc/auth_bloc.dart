// ignore_for_file: prefer_initializing_formals
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/storage/local_storage.dart';
import '../../domain/usecases/change_password_usecase.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/resend_otp_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final RegisterUseCase _registerUseCase;
  final VerifyOtpUseCase _verifyOtpUseCase;
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final ForgotPasswordUseCase _forgotPasswordUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;
  final ChangePasswordUseCase _changePasswordUseCase;
  final ResendOtpUseCase _resendOtpUseCase;
  final LocalStorage _localStorage;
  final PersistCookieJar _cookieJar;

  AuthBloc({
    required RegisterUseCase registerUseCase,
    required VerifyOtpUseCase verifyOtpUseCase,
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
    required ForgotPasswordUseCase forgotPasswordUseCase,
    required ResetPasswordUseCase resetPasswordUseCase,
    required ChangePasswordUseCase changePasswordUseCase,
    required ResendOtpUseCase resendOtpUseCase,
    required LocalStorage localStorage,
    required PersistCookieJar cookieJar,
  })  : _registerUseCase = registerUseCase,
        _verifyOtpUseCase = verifyOtpUseCase,
        _loginUseCase = loginUseCase,
        _logoutUseCase = logoutUseCase,
        _forgotPasswordUseCase = forgotPasswordUseCase,
        _resetPasswordUseCase = resetPasswordUseCase,
        _changePasswordUseCase = changePasswordUseCase,
        _resendOtpUseCase = resendOtpUseCase,
        _localStorage = localStorage,
        _cookieJar = cookieJar,
        super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<RegisterSubmitted>(_onRegisterSubmitted);
    on<OtpSubmitted>(_onOtpSubmitted);
    on<OtpResendRequested>(_onOtpResendRequested);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<LogoutRequested>(_onLogoutRequested);
    on<ForgotPasswordSubmitted>(_onForgotPasswordSubmitted);
    on<ResetPasswordOtpSubmitted>(_onResetPasswordOtpSubmitted);
    on<ResetPasswordSubmitted>(_onResetPasswordSubmitted);
    on<ChangePasswordSubmitted>(_onChangePasswordSubmitted);

    // Restore session on startup without waiting for an external dispatch
    add(const AuthCheckRequested());
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final user = await _localStorage.getUser();
    if (user != null) {
      emit(LoginSuccess(user));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final result = await _registerUseCase(
        name: event.name,
        phone: event.phone,
        email: event.email,
        password: event.password,
      );
      emit(RegisterSuccess(
        customerId: result.customerId,
        otpExpiresInSeconds: result.otpExpiresInSeconds,
        verificationChannels: result.verificationChannels,
        phone: event.phone,
        email: event.email,
      ));
    } on AuthException catch (e) {
      emit(AuthFailure(e.message));
    } catch (_) {
      emit(const AuthFailure('Registration failed. Please try again.'));
    }
  }

  Future<void> _onOtpSubmitted(
    OtpSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final result = await _verifyOtpUseCase(
        customerId: event.customerId,
        channel: event.channel,
        phone: event.phone,
        email: event.email,
        code: event.code,
      );
      emit(OtpVerifySuccess(
        customerId: result.customerId,
        verificationChannels: result.verificationChannels,
      ));
    } on AuthException catch (e) {
      emit(AuthFailure(e.message));
    } catch (_) {
      emit(const AuthFailure('Verification failed. Please try again.'));
    }
  }

  Future<void> _onOtpResendRequested(
    OtpResendRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final result = await _resendOtpUseCase(
        event.channel,
        event.phone,
        event.email,
      );
      emit(OtpResendSuccess(
        otpExpiresInSeconds: result.otpExpiresInSeconds,
        channel: result.channel.isNotEmpty ? result.channel : event.channel,
      ));
    } on AuthException catch (e) {
      emit(AuthFailure(e.message));
    } catch (_) {
      emit(const AuthFailure('Could not resend code. Please try again.'));
    }
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _loginUseCase(
        identifier: event.identifier,
        password: event.password,
      );
      await _localStorage.saveUser(user);
      emit(LoginSuccess(user));
    } on AuthException catch (e) {
      emit(AuthFailure(e.message));
    } catch (_) {
      emit(const AuthFailure('Login failed. Please try again.'));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _logoutUseCase();
    } catch (_) {
      // Server call may fail — always clear locally
    }
    try {
      await _cookieJar.deleteAll();
    } catch (_) {}
    await _localStorage.clearAll();
    emit(const LogoutSuccess());
  }

  Future<void> _onForgotPasswordSubmitted(
    ForgotPasswordSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    final identifier = event.identifier.trim();
    if (identifier.isEmpty) {
      emit(const AuthFailure('Please enter your email or phone number.'));
      return;
    }
    emit(const ForgotPasswordLoading());
    try {
      final result = await _forgotPasswordUseCase(identifier);
      emit(ForgotPasswordSuccess(
        identifier: identifier,
        otpExpiresInSeconds: result.otpExpiresInSeconds,
      ));
    } on AuthException catch (e) {
      emit(AuthFailure(e.message));
    } catch (_) {
      emit(const AuthFailure('Could not send reset code. Please try again.'));
    }
  }

  void _onResetPasswordOtpSubmitted(
    ResetPasswordOtpSubmitted event,
    Emitter<AuthState> emit,
  ) {
    if (event.otpCode.length != AppConstants.otpLength ||
        !RegExp(r'^\d+$').hasMatch(event.otpCode)) {
      emit(const AuthFailure('Please enter a valid 6-digit code.'));
      return;
    }
    emit(ResetPasswordOtpVerified(
      identifier: event.identifier,
      otpCode: event.otpCode,
    ));
  }

  Future<void> _onResetPasswordSubmitted(
    ResetPasswordSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    if (event.newPassword.length < 6) {
      emit(const AuthFailure('Password must be at least 6 characters.'));
      return;
    }
    emit(const AuthLoading());
    try {
      await _resetPasswordUseCase(
        event.identifier,
        event.otpCode,
        event.newPassword,
      );
      emit(const ResetPasswordSuccess());
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase().contains('invalid') ||
              e.message.toLowerCase().contains('expired')
          ? 'Invalid or expired code. Please request a new one.'
          : e.message;
      emit(AuthFailure(msg));
    } on Exception catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('401') ||
          msg.contains('invalid') ||
          msg.contains('expired')) {
        emit(const AuthFailure(
            'Invalid or expired code. Please request a new one.'));
      } else {
        emit(const AuthFailure('Password reset failed. Please try again.'));
      }
    }
  }

  Future<void> _onChangePasswordSubmitted(
    ChangePasswordSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    if (event.currentPassword.isEmpty || event.newPassword.isEmpty) {
      emit(const AuthFailure('All fields are required.'));
      return;
    }
    if (event.newPassword.length < 6) {
      emit(const AuthFailure('Password must be at least 6 characters.'));
      return;
    }
    emit(const AuthLoading());
    try {
      await _changePasswordUseCase(event.currentPassword, event.newPassword);
      emit(const ChangePasswordSuccess());
    } on AuthException catch (e) {
      emit(AuthFailure(e.message));
    } catch (_) {
      emit(const AuthFailure('Failed to update password. Please try again.'));
    }
  }
}
