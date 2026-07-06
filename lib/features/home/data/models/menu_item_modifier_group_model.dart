/// Maps a single object from the outlet response's `menuItemModifierGroups`
/// array — the join table that links a menu item to its modifier groups.
///
/// Used internally by [OutletModel] to resolve which modifier groups belong to
/// a given menu item; not surfaced to the UI directly.
class MenuItemModifierGroupModel {
  final String menuItemId;
  final String groupId;
  final int sortOrder;

  const MenuItemModifierGroupModel({
    required this.menuItemId,
    required this.groupId,
    required this.sortOrder,
  });

  factory MenuItemModifierGroupModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModifierGroupModel(
      menuItemId: json['menuItemId'] as String? ?? '',
      groupId: json['groupId'] as String? ?? '',
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }
}
