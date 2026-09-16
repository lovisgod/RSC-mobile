/// Maps a single object from the outlet response's `menuItemModifierGroups`
/// array — the join table that links a menu item to its modifier groups.
///
/// Used internally by [OutletModel] to resolve which modifier groups belong to
/// a given menu item; not surfaced to the UI directly.
class MenuItemModifierGroupModel {
  final String id;
  final String menuItemId;
  final String groupId;
  final int sortOrder;
  final DateTime? createdAt;

  const MenuItemModifierGroupModel({
    required this.id,
    required this.menuItemId,
    required this.groupId,
    required this.sortOrder,
    this.createdAt,
  });

  factory MenuItemModifierGroupModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModifierGroupModel(
      id: json['id'] as String? ?? '',
      menuItemId: json['menuItemId'] as String? ?? '',
      groupId: json['groupId'] as String? ?? '',
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
    );
  }
}
