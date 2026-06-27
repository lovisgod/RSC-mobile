import '../../../../core/mock/mock_data.dart';
import '../../../../core/mock/mock_delays.dart';
import '../../domain/entities/search_result_entity.dart';
import '../../domain/repositories/search_repository.dart';

class MockSearchRepository implements SearchRepository {
  const MockSearchRepository();

  @override
  Future<List<SearchResultEntity>> search(String query) async {
    await Future.delayed(MockDelays.short);

    final q = query.trim();
    final results = <SearchResultEntity>[];

    if (q.length < 2) {
      // Return every item across all outlets unfiltered
      for (final outlet in MockData.outlets) {
        for (final item in MockData.itemsForOutlet(outlet.id)) {
          results.add(SearchResultEntity(
            menuItem: item,
            outlet: outlet,
            modifierGroups: item.modifierGroups,
          ));
        }
      }
      return results;
    }

    final lower = q.toLowerCase();

    for (final outlet in MockData.outlets) {
      for (final item in MockData.itemsForOutlet(outlet.id)) {
        final matches = item.name.toLowerCase().contains(lower) ||
            item.description.toLowerCase().contains(lower) ||
            outlet.name.toLowerCase().contains(lower) ||
            outlet.cuisineType.toLowerCase().contains(lower);

        if (matches) {
          results.add(SearchResultEntity(
            menuItem: item,
            outlet: outlet,
            modifierGroups: item.modifierGroups,
          ));
        }
      }
    }

    // Sort: exact name matches first, then name partial, then others
    results.sort((a, b) {
      final aName = a.menuItem.name.toLowerCase();
      final bName = b.menuItem.name.toLowerCase();
      final aExact = aName == lower;
      final bExact = bName == lower;
      if (aExact && !bExact) return -1;
      if (!aExact && bExact) return 1;
      final aNameMatch = aName.contains(lower);
      final bNameMatch = bName.contains(lower);
      if (aNameMatch && !bNameMatch) return -1;
      if (!aNameMatch && bNameMatch) return 1;
      return 0;
    });

    return results;
  }
}
