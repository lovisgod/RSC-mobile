import '../../../../core/mock/mock_data.dart';
import '../../../menu/domain/entities/category.dart';
import '../../../menu/domain/entities/menu_item.dart';
import '../../../menu/domain/entities/outlet.dart';
import '../../domain/repositories/home_repository.dart';

class MockHomeRepository implements HomeRepository {
  const MockHomeRepository();

  @override
  Future<List<Outlet>> getOutlets() async {
    await Future.delayed(const Duration(milliseconds: 700));
    return MockData.outlets;
  }

  @override
  Future<List<MenuCategory>> getCategoriesForOutlet(String outletId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return MockData.categoriesForOutlet(outletId);
  }

  @override
  Future<List<MenuItem>> getItemsForCategory(String categoryId) async {
    return MockData.itemsForCategory(categoryId);
  }
}
