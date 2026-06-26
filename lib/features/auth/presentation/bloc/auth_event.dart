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
  final String customerId;
  final String channel; // 'phone' | 'email'
  final String? phone;
  final String? email;
  final String code;

  const OtpSubmitted({
    required this.customerId,
    required this.channel,
    this.phone,
    this.email,
    required this.code,
  });
}

class OtpResendRequested extends AuthEvent {
  final String customerId;
  const OtpResendRequested(this.customerId);
}

class LoginSubmitted extends AuthEvent {
  final String identifier;
  final String password;

  const LoginSubmitted({
    required this.identifier,
    required this.password,
  });
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}
