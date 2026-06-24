import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> login({
    required String identifier,
    required String password,
  });

  Future<User> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  });
}
