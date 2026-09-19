import '../../../menu/domain/entities/modifier.dart';

/// Maps a single object from the outlet response's `itemModifiers` array.
///
/// `priceDeltaMinor` is converted to a major-unit [priceDelta] here in the
/// model layer — never in the UI.
class ItemModifierModel {
  final String id;
  final String outletId;
  final String groupId;
  final String name;
  final double priceDelta;
  final String currency;
  final bool isAvailable;
  final int sortOrder;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  const ItemModifierModel({
    required this.id,
    required this.outletId,
    required this.groupId,
    required this.name,
    required this.priceDelta,
    required this.currency,
    required this.isAvailable,
    required this.sortOrder,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory ItemModifierModel.fromJson(Map<String, dynamic> json) {
    return ItemModifierModel(
      id: json['id'] as String? ?? '',
      outletId: json['outletId'] as String? ?? '',
      groupId: json['groupId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      priceDelta: ((json['priceDeltaMinor'] as num?)?.toDouble() ?? 0) / 100,
      currency: json['currency'] as String? ?? 'NGN',
      isAvailable: json['isAvailable'] as bool? ?? true,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? ''),
      deletedAt: DateTime.tryParse(json['deletedAt'] as String? ?? ''),
    );
  }

  Modifier toEntity() => Modifier(
    id: id,
    groupId: groupId,
    name: name,
    priceDelta: priceDelta,
    isAvailable: isAvailable,
    sortOrder: sortOrder,
    outletId: outletId,
  );
}
