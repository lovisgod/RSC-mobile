import '../../domain/entities/search_result_entity.dart';

abstract class SearchState {
  const SearchState();
}

class SearchInitial extends SearchState {
  const SearchInitial();
}

class SearchLoading extends SearchState {
  const SearchLoading();
}

class SearchLoaded extends SearchState {
  final List<SearchResultEntity> results;
  final String query;

  const SearchLoaded({required this.results, required this.query});

  /// Results grouped by outletId, preserving outlet order from results list.
  Map<String, List<SearchResultEntity>> get groupedByOutlet {
    final map = <String, List<SearchResultEntity>>{};
    for (final r in results) {
      map.putIfAbsent(r.outlet.id, () => []).add(r);
    }
    return map;
  }
}

class SearchEmpty extends SearchState {
  final String query;
  const SearchEmpty({required this.query});
}

class SearchError extends SearchState {
  final String message;
  const SearchError({required this.message});
}
