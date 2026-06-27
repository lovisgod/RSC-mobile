abstract final class RouteNames {
  static const String home = '/';
  static const String auth = '/auth';
  static const String checkout = '/checkout';
  static const String outletDetail = '/outlet/:outletId';
  static const String itemDetail = '/outlet/:outletId/item/:itemId';
  static const String orderHistory = '/profile/orders';
  static const String orderDetails = '/profile/orders/details';

  static const String forgotPassword = '/forgot-password';
  static const String resetOtp = '/reset-otp';
  static const String newPassword = '/new-password';
  static const String changePassword = '/change-password';

  static String outletDetailPath(String outletId) => '/outlet/$outletId';
  static String itemDetailPath(String outletId, String itemId) =>
      '/outlet/$outletId/item/$itemId';
}
