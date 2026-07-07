import '../entities/notification_preferences_entity.dart';
import '../repositories/notification_repository.dart';

class GetNotificationPreferencesUseCase {
  const GetNotificationPreferencesUseCase(this._repository);

  final NotificationRepository _repository;

  Future<NotificationPreferencesEntity> call() => _repository.getPreferences();
}
