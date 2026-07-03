import 'package:collection/collection.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../cart/domain/entities/cart_entity.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../../../cart/domain/entities/selected_modifier_entity.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../home/domain/repositories/home_repository.dart';
import '../entities/order_history_entity.dart';

class ReorderUseCase {
  const ReorderUseCase();

  Future<CartEntity> call(OrderHistoryEntity order) async {
    final cartCubit = getIt<CartCubit>();
    final outlets = await getIt<HomeRepository>().getOutlets();

    cartCubit.clearCart();
    for (final lineItem in order.lineItems) {
      final outletName =
          outlets.firstWhereOrNull((o) => o.id == lineItem.outletId)?.name ??
          AppStrings.kitchenFallbackName;

      cartCubit.addItem(
        CartItemEntity(
          id: CartCubit.generateId(),
          menuItemId: lineItem.menuItemId,
          outletId: lineItem.outletId,
          outletName: outletName,
          outletEmoji: '',
          itemNameSnapshot: lineItem.itemNameSnapshot,
          itemImageUrl: '',
          unitPrice: lineItem.unitPrice,
          basePrice: lineItem.unitPrice,
          quantity: lineItem.quantity,
          selectedModifiers: lineItem.modifiers
              .map(
                (m) => SelectedModifierEntity(
                  modifierId: m.id,
                  name: m.name,
                  priceDelta: m.priceDelta,
                ),
              )
              .toList(),
        ),
      );
    }
    return cartCubit.state.cart;
  }
}
