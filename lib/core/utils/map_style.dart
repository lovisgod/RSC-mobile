import 'package:flutter/services.dart' show rootBundle;

// Loaded once and cached — every GoogleMap on screen shares the same
// dark, brand-tinted style instead of stock daytime Google Maps colors.
abstract final class MapStyle {
  static String? _cached;

  static Future<String> dark() async =>
      _cached ??= await rootBundle.loadString(
        'assets/map_style/dark_style.json',
      );
}
