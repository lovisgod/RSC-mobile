import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/cart_entity.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/entities/selected_modifier_entity.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(CartState(cart: CartEntity.empty()));

  void addItem(CartItemEntity item) {
    final items = List<CartItemEntity>.from(state.cart.items);
    final idx = items.indexWhere(
      (e) =>
          e.menuItemId == item.menuItemId &&
          _modifiersMatch(e.selectedModifiers, item.selectedModifiers),
    );

    if (idx >= 0) {
      items[idx] = items[idx].copyWith(quantity: items[idx].quantity + item.quantity);
    } else {
      items.add(item);
    }

    emit(CartState(
      cart: _buildCart(items),
      lastAddedItemName: item.itemNameSnapshot,
    ));
  }

  void removeItem(String cartItemId) {
    final items = state.cart.items.where((e) => e.id != cartItemId).toList();
    emit(CartState(cart: _buildCart(items)));
  }

  void incrementQuantity(String cartItemId) {
    final items = state.cart.items.map((e) {
      return e.id == cartItemId ? e.copyWith(quantity: e.quantity + 1) : e;
    }).toList();
    emit(CartState(cart: _buildCart(items)));
  }

  void decrementQuantity(String cartItemId) {
    final existing = state.cart.items.firstWhere((e) => e.id == cartItemId);
    if (existing.quantity <= 1) {
      removeItem(cartItemId);
      return;
    }
    final items = state.cart.items.map((e) {
      return e.id == cartItemId ? e.copyWith(quantity: e.quantity - 1) : e;
    }).toList();
    emit(CartState(cart: _buildCart(items)));
  }

  void updateItem(
    String cartItemId, {
    required int quantity,
    required List<SelectedModifierEntity> selectedModifiers,
    required double unitPrice,
  }) {
    final items = state.cart.items.map((e) {
      return e.id == cartItemId
          ? e.copyWith(
              quantity: quantity,
              selectedModifiers: selectedModifiers,
              unitPrice: unitPrice,
            )
          : e;
    }).toList();
    emit(CartState(cart: _buildCart(items)));
  }

  void clearCart() => emit(CartState(cart: CartEntity.empty()));

  // ── Private helpers ────────────────────────────────────────────────────────

  static CartEntity _buildCart(List<CartItemEntity> items) {
    final subtotal =
        items.fold(0.0, (sum, item) => sum + item.unitPrice * item.quantity);
    final vat = subtotal * AppConstants.vatRate;
    return CartEntity(
      items: items,
      subtotal: subtotal,
      vat: vat,
      estimatedTotal: subtotal + vat,
      totalItemCount: items.fold(0, (sum, item) => sum + item.quantity),
    );
  }

  static bool _modifiersMatch(
    List<SelectedModifierEntity> a,
    List<SelectedModifierEntity> b,
  ) {
    if (a.length != b.length) return false;
    final aIds = a.map((m) => m.modifierId).toSet();
    final bIds = b.map((m) => m.modifierId).toSet();
    return aIds.length == bIds.length && aIds.containsAll(bIds);
  }

  static String generateId() {
    final rand = Random.secure();
    final bytes = List<int>.generate(16, (_) => rand.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex =
        bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-'
        '${hex.substring(20)}';
  }
}
