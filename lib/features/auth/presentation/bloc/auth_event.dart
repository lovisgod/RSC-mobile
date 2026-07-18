abstract class AuthEvent {
  const AuthEvent();
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class RegisterSubmitted extends AuthEvent {
  final String name;
  final String phone;
  final String email;
  final String password;

  const RegisterSubmitted({
    required this.name,
    required this.phone,
    required this.email,
    required this.password,
  });
}

class OtpSubmitted extends AuthEvent {
  final String code;

  const OtpSubmitted({required this.code});
}

class OtpResendRequested extends AuthEvent {
  final String channel;
  final String phone;
  final String email;
  const OtpResendRequested({
    required this.channel,
    required this.phone,
    required this.email,
  });
}

class LoginSubmitted extends AuthEvent {
  final String identifier;
  final String password;

  const LoginSubmitted({required this.identifier, required this.password});
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

/// Fired by SessionInterceptor when a 401 on a non-auth endpoint indicates
/// the session is dead. Unlike [LogoutRequested] this never calls the
/// logout endpoint — the session is already known to be invalid, and that
/// call would just fail with another 401.
class SessionExpired extends AuthEvent {
  const SessionExpired();
}

class ForgotPasswordSubmitted extends AuthEvent {
  final String identifier;
  const ForgotPasswordSubmitted({required this.identifier});
}

class ResetPasswordOtpSubmitted extends AuthEvent {
  final String identifier;
  final String otpCode;
  const ResetPasswordOtpSubmitted({
    required this.identifier,
    required this.otpCode,
  });
}

class ResetPasswordSubmitted extends AuthEvent {
  final String identifier;
  final String otpCode;
  final String newPassword;
  const ResetPasswordSubmitted({
    required this.identifier,
    required this.otpCode,
    required this.newPassword,
  });
}

class ChangePasswordSubmitted extends AuthEvent {
  final String currentPassword;
  final String newPassword;
  const ChangePasswordSubmitted({
    required this.currentPassword,
    required this.newPassword,
  });
}
