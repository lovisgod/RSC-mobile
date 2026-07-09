import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/preparation_suggestion_entity.dart';
import '../../domain/repositories/preparation_suggestions_repository.dart';
import '../models/preparation_suggestion_model.dart';

class PreparationSuggestionsRepositoryImpl
    implements PreparationSuggestionsRepository {
  const PreparationSuggestionsRepositoryImpl(this._client);

  final DioClient _client;

  /// Suggestions are a checkout nicety, never a blocker — any failure here
  /// (network, parsing, server error) resolves to an empty list silently.
  @override
  Future<List<PreparationSuggestionEntity>> getSuggestions(
    String outletId, {
    String? q,
  }) async {
    try {
      final response = await _client.dio.get(
        ApiConstants.preparationSuggestions,
        queryParameters: {
          'outletId': outletId,
          if (q != null && q.isNotEmpty) 'q': q,
        },
      );

      final data = (response.data as Map<String, dynamic>)['data'] as List;
      final suggestions =
          data
              .map(
                (e) => PreparationSuggestionModel.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .where((model) => model.isActive)
              .toList()
            ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

      return suggestions.map((model) => model.toEntity()).toList();
    } catch (_) {
      return [];
    }
  }
}
