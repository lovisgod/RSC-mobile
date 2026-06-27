import '../entities/search_result_entity.dart';

abstract class SearchRepository {
  Future<List<SearchResultEntity>> search(String query);
}
