import '../entities/search_result_entity.dart';
import '../repositories/search_repository.dart';

class SearchItemsUseCase {
  const SearchItemsUseCase(this._repository);

  final SearchRepository _repository;

  Future<List<SearchResultEntity>> call(String query) =>
      _repository.search(query);
}
