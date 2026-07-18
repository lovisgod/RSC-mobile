import 'reorder_modifier_model.dart';

class ReorderItemModel {
  final String menuItemId;
  final int quantity;
  final List<ReorderModifierModel> modifiers;
  final String? customerNote;

  const ReorderItemModel({
    required this.menuItemId,
    required this.quantity,
    required this.modifiers,
    this.customerNote,
  });

  factory ReorderItemModel.fromJson(Map<String, dynamic> json) {
    final rawModifiers = json['modifiers'];
    return ReorderItemModel(
      menuItemId: json['menuItemId'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      modifiers: rawModifiers is List
          ? rawModifiers
                .whereType<Map<String, dynamic>>()
                .map(ReorderModifierModel.fromJson)
                .toList()
          : const [],
      customerNote: json['customerNote'] as String?,
    );
  }
}
