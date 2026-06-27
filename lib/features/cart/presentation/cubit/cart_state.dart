import '../../domain/entities/cart_entity.dart';

class CartState {
  final CartEntity cart;
  final String? lastAddedItemName;

  const CartState({
    required this.cart,
    this.lastAddedItemName,
  });

  CartState copyWith({
    CartEntity? cart,
    String? lastAddedItemName,
    bool clearLastAdded = false,
  }) =>
      CartState(
        cart: cart ?? this.cart,
        lastAddedItemName:
            clearLastAdded ? null : (lastAddedItemName ?? this.lastAddedItemName),
      );
}
