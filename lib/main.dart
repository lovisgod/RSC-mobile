import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/di/injection.dart';
import 'features/cart/data/datasources/cart_local_datasource.dart';
import 'features/cart/data/models/hive/cart_item_hive_model.dart';
import 'features/cart/data/models/hive/selected_modifier_hive_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(CartItemHiveModelAdapter());
  Hive.registerAdapter(SelectedModifierHiveModelAdapter());
  await Hive.openBox<CartItemHiveModel>(cartBoxName);

  await configureDependencies();
  runApp(const App());
}
