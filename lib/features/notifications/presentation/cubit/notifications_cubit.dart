import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_notification_read_usecase.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit(this._getNotificationsUseCase, this._markAsReadUseCase)
    : super(const NotificationsState());

  final GetNotificationsUseCase _getNotificationsUseCase;
  final MarkNotificationReadUseCase _markAsReadUseCase;

  bool _hasLoadedOnce = false;

  Future<void> loadNotifications() async {
    emit(state.copyWith(isLoading: !_hasLoadedOnce, clearError: true));
    try {
      final notifications = await _getNotificationsUseCase();
      _hasLoadedOnce = true;
      emit(state.copyWith(notifications: notifications, isLoading: false));
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Failed to load notifications. Please try again.',
        ),
      );
    }
  }

  void markAsRead(String id) {
    final index = state.notifications.indexWhere((n) => n.id == id);
    if (index == -1 || state.notifications[index].isRead) return;

    final updated = [...state.notifications];
    updated[index] = updated[index].copyWith(isRead: true);
    emit(state.copyWith(notifications: updated));

    _markAsReadUseCase(id);
  }

  void markAllAsRead() {
    for (final notification in state.notifications) {
      if (!notification.isRead) {
        _markAsReadUseCase(notification.id);
      }
    }
    final updated = state.notifications
        .map((n) => n.copyWith(isRead: true))
        .toList();
    emit(state.copyWith(notifications: updated));
  }
}
