import '../../data/models/forgot_password_response_model.dart';
import '../repositories/auth_repository.dart';

class ForgotPasswordUseCase {
  const ForgotPasswordUseCase(this._repository);

  final AuthRepository _repository;

  Future<ForgotPasswordResponseModel> call(String identifier) =>
      _repository.forgotPassword(identifier);
}
