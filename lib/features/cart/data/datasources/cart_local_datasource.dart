import 'package:hive/hive.dart';

import '../../domain/entities/cart_item_entity.dart';
import '../../domain/entities/selected_modifier_entity.dart';
import '../models/hive/cart_item_hive_model.dart';
import '../models/hive/selected_modifier_hive_model.dart';

const String cartBoxName = 'cart_box';

/// Persists the cart to disk via Hive so it survives app restarts. Keyed by
/// cart item id — one Hive entry per cart item, not a single serialized blob.
class CartLocalDatasource {
  const CartLocalDatasource(this._box);

  final Box<CartItemHiveModel> _box;

  List<CartItemEntity> loadCart() {
    return _box.values
        .map(
          (hive) => CartItemEntity(
            id: hive.id,
            menuItemId: hive.menuItemId,
            outletId: hive.outletId,
            outletName: hive.outletName,
            outletEmoji: hive.outletEmoji,
            itemNameSnapshot: hive.itemNameSnapshot,
            itemImageUrl: hive.itemImageUrl,
            unitPrice: hive.unitPrice,
            basePrice: hive.basePrice,
            quantity: hive.quantity,
            selectedModifiers: hive.selectedModifiers
                .map(
                  (m) => SelectedModifierEntity(
                    modifierId: m.modifierId,
                    name: m.name,
                    priceDelta: m.priceDelta,
                  ),
                )
                .toList(),
          ),
        )
        .toList();
  }

  Future<void> saveCart(List<CartItemEntity> items) async {
    await _box.clear();
    for (final item in items) {
      final hiveItem = CartItemHiveModel()
        ..id = item.id
        ..menuItemId = item.menuItemId
        ..outletId = item.outletId
        ..outletName = item.outletName
        ..outletEmoji = item.outletEmoji
        ..itemNameSnapshot = item.itemNameSnapshot
        ..itemImageUrl = item.itemImageUrl
        ..unitPrice = item.unitPrice
        ..basePrice = item.basePrice
        ..quantity = item.quantity
        ..selectedModifiers = item.selectedModifiers
            .map(
              (m) => SelectedModifierHiveModel()
                ..modifierId = m.modifierId
                ..name = m.name
                ..priceDelta = m.priceDelta,
            )
            .toList();
      await _box.put(item.id, hiveItem);
    }
  }

  Future<void> clearCart() => _box.clear();
}
