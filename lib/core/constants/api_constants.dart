abstract final class ApiConstants {
  static const String baseUrl = 'https://api-dev.rscdev.tech';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Auth
  static const String register = '/api/v1/auth/register';
  static const String verifyUser = '/api/v1/auth/verify-user';
  static const String resendVerificationCode =
      '/api/v1/auth/resend-verification-code';
  static const String login = '/api/v1/auth/login';
  static const String logout = '/api/v1/auth/logout';
  static const String forgotPassword = '/api/v1/auth/forgot-password';
  static const String resetPassword = '/api/v1/auth/reset-password';
  static const String changePassword = '/api/v1/auth/change-password';

  // Outlets (public — outlets with their nested menu in one payload)
  static const String outlets = '/api/v1/outlets';

  // Menu
  static const String categories = '/api/v1/menu/categories';
  static const String menuItems = '/api/v1/menu/items';

  // Payments
  static const String initiatePayment = '/api/v1/payments/initiate';
  static const String platformCharges = '/api/v1/payments/platform-charges';
  static String verifyPayment(String reference) =>
      '/api/v1/payments/verify/$reference';

  /// `{orderId}` is substituted at call time (retry payment on an unpaid
  /// order).
  static const String retryPayment = '/api/v1/payments/orders/{orderId}/retry';

  /// `{reference}` is substituted at call time.
  static const String requestRefund =
      '/api/v1/payments/{reference}/refund-request';

  // Orders
  static const String orders = '/api/v1/orders';
  static String orderById(String id) => '/api/v1/orders/$id';
  static String reorderPath(String id) => '/api/v1/orders/$id/reorder';

  /// `{id}` is substituted at call time (REST fallback when the socket is
  /// down).
  static const String riderLocation = '/api/v1/orders/{id}/rider-location';

  // Menu item rating — `{id}` is substituted at call time.
  static const String rateMenuItem = '/api/v1/menu-items/{id}/rating';

  // Profile
  static const String profile = '/api/v1/profile';
  static const String userMe = '/api/v1/users/me';
  static const String uploadAvatar = '/api/v1/users/me/avatar';
  static const String deactivateAccount = '/api/v1/users/me/deactivate';
  static const String verifyProfileChange = '/api/v1/users/me/verify-change';

  // Delivery addresses
  static const String deliveryAddresses = '/api/v1/delivery/addresses';
  static String deliveryAddressById(String id) =>
      '/api/v1/delivery/addresses/$id';
  static String setDefaultAddressPath(String id) =>
      '/api/v1/delivery/addresses/$id/default';
  static const String validateAddress = '/api/v1/delivery/validate-address';
  static const String addressSuggestions =
      '/api/v1/delivery/address-suggestions';
  static const String resolveAddress = '/api/v1/delivery/resolve-address';

  // Preparation suggestions
  static const String preparationSuggestions =
      '/api/v1/preparation-suggestions';

  // Notifications
  static const String notifications = '/api/v1/notifications';
  static const String deviceToken = '/api/v1/notifications/device-token';
  static String markNotificationRead(String id) =>
      '/api/v1/notifications/$id/read';
  static const String notificationPreferences =
      '/api/v1/notifications/preferences';
}
