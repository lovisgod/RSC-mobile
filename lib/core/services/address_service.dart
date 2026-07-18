import '../../features/checkout/data/models/address_suggestion_model.dart';
import '../../features/checkout/data/models/resolve_address_request_model.dart';
import '../../features/checkout/data/models/resolved_address_model.dart';
import '../constants/api_constants.dart';
import '../network/dio_client.dart';

/// Address autocomplete and resolution backed by the RSC delivery API
/// (Google Places under the hood). Authenticated via [DioClient]'s cookie
/// jar — never a separate Dio instance.
class AddressService {
  AddressService(this._dioClient);

  final DioClient _dioClient;

  Future<List<AddressSuggestionModel>> searchAddress(String query) async {
    if (query.trim().length < 3) return [];

    try {
      final response = await _dioClient.dio.get(
        ApiConstants.addressSuggestions,
        queryParameters: {'q': query},
      );

      final data = response.data['data'];
      if (data is! List) return [];

      return data
          .whereType<Map<String, dynamic>>()
          .map(AddressSuggestionModel.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<ResolvedAddressModel?> resolveAddress(
    AddressSuggestionModel suggestion,
  ) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.resolveAddress,
        data: ResolveAddressRequestModel(
          input: suggestion.description,
          suggestionId: suggestion.id,
          provider: suggestion.provider,
          sessionToken: suggestion.sessionToken,
        ).toJson(),
      );

      final data = response.data['data'];
      if (data is! Map<String, dynamic>) return null;
      return ResolvedAddressModel.fromJson(data);
    } catch (_) {
      return null;
    }
  }
}
