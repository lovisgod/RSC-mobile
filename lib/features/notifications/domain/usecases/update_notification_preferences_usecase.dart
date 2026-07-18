import '../entities/notification_preferences_entity.dart';
import '../repositories/notification_repository.dart';

class UpdateNotificationPreferencesUseCase {
  const UpdateNotificationPreferencesUseCase(this._repository);

  final NotificationRepository _repository;

  Future<NotificationPreferencesEntity> call(
    bool promotions,
    bool discounts,
    bool seasonalOffers,
  ) => _repository.updatePreferences(promotions, discounts, seasonalOffers);
}
