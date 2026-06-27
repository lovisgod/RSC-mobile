abstract final class RouteNames {
  static const String home = '/';
  static const String auth = '/auth';
  static const String checkout = '/checkout';
  static const String outletDetail = '/outlet/:outletId';
  static const String itemDetail = '/outlet/:outletId/item/:itemId';
  static const String orderHistory = '/profile/orders';
  static const String orderDetails = '/profile/orders/details';

  static String outletDetailPath(String outletId) => '/outlet/$outletId';
  static String itemDetailPath(String outletId, String itemId) =>
      '/outlet/$outletId/item/$itemId';
}
