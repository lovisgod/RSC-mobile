import '../../../menu/domain/entities/menu_item.dart';

class DailySpecial {
  final MenuItem menuItemRef;
  final String outletName;
  final int discountPercent;
  final double originalPrice;
  final double discountedPrice;
  final bool isTodaysPick;

  const DailySpecial({
    required this.menuItemRef,
    required this.outletName,
    required this.discountPercent,
    required this.originalPrice,
    required this.discountedPrice,
    this.isTodaysPick = false,
  });
}
