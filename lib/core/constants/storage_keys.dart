abstract final class StorageKeys {
  // ─── Cached user ──────────────────────────────────────────────────────────
  static const String userId = 'user_id';
  static const String userRole = 'user_role';

  // ─── Hive boxes ───────────────────────────────────────────────────────────
  static const String cartBox = 'cart_box';

  // ─── Pending rating prompts (one key per delivered order) ─────────────────
  static const String pendingRatingPrefix = 'pending_rating_';
}
