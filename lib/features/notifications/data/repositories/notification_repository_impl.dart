import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/entities/notification_preferences_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../models/notification_model.dart';
import '../models/notification_preferences_model.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  const NotificationRepositoryImpl(this._client);

  final DioClient _client;

  @override
  Future<List<NotificationEntity>> getNotifications() async {
    try {
      final response = await _client.dio.get(ApiConstants.notifications);
      final data = response.data['data'] as List? ?? [];
      final notifications = data
          .whereType<Map<String, dynamic>>()
          .map((json) => NotificationModel.fromJson(json).toEntity())
          .toList();
      notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return notifications;
    } on DioException catch (e) {
      if (e.error is ServerException &&
          (e.error as ServerException).statusCode == 401) {
        throw AuthException(AppStrings.sessionExpiredLogin);
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> markAsRead(String id) async {
    try {
      await _client.dio.patch(ApiConstants.markNotificationRead(id));
    } catch (e) {
      debugPrint('[RSC] Failed to mark notification $id as read: $e');
    }
  }

  @override
  Future<NotificationPreferencesEntity> getPreferences() async {
    try {
      final response = await _client.dio.get(
        ApiConstants.notificationPreferences,
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return NotificationPreferencesModel.fromJson(data).toEntity();
    } catch (_) {
      return const NotificationPreferencesEntity.defaults();
    }
  }

  @override
  Future<NotificationPreferencesEntity> updatePreferences(
    bool promotions,
    bool discounts,
    bool seasonalOffers,
  ) async {
    try {
      final response = await _client.dio.patch(
        ApiConstants.notificationPreferences,
        data: NotificationPreferencesModel(
          promotions: promotions,
          discounts: discounts,
          seasonalOffers: seasonalOffers,
        ).toJson(),
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return NotificationPreferencesModel.fromJson(data).toEntity();
    } on DioException catch (e) {
      final error = e.error;
      final message = error is ServerException
          ? error.message
          : 'Failed to update notification preferences. Please try again.';
      throw AuthException(message);
    }
  }
}
