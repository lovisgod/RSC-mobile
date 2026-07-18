import '../../data/models/validate_address_response_model.dart';

abstract class AddressValidationRepository {
  Future<ValidateAddressResponseModel> validateAddress(
    double latitude,
    double longitude,
  );
}
