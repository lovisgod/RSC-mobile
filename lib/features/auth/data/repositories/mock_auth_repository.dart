import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

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

    await Future.delayed(const Duration(milliseconds: 1500));

    final isEmail = identifier.contains('@');
    return UserModel(
      id: 'mock_user_001',
      name: 'Enobong Ndedde',
      phone: isEmail ? '+2348012345678' : identifier,
      email: isEmail ? identifier : 'user@rscfood.com',
    );
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

    await Future.delayed(const Duration(milliseconds: 1500));

    return UserModel(
      id: 'mock_user_002',
      name: name.trim(),
      phone: phone.trim(),
      email: email.trim().toLowerCase(),
    );
  }
}
