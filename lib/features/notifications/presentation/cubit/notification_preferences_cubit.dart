import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/notification_preferences_entity.dart';
import '../../domain/usecases/get_notification_preferences_usecase.dart';
import '../../domain/usecases/update_notification_preferences_usecase.dart';
import 'notification_preferences_state.dart';

class NotificationPreferencesCubit extends Cubit<NotificationPreferencesState> {
  NotificationPreferencesCubit(
    this._getPreferencesUseCase,
    this._updatePreferencesUseCase,
  ) : super(const NotificationPreferencesState());

  final GetNotificationPreferencesUseCase _getPreferencesUseCase;
  final UpdateNotificationPreferencesUseCase _updatePreferencesUseCase;

  Future<void> loadPreferences() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    final preferences = await _getPreferencesUseCase();
    emit(state.copyWith(preferences: preferences, isLoading: false));
  }

  Future<void> updatePreference(String key, bool value) async {
    final previous = state.preferences;
    if (previous == null) return;

    final optimistic = _applyKey(previous, key, value);
    emit(
      state.copyWith(preferences: optimistic, isSaving: true, clearError: true),
    );

    try {
      final updated = await _updatePreferencesUseCase(
        optimistic.promotions,
        optimistic.discounts,
        optimistic.seasonalOffers,
      );
      emit(
        state.copyWith(
          preferences: updated,
          isSaving: false,
          successMessage: 'Preferences updated',
        ),
      );
    } on AuthException catch (e) {
      emit(
        state.copyWith(
          preferences: previous,
          isSaving: false,
          error: e.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          preferences: previous,
          isSaving: false,
          error: 'Failed to update preferences. Please try again.',
        ),
      );
    }
  }

  NotificationPreferencesEntity _applyKey(
    NotificationPreferencesEntity preferences,
    String key,
    bool value,
  ) {
    switch (key) {
      case 'promotions':
        return preferences.copyWith(promotions: value);
      case 'discounts':
        return preferences.copyWith(discounts: value);
      case 'seasonalOffers':
        return preferences.copyWith(seasonalOffers: value);
      default:
        return preferences;
    }
  }
}
