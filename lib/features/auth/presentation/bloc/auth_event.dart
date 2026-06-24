import '../../../auth/domain/entities/user.dart';

abstract class AuthEvent {
  const AuthEvent();
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthLoginRequested extends AuthEvent {
  final String identifier;
  final String password;

  const AuthLoginRequested({
    required this.identifier,
    required this.password,
  });
}

class AuthRegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String phone;
  final String password;

  const AuthRegisterRequested({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
  });
}

class AuthOtpVerifyRequested extends AuthEvent {
  final String otp;
  final String name;
  final String email;
  final String phone;
  final String password;

  const AuthOtpVerifyRequested({
    required this.otp,
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
  });
}

class AuthLoggedIn extends AuthEvent {
  final User user;
  const AuthLoggedIn(this.user);
}

class AuthLoggedOut extends AuthEvent {
  const AuthLoggedOut();
}
