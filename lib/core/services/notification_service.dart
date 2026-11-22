import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../firebase_options.dart';
import '../constants/api_constants.dart';
import '../constants/storage_keys.dart';
import '../di/injection.dart';
import '../network/dio_client.dart';
import '../router/app_router.dart';
import '../storage/local_storage.dart';
import '../../features/shell/presentation/bloc/shell_bloc.dart';
import '../../features/shell/presentation/bloc/shell_event.dart';
import '../../features/track/presentation/cubit/track_cubit.dart';

const String _ordersChannelId = 'rsc_orders';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('[RSC] Background message: ${message.messageId}');
  final orderId = _orderIdFromData(message.data);
  if (_isOrderNotification(message.data)) {
    const storage = FlutterSecureStorage();
    await storage.write(
      key: StorageKeys.pendingOrderNotificationRefresh,
      value: orderId ?? '',
    );
  }
}

class NotificationService {
  NotificationService(this._client, this._localStorage);

  final DioClient _client;
  final LocalStorage _localStorage;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint(
      '[RSC] Notification permission status: ${settings.authorizationStatus}',
    );

    await _setupLocalNotifications();

    final token = await _fcm.getToken();
    if (token != null) {
      debugPrint('[RSC] FCM Token: $token');
      await _saveTokenToBackend(token);
    }

    _fcm.onTokenRefresh.listen(_saveTokenToBackend);

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await refreshTrackedOrderIfPendingNotification();
  }

  /// Re-registers the current FCM token with the backend. Called after a
  /// successful login so the token is always saved under a valid session.
  Future<void> refreshAndSaveToken() async {
    final token = await _fcm.getToken();
    if (token != null) {
      await _saveTokenToBackend(token);
    }
  }

  Future<void> _saveTokenToBackend(String token) async {
    // The device-token endpoint requires a session — a guest POST would 401
    // and trip the SessionInterceptor. Token is registered after login via
    // [refreshAndSaveToken] instead.
    final userId = await _localStorage.getUserId();
    if (userId == null) {
      debugPrint('[RSC] Skipping FCM token save — user not logged in');
      return;
    }

    try {
      final response = await _client.dio.post(
        ApiConstants.deviceToken,
        data: {'token': token},
      );
      if (response.statusCode == 201) {
        debugPrint('[RSC] FCM token registered with backend');
      }
    } catch (e) {
      debugPrint('[RSC] Failed to save FCM token: $e');
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    await _refreshTrackedOrderForNotification(message);

    final notification = message.notification;
    if (notification == null) return;
    final orderId = _orderIdFromData(message.data);

    await _localNotifications.show(
      message.hashCode,
      notification.title ?? '',
      notification.body ?? '',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _ordersChannelId,
          'Order Updates',
          channelDescription: 'Notifications about your Dineout NG orders',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
      ),
      payload: _isOrderNotification(message.data)
          ? 'order:${orderId ?? ''}'
          : null,
    );
  }

  Future<void> _handleNotificationTap(RemoteMessage message) async {
    final data = message.data;
    if (_isOrderNotification(data)) {
      getIt<ShellBloc>().add(const ShellTabChanged(3));
      appRouter.go('/');
      await _refreshTrackedOrderForNotification(message);
    } else {
      appRouter.go('/');
    }
  }

  Future<void> refreshTrackedOrderIfPendingNotification() async {
    final orderId = await _localStorage.takePendingOrderNotificationRefresh();
    if (orderId == null) return;
    await _refreshTrackedOrder(orderId.isEmpty ? null : orderId);
  }

  Future<void> _refreshTrackedOrderForNotification(
    RemoteMessage message,
  ) async {
    final data = message.data;
    if (!_isOrderNotification(data)) return;
    await _refreshTrackedOrder(_orderIdFromData(data));
  }

  Future<void> _refreshTrackedOrder(String? orderId) async {
    try {
      await getIt<TrackCubit>().refreshFromOrderNotification(orderId: orderId);
    } catch (e) {
      debugPrint('[RSC] Order notification refresh failed: $e');
    }
  }

  Future<void> _setupLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload == null || !payload.startsWith('order:')) return;
        final orderId = payload.substring('order:'.length);
        getIt<ShellBloc>().add(const ShellTabChanged(3));
        appRouter.go('/');
        _refreshTrackedOrder(orderId.isEmpty ? null : orderId);
      },
    );

    const channel = AndroidNotificationChannel(
      _ordersChannelId,
      'Order Updates',
      description: 'Notifications about your Dineout NG orders',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }
}

bool _isOrderNotification(Map<String, dynamic> data) {
  final type = data['type']?.toString().toLowerCase();
  return _orderIdFromData(data) != null || (type?.contains('order') ?? false);
}

String? _orderIdFromData(Map<String, dynamic> data) {
  final orderId = data['orderId'] ?? data['masterOrderId'];
  if (orderId == null) return null;
  final value = orderId.toString();
  return value.isEmpty ? null : value;
}
