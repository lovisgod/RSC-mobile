import '../../data/models/update_profile_response_model.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileUseCase {
  final ProfileRepository _repository;

  const UpdateProfileUseCase(this._repository);

  Future<UpdateProfileResponseModel> call(
    String name,
    String phone,
    String email,
  ) => _repository.updateProfile(name, phone, email);
}
