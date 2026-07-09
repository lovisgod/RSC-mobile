import '../entities/preparation_suggestion_entity.dart';
import '../repositories/preparation_suggestions_repository.dart';

class GetPreparationSuggestionsUsecase {
  const GetPreparationSuggestionsUsecase(this._repository);

  final PreparationSuggestionsRepository _repository;

  Future<List<PreparationSuggestionEntity>> call(
    String outletId, {
    String? q,
  }) => _repository.getSuggestions(outletId, q: q);
}
