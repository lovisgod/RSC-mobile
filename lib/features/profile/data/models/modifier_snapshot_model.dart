import '../../domain/entities/modifier_snapshot_entity.dart';

class ModifierSnapshotModel {
  final String id;
  final String name;
  final double priceDelta;

  const ModifierSnapshotModel({
    required this.id,
    required this.name,
    required this.priceDelta,
  });

  factory ModifierSnapshotModel.fromJson(Map<String, dynamic> json) {
    return ModifierSnapshotModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      priceDelta: ((json['priceDeltaMinor'] as num?) ?? 0) / 100,
    );
  }

  ModifierSnapshotEntity toEntity() =>
      ModifierSnapshotEntity(id: id, name: name, priceDelta: priceDelta);
}
