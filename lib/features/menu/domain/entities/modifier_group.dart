import 'modifier.dart';

class ModifierGroup {
  final String id;
  final String menuItemId;
  final String name;
  final bool isRequired;
  final int maxSelections;
  final List<Modifier> modifiers;

  const ModifierGroup({
    required this.id,
    required this.menuItemId,
    required this.name,
    required this.isRequired,
    required this.maxSelections,
    required this.modifiers,
  });
}
