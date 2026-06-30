import 'modifier.dart';

class ModifierGroup {
  final String id;
  final String menuItemId;
  final String name;
  final bool isRequired;
  final int minSelections;
  final int maxSelections;
  final int sortOrder;
  final String outletId;
  final List<Modifier> modifiers;

  const ModifierGroup({
    required this.id,
    required this.menuItemId,
    required this.name,
    required this.isRequired,
    required this.maxSelections,
    required this.modifiers,
    this.minSelections = 0,
    this.sortOrder = 0,
    this.outletId = '',
  });
}
