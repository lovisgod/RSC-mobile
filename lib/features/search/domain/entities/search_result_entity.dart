import '../../../menu/domain/entities/menu_item.dart';
import '../../../menu/domain/entities/modifier_group.dart';
import '../../../menu/domain/entities/outlet.dart';

class SearchResultEntity {
  final MenuItem menuItem;
  final Outlet outlet;
  final List<ModifierGroup> modifierGroups;

  const SearchResultEntity({
    required this.menuItem,
    required this.outlet,
    required this.modifierGroups,
  });
}
