import '../../../auth/domain/entities/user.dart';

abstract class AuthEvent {
  const AuthEvent();
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthLoggedIn extends AuthEvent {
  final User user;
  const AuthLoggedIn(this.user);
}

class AuthLoggedOut extends AuthEvent {
  const AuthLoggedOut();
}
