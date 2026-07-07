import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/di/injection.dart';
import 'core/services/notification_service.dart';
import 'firebase_options.dart';
import 'features/cart/data/datasources/cart_local_datasource.dart';
import 'features/cart/data/models/hive/cart_item_hive_model.dart';
import 'features/cart/data/models/hive/selected_modifier_hive_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('[RSC] Firebase initialized');
  } catch (e) {
    debugPrint('[RSC] Firebase init failed: $e');
  }

  await Hive.initFlutter();
  Hive.registerAdapter(CartItemHiveModelAdapter());
  Hive.registerAdapter(SelectedModifierHiveModelAdapter());
  await Hive.openBox<CartItemHiveModel>(cartBoxName);

  await configureDependencies();

  try {
    await getIt<NotificationService>().initialize();
  } catch (e) {
    debugPrint('[RSC] Notification service init failed: $e');
  }

  runApp(const App());
}
