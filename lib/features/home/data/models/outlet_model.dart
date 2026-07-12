import '../../../menu/domain/entities/menu_item.dart';
import '../../../menu/domain/entities/modifier.dart';
import '../../../menu/domain/entities/modifier_group.dart';
import '../../../menu/domain/entities/outlet.dart';
import 'item_modifier_model.dart';
import 'menu_category_model.dart';
import 'menu_item_model.dart';
import 'menu_item_modifier_group_model.dart';
import 'modifier_group_model.dart';

/// Maps a single outlet object from `GET /api/v1/outlets`, including all of its
/// nested menu arrays. The flat arrays are stitched back together (items →
/// modifier groups → modifiers, via the join table) when building domain
/// entities so the existing UI keeps working off `MenuItem.modifierGroups`.
class OutletModel {
  final String id;
  final String name;
  final String description;
  final String cuisineType;
  final String? imageUrl;
  final bool isOnline;

  final double ratingAverage;
  final int ratingCount;
  final double? deliveryRadiusKm;
  final double? latitude;
  final double? longitude;
  final String? paystackSubaccountCode;

  final List<MenuCategoryModel> categories;
  final List<MenuItemModel> items;
  final List<ModifierGroupModel> modifierGroups;
  final List<ItemModifierModel> modifiers;
  final List<MenuItemModifierGroupModel> itemModifierMappings;

  // ── Placeholder values (not yet provided by the outlets API) ──────────────
  // TODO: Backend needs to add deliveryFee to the outlets API response —
  // using a hardcoded placeholder until then.
  static const double _placeholderDeliveryFee = 500.0;

  OutletModel({
    required this.id,
    required this.name,
    required this.description,
    required this.cuisineType,
    required this.imageUrl,
    required this.isOnline,
    required this.ratingAverage,
    required this.ratingCount,
    this.deliveryRadiusKm,
    this.latitude,
    this.longitude,
    this.paystackSubaccountCode,
    required this.categories,
    required this.items,
    required this.modifierGroups,
    required this.modifiers,
    required this.itemModifierMappings,
  });

  factory OutletModel.fromJson(Map<String, dynamic> json) {
    List<T> parseList<T>(String key, T Function(Map<String, dynamic>) fromJson) {
      final raw = json[key];
      if (raw is! List) return const [];
      return raw
          .whereType<Map<String, dynamic>>()
          .map(fromJson)
          .toList(growable: false);
    }

    return OutletModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      cuisineType: json['cuisineType'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      isOnline: json['isOnline'] as bool? ?? false,
      ratingAverage:
          double.tryParse(json['ratingAverage'] as String? ?? '0') ?? 0.0,
      ratingCount: json['ratingCount'] as int? ?? 0,
      deliveryRadiusKm: (json['deliveryRadiusKm'] as num?)?.toDouble(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      paystackSubaccountCode: json['paystackSubaccountCode'] as String?,
      categories: parseList('menuCategories', MenuCategoryModel.fromJson),
      items: parseList('menuItems', MenuItemModel.fromJson),
      modifierGroups: parseList('itemModifierGroups', ModifierGroupModel.fromJson),
      modifiers: parseList('itemModifiers', ItemModifierModel.fromJson),
      itemModifierMappings:
          parseList('menuItemModifierGroups', MenuItemModifierGroupModel.fromJson),
    );
  }

  /// [isFeatured] is decided by the caller (true for the first outlet only).
  Outlet toEntity({bool isFeatured = false}) => Outlet(
        id: id,
        name: name,
        description: description,
        cuisineType: cuisineType,
        imageUrl: imageUrl ?? '',
        isOnline: isOnline,
        ratingAverage: ratingAverage,
        ratingCount: ratingCount,
        deliveryRadiusKm: deliveryRadiusKm,
        latitude: latitude,
        longitude: longitude,
        deliveryTimeRange: _computeDeliveryTimeRange(),
        minOrder: _placeholderDeliveryFee,
        isFeatured: isFeatured,
      );

  /// Aggregates each menu item's `deliveryTimeRange` ("15", "35-40", ...)
  /// into a single outlet-level range: the minimum lower bound and maximum
  /// upper bound across all items that have one. Null if none do.
  String? _computeDeliveryTimeRange() {
    final ranges = items
        .where(
          (i) =>
              i.deliveryTimeRange != null && i.deliveryTimeRange!.isNotEmpty,
        )
        .map((i) => i.deliveryTimeRange!)
        .toList();

    if (ranges.isEmpty) return null;

    var minVal = 999;
    var maxVal = 0;

    for (final range in ranges) {
      final parts = range.split('-');
      if (parts.length == 1) {
        final val = int.tryParse(parts[0].trim()) ?? 0;
        if (val < minVal) minVal = val;
        if (val > maxVal) maxVal = val;
      } else if (parts.length == 2) {
        final lo = int.tryParse(parts[0].trim()) ?? 0;
        final hi = int.tryParse(parts[1].trim()) ?? 0;
        if (lo < minVal) minVal = lo;
        if (hi > maxVal) maxVal = hi;
      }
    }

    if (minVal == maxVal) return '$minVal min';
    return '$minVal-$maxVal min';
  }

  // ── Menu assembly ─────────────────────────────────────────────────────────

  List<MenuCategoryModel> get sortedCategories =>
      [...categories]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

  /// All menu items as domain entities, each with its modifier groups attached,
  /// sorted by `sortOrder`.
  List<MenuItem> buildMenuItems() {
    final groupsByItem = _groupsByItemId();
    final result = [
      for (final item in items)
        item.toEntity(modifierGroups: groupsByItem[item.id] ?? const []),
    ]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return result;
  }

  /// Items belonging to [categoryId], with modifier groups attached, sorted.
  List<MenuItem> itemsForCategory(String categoryId) =>
      buildMenuItems().where((i) => i.categoryId == categoryId).toList();

  /// Modifier groups (with their modifiers) for a single menu item, resolved
  /// through the `menuItemModifierGroups` join table.
  List<ModifierGroup> modifierGroupsForItem(String menuItemId) =>
      _groupsByItemId()[menuItemId] ?? const [];

  // ── Internal join helpers ───────────────────────────────────────────────────

  Map<String, List<ModifierGroup>>? _groupsByItemCache;

  Map<String, List<ModifierGroup>> _groupsByItemId() {
    final cached = _groupsByItemCache;
    if (cached != null) return cached;

    // Modifiers grouped by their parent group, sorted.
    final modsByGroup = <String, List<Modifier>>{};
    for (final m in modifiers) {
      (modsByGroup[m.groupId] ??= []).add(m.toEntity());
    }
    for (final list in modsByGroup.values) {
      list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    }

    final groupModelById = {for (final g in modifierGroups) g.id: g};

    // Join-table rows grouped by menu item, sorted.
    final mappingsByItem = <String, List<MenuItemModifierGroupModel>>{};
    for (final map in itemModifierMappings) {
      (mappingsByItem[map.menuItemId] ??= []).add(map);
    }

    final result = <String, List<ModifierGroup>>{};
    mappingsByItem.forEach((menuItemId, maps) {
      maps.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      final groups = <ModifierGroup>[];
      for (final map in maps) {
        final groupModel = groupModelById[map.groupId];
        if (groupModel == null) continue;
        groups.add(groupModel.toEntity(
          menuItemId: menuItemId,
          modifiers: modsByGroup[groupModel.id] ?? const [],
        ));
      }
      result[menuItemId] = groups;
    });

    return _groupsByItemCache = result;
  }
}
