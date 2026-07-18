import '../../domain/entities/line_item_entity.dart';
import 'modifier_snapshot_model.dart';

class LineItemModel {
  final String id;
  final String masterOrderId;
  final String subOrderId;
  final String outletId;
  final String menuItemId;
  final String itemNameSnapshot;
  final double unitPrice;
  final int quantity;
  final double lineTotal;
  final String? customerNote;
  final List<ModifierSnapshotModel> modifiersSnapshot;

  const LineItemModel({
    required this.id,
    required this.masterOrderId,
    required this.subOrderId,
    required this.outletId,
    required this.menuItemId,
    required this.itemNameSnapshot,
    required this.unitPrice,
    required this.quantity,
    required this.lineTotal,
    this.customerNote,
    required this.modifiersSnapshot,
  });

  factory LineItemModel.fromJson(Map<String, dynamic> json) {
    return LineItemModel(
      id: json['id'] as String? ?? '',
      masterOrderId: json['masterOrderId'] as String? ?? '',
      subOrderId: json['subOrderId'] as String? ?? '',
      outletId: json['outletId'] as String? ?? '',
      menuItemId: json['menuItemId'] as String? ?? '',
      itemNameSnapshot: json['itemNameSnapshot'] as String? ?? '',
      unitPrice: ((json['unitPriceMinor'] as num?) ?? 0) / 100,
      quantity: json['quantity'] as int? ?? 0,
      lineTotal: ((json['lineTotalMinor'] as num?) ?? 0) / 100,
      customerNote: json['customerNote'] as String?,
      modifiersSnapshot: ((json['modifiersSnapshot'] as List?) ?? [])
          .whereType<Map<String, dynamic>>()
          .map(ModifierSnapshotModel.fromJson)
          .toList(),
    );
  }

  LineItemEntity toEntity() => LineItemEntity(
    id: id,
    menuItemId: menuItemId,
    outletId: outletId,
    subOrderId: subOrderId,
    itemNameSnapshot: itemNameSnapshot,
    unitPrice: unitPrice,
    quantity: quantity,
    lineTotal: lineTotal,
    customerNote: customerNote,
    modifiers: modifiersSnapshot.map((m) => m.toEntity()).toList(),
  );
}
