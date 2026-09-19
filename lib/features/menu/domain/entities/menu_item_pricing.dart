/// Discount-window pricing, computed client-side rather than trusted
/// straight off an API payload — mirrors the server's own check
/// (`menu-item.entity.ts`) and the web `@rsc/contracts` helpers
/// `isMenuItemDiscountActive`/`getMenuItemCurrentPriceMinor`. A cached or
/// stale response can otherwise disagree with the device clock about
/// whether a discount window is currently open.
library;

bool isMenuItemDiscountActive({
  required double price,
  required double? discountPrice,
  required DateTime? discountStartsAt,
  required DateTime? discountEndsAt,
  DateTime? at,
}) {
  if (discountPrice == null || discountPrice >= price) return false;

  final now = at ?? DateTime.now();
  final startsOk = discountStartsAt == null || !now.isBefore(discountStartsAt);
  final endsOk = discountEndsAt == null || !now.isAfter(discountEndsAt);
  return startsOk && endsOk;
}

double getMenuItemCurrentPrice({
  required double price,
  required double? discountPrice,
  required DateTime? discountStartsAt,
  required DateTime? discountEndsAt,
  DateTime? at,
}) {
  final active = isMenuItemDiscountActive(
    price: price,
    discountPrice: discountPrice,
    discountStartsAt: discountStartsAt,
    discountEndsAt: discountEndsAt,
    at: at,
  );
  return active ? discountPrice! : price;
}
