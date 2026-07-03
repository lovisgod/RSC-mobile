import 'modifier_snapshot_entity.dart';

class LineItemEntity {
  final String id;
  final String menuItemId;
  final String outletId;
  final String subOrderId;
  final String itemNameSnapshot;
  final double unitPrice;
  final int quantity;
  final double lineTotal;
  final List<ModifierSnapshotEntity> modifiers;

  const LineItemEntity({
    required this.id,
    required this.menuItemId,
    required this.outletId,
    required this.subOrderId,
    required this.itemNameSnapshot,
    required this.unitPrice,
    required this.quantity,
    required this.lineTotal,
    required this.modifiers,
  });
}
