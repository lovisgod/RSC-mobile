abstract final class ApiConstants {
  static const String baseUrl = 'https://api-dev.rscdev.tech';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Auth
  static const String register = '/api/v1/auth/register';
  static const String verifyUser = '/api/v1/auth/verify-user';
  static const String login = '/api/v1/auth/login';
  static const String logout = '/api/v1/auth/logout';

  // Menu
  static const String categories = '/api/v1/menu/categories';
  static const String menuItems = '/api/v1/menu/items';

  // Orders
  static const String orders = '/api/v1/orders';

  // Profile
  static const String profile = '/api/v1/profile';

  // Notifications
  static const String notifications = '/api/v1/notifications';
  static const String registerFcmToken = '/api/v1/notifications/fcm-token';
}
