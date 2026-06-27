import '../../../menu/domain/entities/category.dart';
import '../../../menu/domain/entities/menu_item.dart';
import '../../../menu/domain/entities/outlet.dart';

abstract class HomeRepository {
  Future<List<Outlet>> getOutlets();
  Future<List<MenuCategory>> getCategoriesForOutlet(String outletId);
  Future<List<MenuItem>> getItemsForCategory(String categoryId);
}
