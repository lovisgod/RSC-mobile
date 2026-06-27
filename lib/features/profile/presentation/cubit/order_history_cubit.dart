import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/mock/mock_user.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../../../cart/domain/entities/selected_modifier_entity.dart';
import '../../domain/entities/order_history_entity.dart';
import '../../domain/entities/order_history_line_item.dart';
import '../../domain/entities/order_history_sub_order.dart';
import 'order_history_state.dart';

class OrderHistoryCubit extends Cubit<OrderHistoryState> {
  OrderHistoryCubit() : super(const OrderHistoryState());

  void init() {
    final now = DateTime.now();
    emit(OrderHistoryState(orders: [
      _mockOrder1(now),
      _mockOrder2(now),
      _mockOrder3(now),
    ]));
  }

  void addInProgressOrder(OrderHistoryEntity order) {
    emit(state.copyWith(orders: [order, ...state.orders]));
  }

  void markOrderCompleted(String orderId) {
    final updated = state.orders
        .map((o) => o.orderId == orderId ? o.copyWith(isCompleted: true) : o)
        .toList();
    emit(state.copyWith(orders: updated));
  }

  // ── Seed helpers ────────────────────────────────────────────────────────────

  static OrderHistoryEntity _mockOrder1(DateTime now) => OrderHistoryEntity(
        orderId: 'RSC-45821093',
        deliveryCode: 'DEL-3297',
        placedAt: now.subtract(const Duration(days: 2)),
        deliveryMode: 'DELIVERY',
        deliveryAddress: MockUser.defaultAddress,
        subOrders: const [
          OrderHistorySubOrder(
            outletName: 'Cactus',
            outletEmoji: '🔥',
            items: [
              OrderHistoryLineItem(
                itemName: 'Suya Skewers',
                quantity: 1,
                unitPrice: 3300,
                selectedModifiers: ['Fried Plantain (Dodo)'],
              ),
            ],
          ),
        ],
        subtotal: 3300,
        deliveryFee: 500,
        vat: 248,
        grandTotal: 4048,
        isCompleted: true,
        cartItems: const [
          CartItemEntity(
            id: 'seed-cactus-suya-001',
            menuItemId: '1a2b3c4d-0001-0000-0000-000000000001',
            outletId: 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
            outletName: 'Cactus',
            outletEmoji: '🔥',
            itemNameSnapshot: 'Suya Skewers',
            itemImageUrl: '',
            unitPrice: 3300,
            basePrice: 2500,
            quantity: 1,
            selectedModifiers: [
              SelectedModifierEntity(
                modifierId: 'mod-side-plantain',
                name: 'Fried Plantain (Dodo)',
                priceDelta: 800,
              ),
            ],
          ),
        ],
      );

  static OrderHistoryEntity _mockOrder2(DateTime now) => OrderHistoryEntity(
        orderId: 'RSC-78234510',
        deliveryCode: 'DEL-5541',
        placedAt: now.subtract(const Duration(days: 5)),
        deliveryMode: 'TAKEOUT',
        deliveryAddress: '',
        subOrders: const [
          OrderHistorySubOrder(
            outletName: 'Salmas',
            outletEmoji: '🍜',
            items: [
              OrderHistoryLineItem(
                itemName: 'Steaming Bowl',
                quantity: 2,
                unitPrice: 2800,
                selectedModifiers: [],
              ),
            ],
          ),
        ],
        subtotal: 5600,
        deliveryFee: 0,
        vat: 420,
        grandTotal: 6020,
        isCompleted: true,
        cartItems: const [
          CartItemEntity(
            id: 'seed-salmas-bowl-001',
            menuItemId: 'seed-salmas-steaming-bowl',
            outletId: '550e8400-e29b-41d4-a716-446655440000',
            outletName: 'Salmas',
            outletEmoji: '🍜',
            itemNameSnapshot: 'Steaming Bowl',
            itemImageUrl: '',
            unitPrice: 2800,
            basePrice: 2800,
            quantity: 2,
            selectedModifiers: [],
          ),
        ],
      );

  static OrderHistoryEntity _mockOrder3(DateTime now) => OrderHistoryEntity(
        orderId: 'RSC-12904857',
        deliveryCode: 'DEL-8812',
        placedAt: now.subtract(const Duration(days: 7)),
        deliveryMode: 'DELIVERY',
        deliveryAddress: MockUser.defaultAddress,
        subOrders: const [
          OrderHistorySubOrder(
            outletName: 'Cactus',
            outletEmoji: '🔥',
            items: [
              OrderHistoryLineItem(
                itemName: 'Peppered Snails',
                quantity: 1,
                unitPrice: 3500,
                selectedModifiers: [],
              ),
              OrderHistoryLineItem(
                itemName: 'Spring Rolls (6pc)',
                quantity: 1,
                unitPrice: 2000,
                selectedModifiers: [],
              ),
            ],
          ),
        ],
        subtotal: 5500,
        deliveryFee: 500,
        vat: 413,
        grandTotal: 6413,
        isCompleted: true,
        cartItems: const [
          CartItemEntity(
            id: 'seed-cactus-snails-001',
            menuItemId: 'seed-cactus-peppered-snails',
            outletId: 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
            outletName: 'Cactus',
            outletEmoji: '🔥',
            itemNameSnapshot: 'Peppered Snails',
            itemImageUrl: '',
            unitPrice: 3500,
            basePrice: 3500,
            quantity: 1,
            selectedModifiers: [],
          ),
          CartItemEntity(
            id: 'seed-cactus-springrolls-001',
            menuItemId: 'seed-cactus-spring-rolls',
            outletId: 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
            outletName: 'Cactus',
            outletEmoji: '🔥',
            itemNameSnapshot: 'Spring Rolls (6pc)',
            itemImageUrl: '',
            unitPrice: 2000,
            basePrice: 2000,
            quantity: 1,
            selectedModifiers: [],
          ),
        ],
      );
}
