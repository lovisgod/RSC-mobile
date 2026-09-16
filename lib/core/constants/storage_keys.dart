abstract final class StorageKeys {
  // ─── Cached user ──────────────────────────────────────────────────────────
  static const String userId = 'user_id';
  static const String userRole = 'user_role';

  // ─── Hive boxes ───────────────────────────────────────────────────────────
  static const String cartBox = 'cart_box';

  // ─── Favorites ────────────────────────────────────────────────────────────
  static const String favoriteMenuItems = 'favorite_menu_items';

  // ─── Pending rating prompts (one key per delivered order) ─────────────────
  static const String pendingRatingPrefix = 'pending_rating_';

  // ─── Notification-driven refresh fallback ─────────────────────────────────
  static const String pendingOrderNotificationRefresh =
      'pending_order_notification_refresh';
}
