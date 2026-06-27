import '../../../menu/domain/entities/category.dart';
import '../../../menu/domain/entities/menu_item.dart';

class OutletMenu {
  final List<MenuCategory> categories;
  final Map<String, List<MenuItem>> itemsByCategory;

  const OutletMenu({
    required this.categories,
    required this.itemsByCategory,
  });
}
