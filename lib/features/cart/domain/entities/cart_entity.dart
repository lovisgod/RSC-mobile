import 'cart_item_entity.dart';

class CartEntity {
  final List<CartItemEntity> items;
  final double subtotal;
  final double vat;
  final double estimatedTotal;
  final int totalItemCount;

  const CartEntity({
    required this.items,
    required this.subtotal,
    required this.vat,
    required this.estimatedTotal,
    required this.totalItemCount,
  });

  factory CartEntity.empty() => const CartEntity(
        items: [],
        subtotal: 0,
        vat: 0,
        estimatedTotal: 0,
        totalItemCount: 0,
      );

  Map<String, List<CartItemEntity>> get itemsGroupedByOutlet {
    final grouped = <String, List<CartItemEntity>>{};
    for (final item in items) {
      (grouped[item.outletId] ??= []).add(item);
    }
    return grouped;
  }
}
