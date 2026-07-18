import '../../domain/entities/notification_preferences_entity.dart';

class NotificationPreferencesState {
  final NotificationPreferencesEntity? preferences;
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final String? successMessage;

  const NotificationPreferencesState({
    this.preferences,
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    this.successMessage,
  });

  NotificationPreferencesState copyWith({
    NotificationPreferencesEntity? preferences,
    bool? isLoading,
    bool? isSaving,
    String? error,
    bool clearError = false,
    String? successMessage,
    bool clearSuccessMessage = false,
  }) => NotificationPreferencesState(
    preferences: preferences ?? this.preferences,
    isLoading: isLoading ?? this.isLoading,
    isSaving: isSaving ?? this.isSaving,
    error: clearError ? null : (error ?? this.error),
    successMessage: clearSuccessMessage
        ? null
        : (successMessage ?? this.successMessage),
  );
}
