// ignore_for_file: prefer_initializing_formals
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/storage/local_storage.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final RegisterUseCase _registerUseCase;
  final VerifyOtpUseCase _verifyOtpUseCase;
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final LocalStorage _localStorage;
  final PersistCookieJar _cookieJar;

  AuthBloc({
    required RegisterUseCase registerUseCase,
    required VerifyOtpUseCase verifyOtpUseCase,
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
    required LocalStorage localStorage,
    required PersistCookieJar cookieJar,
  })  : _registerUseCase = registerUseCase,
        _verifyOtpUseCase = verifyOtpUseCase,
        _loginUseCase = loginUseCase,
        _logoutUseCase = logoutUseCase,
        _localStorage = localStorage,
        _cookieJar = cookieJar,
        super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<RegisterSubmitted>(_onRegisterSubmitted);
    on<OtpSubmitted>(_onOtpSubmitted);
    on<OtpResendRequested>(_onOtpResendRequested);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<LogoutRequested>(_onLogoutRequested);

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
    // TODO: call resend endpoint when available from backend team
    await Future<void>.delayed(const Duration(milliseconds: 500));
    emit(const AuthFailure('Resend not available yet. Please try again later.'));
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
}
