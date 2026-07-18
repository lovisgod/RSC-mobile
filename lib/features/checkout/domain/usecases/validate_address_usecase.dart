import '../../data/models/validate_address_response_model.dart';
import '../repositories/address_validation_repository.dart';

class ValidateAddressUseCase {
  const ValidateAddressUseCase(this._repository);

  final AddressValidationRepository _repository;

  Future<ValidateAddressResponseModel> call(
    double latitude,
    double longitude,
  ) => _repository.validateAddress(latitude, longitude);
}
