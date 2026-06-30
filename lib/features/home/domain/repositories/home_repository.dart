import '../../../menu/domain/entities/category.dart';
import '../../../menu/domain/entities/menu_item.dart';
import '../../../menu/domain/entities/modifier_group.dart';
import '../../../menu/domain/entities/outlet.dart';

abstract class HomeRepository {
  Future<List<Outlet>> getOutlets();
  Future<List<MenuCategory>> getCategoriesForOutlet(String outletId);
  Future<List<MenuItem>> getItemsForCategory(String categoryId);

  /// All menu items for an outlet (with modifier groups attached). Backs the
  /// search feature, which reads from the same cached outlets.
  Future<List<MenuItem>> getItemsForOutlet(String outletId);

  /// Modifier groups (with their modifiers) for a single menu item, resolved
  /// through the outlet's `menuItemModifierGroups` join table.
  Future<List<ModifierGroup>> getModifierGroupsForItem(
    String outletId,
    String menuItemId,
  );

  /// Forces a re-fetch of the outlets payload, bypassing the in-memory cache.
  /// Call on pull-to-refresh.
  Future<List<Outlet>> refreshOutlets();
}
