import '../../../menu/domain/entities/modifier.dart';
import '../../../menu/domain/entities/modifier_group.dart';

/// Maps a single object from the outlet response's `itemModifierGroups` array.
///
/// A group is linked to menu items through the `menuItemModifierGroups` join
/// table, so [toEntity] takes the owning `menuItemId` and the resolved
/// [Modifier] list when assembling a per-item view.
class ModifierGroupModel {
  final String id;
  final String outletId;
  final String name;
  final int minSelections;
  final int maxSelections;
  final bool isRequired;
  final int sortOrder;

  const ModifierGroupModel({
    required this.id,
    required this.outletId,
    required this.name,
    required this.minSelections,
    required this.maxSelections,
    required this.isRequired,
    required this.sortOrder,
  });

  factory ModifierGroupModel.fromJson(Map<String, dynamic> json) {
    return ModifierGroupModel(
      id: json['id'] as String? ?? '',
      outletId: json['outletId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      minSelections: (json['minSelections'] as num?)?.toInt() ?? 0,
      maxSelections: (json['maxSelections'] as num?)?.toInt() ?? 1,
      isRequired: json['isRequired'] as bool? ?? false,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }

  ModifierGroup toEntity({
    required String menuItemId,
    List<Modifier> modifiers = const [],
  }) =>
      ModifierGroup(
        id: id,
        menuItemId: menuItemId,
        name: name,
        isRequired: isRequired,
        minSelections: minSelections,
        maxSelections: maxSelections,
        sortOrder: sortOrder,
        outletId: outletId,
        modifiers: modifiers,
      );
}
