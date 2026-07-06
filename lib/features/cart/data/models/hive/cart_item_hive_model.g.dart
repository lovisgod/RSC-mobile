// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_item_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CartItemHiveModelAdapter extends TypeAdapter<CartItemHiveModel> {
  @override
  final int typeId = 0;

  @override
  CartItemHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CartItemHiveModel()
      ..id = fields[0] as String
      ..menuItemId = fields[1] as String
      ..outletId = fields[2] as String
      ..outletName = fields[3] as String
      ..outletEmoji = fields[4] as String
      ..itemNameSnapshot = fields[5] as String
      ..unitPrice = fields[6] as double
      ..basePrice = fields[7] as double
      ..quantity = fields[8] as int
      ..selectedModifiers =
          (fields[9] as List).cast<SelectedModifierHiveModel>()
      ..itemImageUrl = fields[10] as String;
  }

  @override
  void write(BinaryWriter writer, CartItemHiveModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.menuItemId)
      ..writeByte(2)
      ..write(obj.outletId)
      ..writeByte(3)
      ..write(obj.outletName)
      ..writeByte(4)
      ..write(obj.outletEmoji)
      ..writeByte(5)
      ..write(obj.itemNameSnapshot)
      ..writeByte(6)
      ..write(obj.unitPrice)
      ..writeByte(7)
      ..write(obj.basePrice)
      ..writeByte(8)
      ..write(obj.quantity)
      ..writeByte(9)
      ..write(obj.selectedModifiers)
      ..writeByte(10)
      ..write(obj.itemImageUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItemHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
