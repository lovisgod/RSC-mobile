import '../entities/register_result.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository _repository;

  const RegisterUseCase(this._repository);

  Future<RegisterResult> call({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) =>
      _repository.register(
        name: name,
        phone: phone,
        email: email,
        password: password,
      );
}
