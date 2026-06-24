import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository _repository;

  const RegisterUseCase(this._repository);

  Future<User> call({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) =>
      _repository.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );
}
