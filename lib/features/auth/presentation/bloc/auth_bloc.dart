// ignore_for_file: prefer_initializing_formals
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/storage_keys.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final FlutterSecureStorage _storage;

  AuthBloc({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required FlutterSecureStorage storage,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _storage = storage,
        super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthOtpVerifyRequested>(_onOtpVerifyRequested);
    on<AuthLoggedIn>(_onLoggedIn);
    on<AuthLoggedOut>(_onLoggedOut);
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Phase 4: check stored tokens, restore session
    emit(const AuthUnauthenticated());
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _loginUseCase(
        identifier: event.identifier,
        password: event.password,
      );
      await _persistUser(user.id, user.name, user.phone, user.email);
      emit(AuthAuthenticated(user));
    } on AuthException catch (e) {
      emit(AuthFailure(e.message));
    } catch (_) {
      emit(const AuthFailure('Login failed. Please try again.'));
    }
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      // Phase 2 mock: simulate OTP dispatch to phone
      await Future<void>.delayed(const Duration(milliseconds: 1000));
      emit(AuthOtpSent(
        phone: event.phone,
        name: event.name,
        email: event.email,
        password: event.password,
      ));
    } on AuthException catch (e) {
      emit(AuthFailure(e.message));
    } catch (_) {
      emit(const AuthFailure('Failed to send OTP. Please try again.'));
    }
  }

  Future<void> _onOtpVerifyRequested(
    AuthOtpVerifyRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      if (event.otp.length != AppConstants.otpLength) {
        throw const AuthException('Enter a valid 6-digit code');
      }
      // Phase 2 mock: simulate OTP verification + account creation
      await Future<void>.delayed(const Duration(milliseconds: 1000));
      await _registerUseCase(
        name: event.name,
        email: event.email,
        phone: event.phone,
        password: event.password,
      );
      emit(const AuthRegisterSuccess());
    } on AuthException catch (e) {
      emit(AuthFailure(e.message));
    } catch (_) {
      emit(const AuthFailure('Verification failed. Please try again.'));
    }
  }

  void _onLoggedIn(AuthLoggedIn event, Emitter<AuthState> emit) {
    emit(AuthAuthenticated(event.user));
  }

  Future<void> _onLoggedOut(
    AuthLoggedOut event,
    Emitter<AuthState> emit,
  ) async {
    await _storage.deleteAll();
    emit(const AuthUnauthenticated());
  }

  Future<void> _persistUser(
    String id,
    String name,
    String phone,
    String? email,
  ) async {
    await _storage.write(key: StorageKeys.userId, value: id);
    await _storage.write(key: StorageKeys.userName, value: name);
    await _storage.write(key: StorageKeys.userPhone, value: phone);
    if (email != null) {
      await _storage.write(key: StorageKeys.userEmail, value: email);
    }
  }
}
