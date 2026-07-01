/// Deterministic food-emoji placeholders for menu items that have no image.
///
/// The same item name always maps to the same emoji, so an item looks
/// consistent across the home, outlet-detail, search, and item-detail screens.
abstract final class PlaceholderImageUtil {
  static const List<String> _foodEmojis = [
    '🍽️',
    '🍲',
    '🥘',
    '🍛',
    '🍜',
    '🥗',
    '🍝',
    '🍕',
    '🍔',
    '🥙',
  ];

  /// Returns a stable emoji for [itemName] derived from a simple deterministic
  /// hash, so the same name always yields the same emoji.
  static String getPlaceholderEmoji(String itemName) {
    if (itemName.isEmpty) return _foodEmojis.first;

    // FNV-1a style rolling hash — deterministic across runs/platforms.
    var hash = 0;
    for (final codeUnit in itemName.codeUnits) {
      hash = (hash * 31 + codeUnit) & 0x7fffffff;
    }
    return _foodEmojis[hash % _foodEmojis.length];
  }
}
