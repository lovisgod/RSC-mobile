abstract final class ApiConstants {
  static const String baseUrl = 'https://api.rsc.com/v1';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String verifyOtp = '/auth/verify-otp';
  static const String refreshToken = '/auth/refresh';

  // Menu
  static const String categories = '/menu/categories';
  static const String menuItems = '/menu/items';

  // Orders
  static const String orders = '/orders';
  static const String orderDetail = '/orders/{id}';

  // Profile
  static const String profile = '/profile';

  // Notifications
  static const String notifications = '/notifications';
  static const String registerFcmToken = '/notifications/fcm-token';
}
