import '../../domain/entities/daily_special.dart';
import '../../domain/repositories/daily_specials_repository.dart';
import '../../domain/repositories/home_repository.dart';

/// Derives Daily Specials from the cached `GET /api/v1/outlets` payload.
class OutletsDailySpecialsRepository implements DailySpecialsRepository {
  final HomeRepository _homeRepository;

  const OutletsDailySpecialsRepository(this._homeRepository);

  @override
  Future<List<DailySpecial>> getDailySpecials() async {
    final now = DateTime.now();
    final outlets = await _homeRepository.getOutlets();
    final specials = <DailySpecial>[];

    for (final outlet in outlets) {
      final items = await _homeRepository.getItemsForOutlet(outlet.id);
      for (final item in items) {
        final discountedPrice = item.discountPrice;
        if (!item.isAvailable ||
            !item.isDiscountActive ||
            discountedPrice == null ||
            discountedPrice >= item.price ||
            !_isWithinDiscountWindow(
              now,
              startsAt: item.discountStartsAt,
              endsAt: item.discountEndsAt,
            )) {
          continue;
        }

        specials.add(
          DailySpecial(
            menuItemRef: item,
            outletName: outlet.name,
            discountPercent: _discountPercent(item.price, discountedPrice),
            originalPrice: item.price,
            discountedPrice: discountedPrice,
            isTodaysPick: specials.isEmpty,
          ),
        );
      }
    }

    specials.sort((a, b) => b.discountPercent.compareTo(a.discountPercent));
    if (specials.isEmpty) return specials;

    return [
      specials.first,
      for (final special in specials.skip(1))
        DailySpecial(
          menuItemRef: special.menuItemRef,
          outletName: special.outletName,
          discountPercent: special.discountPercent,
          originalPrice: special.originalPrice,
          discountedPrice: special.discountedPrice,
        ),
    ];
  }

  bool _isWithinDiscountWindow(
    DateTime now, {
    required DateTime? startsAt,
    required DateTime? endsAt,
  }) {
    final startsOk = startsAt == null || !now.isBefore(startsAt);
    final endsOk = endsAt == null || !now.isAfter(endsAt);
    return startsOk && endsOk;
  }

  int _discountPercent(double originalPrice, double discountedPrice) {
    if (originalPrice <= 0) return 0;
    return (((originalPrice - discountedPrice) / originalPrice) * 100).round();
  }
}
