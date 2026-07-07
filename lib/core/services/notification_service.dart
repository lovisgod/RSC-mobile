import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../firebase_options.dart';
import '../constants/api_constants.dart';
import '../di/injection.dart';
import '../network/dio_client.dart';
import '../router/app_router.dart';
import '../../features/shell/presentation/bloc/shell_bloc.dart';
import '../../features/shell/presentation/bloc/shell_event.dart';

const String _ordersChannelId = 'rsc_orders';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('[RSC] Background message: ${message.messageId}');
}

class NotificationService {
  NotificationService(this._client);

  final DioClient _client;
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
  }

  Future<void> _saveTokenToBackend(String token) async {
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
    final notification = message.notification;
    if (notification == null) return;

    await _localNotifications.show(
      message.hashCode,
      notification.title ?? '',
      notification.body ?? '',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _ordersChannelId,
          'Order Updates',
          channelDescription: 'Notifications about your RSC food orders',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
      ),
    );
  }

  void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;
    if (data.containsKey('orderId') || data['type'] == 'order_update') {
      getIt<ShellBloc>().add(const ShellTabChanged(3));
      appRouter.go('/');
    } else {
      appRouter.go('/');
    }
  }

  Future<void> _setupLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _localNotifications.initialize(initSettings);

    const channel = AndroidNotificationChannel(
      _ordersChannelId,
      'Order Updates',
      description: 'Notifications about your RSC food orders',
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
