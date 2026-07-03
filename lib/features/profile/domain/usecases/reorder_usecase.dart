import 'package:collection/collection.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../../../cart/domain/entities/selected_modifier_entity.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../home/domain/repositories/home_repository.dart';
import '../../../menu/domain/entities/menu_item.dart';
import '../entities/order_history_entity.dart';

/// Rebuilds the cart from a past order's line items, ready for the user to
/// review on the Cart tab before checking out again.
class ReorderUseCase {
  const ReorderUseCase(this._cartCubit, this._homeRepository);

  final CartCubit _cartCubit;
  final HomeRepository _homeRepository;

  static const _fallbackEmoji = '🍽️';

  Future<void> call(OrderHistoryEntity order) async {
    _cartCubit.clearCart();

    final outlets = await _homeRepository.getOutlets();

    final outletIds = order.lineItems.map((l) => l.outletId).toSet();
    final itemsByOutlet = <String, List<MenuItem>>{
      for (final outletId in outletIds)
        outletId: await _homeRepository.getItemsForOutlet(outletId),
    };

    for (final lineItem in order.lineItems) {
      final outletName =
          outlets.firstWhereOrNull((o) => o.id == lineItem.outletId)?.name ??
          AppStrings.kitchenFallbackName;
      final imageUrl = itemsByOutlet[lineItem.outletId]
          ?.firstWhereOrNull((i) => i.id == lineItem.menuItemId)
          ?.imageUrl;

      _cartCubit.addItem(
        CartItemEntity(
          id: CartCubit.generateId(),
          menuItemId: lineItem.menuItemId,
          outletId: lineItem.outletId,
          outletName: outletName,
          outletEmoji: _fallbackEmoji,
          itemNameSnapshot: lineItem.itemNameSnapshot,
          itemImageUrl: imageUrl ?? '',
          // Modifiers are already baked into the snapshot price from the
          // original order, so unitPrice and basePrice are the same value.
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
  }
}
