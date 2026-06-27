import '../../../../core/di/injection.dart';
import '../../../cart/domain/entities/cart_entity.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';

class ReorderUseCase {
  const ReorderUseCase();

  CartEntity call(List<CartItemEntity> cartItems) {
    final cartCubit = getIt<CartCubit>();
    cartCubit.clearCart();
    for (final item in cartItems) {
      cartCubit.addItem(item);
    }
    return cartCubit.state.cart;
  }
}
