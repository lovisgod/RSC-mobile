import '../entities/notification_entity.dart';
import '../entities/notification_preferences_entity.dart';

abstract class NotificationRepository {
  Future<List<NotificationEntity>> getNotifications();
  Future<void> markAsRead(String id);
  Future<NotificationPreferencesEntity> getPreferences();
  Future<NotificationPreferencesEntity> updatePreferences(
    bool promotions,
    bool discounts,
    bool seasonalOffers,
  );
}
