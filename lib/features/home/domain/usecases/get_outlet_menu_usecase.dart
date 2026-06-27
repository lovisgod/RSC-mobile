import '../../../menu/domain/entities/menu_item.dart';
import '../entities/outlet_menu.dart';
import '../repositories/home_repository.dart';

class GetOutletMenuUseCase {
  final HomeRepository _repository;
  const GetOutletMenuUseCase(this._repository);

  Future<OutletMenu> call(String outletId) async {
    final categories = await _repository.getCategoriesForOutlet(outletId);
    final itemsByCategory = <String, List<MenuItem>>{};
    for (final cat in categories) {
      itemsByCategory[cat.id] = await _repository.getItemsForCategory(cat.id);
    }
    return OutletMenu(categories: categories, itemsByCategory: itemsByCategory);
  }
}
