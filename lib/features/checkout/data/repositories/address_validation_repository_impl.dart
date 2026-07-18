import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/repositories/address_validation_repository.dart';
import '../models/validate_address_request_model.dart';
import '../models/validate_address_response_model.dart';

class AddressValidationRepositoryImpl implements AddressValidationRepository {
  const AddressValidationRepositoryImpl(this._client);

  final DioClient _client;

  /// Always resolves — the endpoint itself never throws for an out-of-zone
  /// point (still 200, deliverable: false), and a network failure is treated
  /// the same way: not deliverable, rather than surfacing an error to the
  /// user mid-checkout.
  @override
  Future<ValidateAddressResponseModel> validateAddress(
    double latitude,
    double longitude,
  ) async {
    try {
      final response = await _client.dio.post(
        ApiConstants.validateAddress,
        data: ValidateAddressRequestModel(
          latitude: latitude,
          longitude: longitude,
        ).toJson(),
      );

      final data =
          (response.data as Map<String, dynamic>)['data']
              as Map<String, dynamic>;
      return ValidateAddressResponseModel.fromJson(data);
    } catch (_) {
      return const ValidateAddressResponseModel(deliverable: false);
    }
  }
}
