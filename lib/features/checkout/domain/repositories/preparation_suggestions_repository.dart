import '../entities/preparation_suggestion_entity.dart';

abstract interface class PreparationSuggestionsRepository {
  Future<List<PreparationSuggestionEntity>> getSuggestions(
    String outletId, {
    String? q,
  });
}
