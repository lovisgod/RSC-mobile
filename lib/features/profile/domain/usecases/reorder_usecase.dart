import '../../../../core/constants/app_strings.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../../../cart/domain/entities/selected_modifier_entity.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../home/domain/repositories/home_repository.dart';
import '../../../menu/domain/entities/menu_item.dart';
import '../../../menu/domain/entities/outlet.dart';
import '../../data/models/reorder_response_model.dart';
import 'get_reorder_details_usecase.dart';

/// Rebuilds the cart from a past order via the dedicated reorder endpoint,
/// which returns current menu-item ids/quantities/modifiers plus the
/// delivery address/coordinates used on that order — ready for the user to
/// review on the Cart tab, and for the caller to pre-fill checkout with.
class ReorderUseCase {
  const ReorderUseCase(
    this._getReorderDetailsUsecase,
    this._cartCubit,
    this._homeRepository,
  );

  final GetReorderDetailsUsecase _getReorderDetailsUsecase;
  final CartCubit _cartCubit;
  final HomeRepository _homeRepository;

  // No shared, public emoji-lookup exists in the domain layer (the home/item
  // screens each keep their own private, outlet-id-keyed map) — this matches
  // what the previous version of this usecase already did.
  static const _fallbackEmoji = '🍽️';

  Future<ReorderResponseModel> call(String orderId) async {
    final reorderData = await _getReorderDetailsUsecase(orderId);

    _cartCubit.clearCart();

    // The reorder response only carries menuItemId — no outletId — so every
    // outlet's current menu has to be indexed by item id to resolve one.
    final itemIndex = await _buildMenuItemIndex();

    for (final reorderItem in reorderData.items) {
      final match = itemIndex[reorderItem.menuItemId];
      final outlet = match?.outlet;
      final menuItem = match?.item;

      _cartCubit.addItem(
        CartItemEntity(
          id: CartCubit.generateId(),
          menuItemId: reorderItem.menuItemId,
          outletId: outlet?.id ?? '',
          outletName: outlet?.name ?? AppStrings.kitchenFallbackName,
          outletEmoji: _fallbackEmoji,
          itemNameSnapshot: menuItem?.name ?? AppStrings.itemFallbackName,
          itemImageUrl: menuItem?.imageUrl ?? '',
          // Modifiers only carry an id in the reorder response (no price),
          // so unitPrice is just the item's current base price for now.
          unitPrice: menuItem?.price ?? 0.0,
          basePrice: menuItem?.price ?? 0.0,
          quantity: reorderItem.quantity,
          selectedModifiers: reorderItem.modifiers
              .map(
                (m) => SelectedModifierEntity(
                  modifierId: m.modifierId,
                  name: '',
                  priceDelta: 0.0,
                ),
              )
              .toList(),
        ),
      );
    }

    return reorderData;
  }

  Future<Map<String, ({Outlet outlet, MenuItem item})>>
  _buildMenuItemIndex() async {
    final outlets = await _homeRepository.getOutlets();
    final index = <String, ({Outlet outlet, MenuItem item})>{};
    for (final outlet in outlets) {
      final items = await _homeRepository.getItemsForOutlet(outlet.id);
      for (final item in items) {
        index[item.id] = (outlet: outlet, item: item);
      }
    }
    return index;
  }
}
