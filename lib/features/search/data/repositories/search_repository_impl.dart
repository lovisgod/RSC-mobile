import '../../../home/domain/repositories/home_repository.dart';
import '../../domain/entities/search_result_entity.dart';
import '../../domain/repositories/search_repository.dart';

/// Searches across the outlets/menu already cached by [HomeRepository] — no
/// separate API call is made; results come from the same in-memory payload
/// fetched on the home screen.
class SearchRepositoryImpl implements SearchRepository {
  const SearchRepositoryImpl(this._homeRepository);

  final HomeRepository _homeRepository;

  @override
  Future<List<SearchResultEntity>> search(String query) async {
    final outlets = await _homeRepository.getOutlets();

    // Build the full (item, outlet) result set from the cached data.
    final all = <SearchResultEntity>[];
    for (final outlet in outlets) {
      final items = await _homeRepository.getItemsForOutlet(outlet.id);
      for (final item in items) {
        all.add(SearchResultEntity(
          menuItem: item,
          outlet: outlet,
          modifierGroups: item.modifierGroups,
        ));
      }
    }

    final q = query.trim();
    if (q.length < 2) return all;

    final lower = q.toLowerCase();
    final results = all.where((r) {
      final item = r.menuItem;
      final outlet = r.outlet;
      return item.name.toLowerCase().contains(lower) ||
          item.description.toLowerCase().contains(lower) ||
          outlet.name.toLowerCase().contains(lower) ||
          outlet.cuisineType.toLowerCase().contains(lower);
    }).toList();

    // Sort: exact name matches first, then name partials, then the rest.
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
