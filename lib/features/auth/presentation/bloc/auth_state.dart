import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class RegisterSuccess extends AuthState {
  final String customerId;
  final int otpExpiresInSeconds;
  final Map<String, bool> verificationChannels;
  final String phone;
  final String email;

  const RegisterSuccess({
    required this.customerId,
    required this.otpExpiresInSeconds,
    required this.verificationChannels,
    required this.phone,
    required this.email,
  });

  @override
  List<Object?> get props => [customerId];
}

class OtpVerifySuccess extends AuthState {
  final String customerId;
  final Map<String, bool> verificationChannels;

  const OtpVerifySuccess({
    required this.customerId,
    required this.verificationChannels,
  });

  @override
  List<Object?> get props => [customerId];
}

class LoginSuccess extends AuthState {
  final UserEntity user;

  const LoginSuccess(this.user);

  @override
  List<Object?> get props => [user.id];
}

class LogoutSuccess extends AuthState {
  const LogoutSuccess();
}

class AuthFailure extends AuthState {
  final String message;

  const AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class ForgotPasswordLoading extends AuthState {
  const ForgotPasswordLoading();
}

class ForgotPasswordSuccess extends AuthState {
  final String identifier;
  final int otpExpiresInSeconds;

  const ForgotPasswordSuccess({
    required this.identifier,
    required this.otpExpiresInSeconds,
  });

  @override
  List<Object?> get props => [identifier, otpExpiresInSeconds];
}

class ResetPasswordOtpVerified extends AuthState {
  final String identifier;
  final String otpCode;

  const ResetPasswordOtpVerified({
    required this.identifier,
    required this.otpCode,
  });

  @override
  List<Object?> get props => [identifier, otpCode];
}

class ResetPasswordSuccess extends AuthState {
  const ResetPasswordSuccess();
}

class OtpResendSuccess extends AuthState {
  final int otpExpiresInSeconds;
  final String channel;

  const OtpResendSuccess({
    required this.otpExpiresInSeconds,
    required this.channel,
  });

  @override
  List<Object?> get props => [otpExpiresInSeconds, channel];
}

class ChangePasswordSuccess extends AuthState {
  const ChangePasswordSuccess();
}
