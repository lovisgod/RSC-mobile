import '../../../../core/errors/exceptions.dart';
import '../../../../core/mock/mock_data.dart';
import '../../../../core/mock/mock_delays.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  @override
  Future<User> login({
    required String identifier,
    required String password,
  }) async {
    if (identifier.trim().isEmpty || password.isEmpty) {
      throw const AuthException('All fields are required');
    }
    if (password.length < 6) {
      throw const AuthException('Password must be at least 6 characters');
    }

    await Future.delayed(MockDelays.medium);

    return MockData.currentUser;
  }

  @override
  Future<User> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    if (name.trim().isEmpty ||
        email.trim().isEmpty ||
        phone.trim().isEmpty ||
        password.isEmpty) {
      throw const AuthException('All fields are required');
    }
    if (password.length < 6) {
      throw const AuthException('Password must be at least 6 characters');
    }

    await Future.delayed(MockDelays.medium);

    return MockData.currentUser;
  }
}
