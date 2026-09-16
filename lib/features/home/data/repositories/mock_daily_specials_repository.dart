import '../../../menu/domain/entities/menu_item.dart';
import '../../domain/entities/daily_special.dart';
import '../../domain/repositories/daily_specials_repository.dart';

/// Mock implementation of [DailySpecialsRepository] — the Daily Specials
/// section ships against static data first, real API wiring is deferred.
class MockDailySpecialsRepository implements DailySpecialsRepository {
  @override
  Future<List<DailySpecial>> getDailySpecials() async {
    return _specials;
  }

  static final List<DailySpecial> _specials = [
    DailySpecial(
      menuItemRef: const MenuItem(
        id: 'mock-special-1',
        categoryId: 'mock-category',
        outletId: 'mock-outlet-1',
        name: 'Smoky Suya Platter',
        description: 'Grilled beef suya with fresh onions and pepper mix.',
        price: 4500,
        imageUrl: null,
        isAvailable: true,
      ),
      outletName: 'Cactus',
      discountPercent: 20,
      originalPrice: 4500,
      discountedPrice: 3600,
      isTodaysPick: true,
    ),
    DailySpecial(
      menuItemRef: const MenuItem(
        id: 'mock-special-2',
        categoryId: 'mock-category',
        outletId: 'mock-outlet-2',
        name: 'Party Jollof Rice',
        description: 'Smoky party-style jollof rice with fried plantain.',
        price: 3800,
        imageUrl: null,
        isAvailable: true,
      ),
      outletName: 'Salmas Kitchen',
      discountPercent: 15,
      originalPrice: 3800,
      discountedPrice: 3230,
    ),
    DailySpecial(
      menuItemRef: const MenuItem(
        id: 'mock-special-3',
        categoryId: 'mock-category',
        outletId: 'mock-outlet-3',
        name: 'Double Smash Burger',
        description: 'Two smashed beef patties, cheese, and special sauce.',
        price: 5200,
        imageUrl: null,
        isAvailable: true,
      ),
      outletName: 'Grill House',
      discountPercent: 25,
      originalPrice: 5200,
      discountedPrice: 3900,
    ),
  ];
}
