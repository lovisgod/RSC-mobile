// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selected_modifier_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SelectedModifierHiveModelAdapter
    extends TypeAdapter<SelectedModifierHiveModel> {
  @override
  final int typeId = 1;

  @override
  SelectedModifierHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SelectedModifierHiveModel()
      ..modifierId = fields[0] as String
      ..name = fields[1] as String
      ..priceDelta = fields[2] as double;
  }

  @override
  void write(BinaryWriter writer, SelectedModifierHiveModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.modifierId)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.priceDelta);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SelectedModifierHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
