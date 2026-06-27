import '../../../cart/domain/entities/cart_item_entity.dart';
import 'order_history_sub_order.dart';

class OrderHistoryEntity {
  final String orderId;
  final String deliveryCode;
  final DateTime placedAt;
  final String deliveryMode; // 'DELIVERY' | 'TAKEOUT'
  final String deliveryAddress;
  final List<OrderHistorySubOrder> subOrders;
  final double subtotal;
  final double deliveryFee;
  final double vat;
  final double grandTotal;
  final bool isCompleted;
  final List<CartItemEntity> cartItems;

  const OrderHistoryEntity({
    required this.orderId,
    required this.deliveryCode,
    required this.placedAt,
    required this.deliveryMode,
    required this.deliveryAddress,
    required this.subOrders,
    required this.subtotal,
    required this.deliveryFee,
    required this.vat,
    required this.grandTotal,
    required this.isCompleted,
    required this.cartItems,
  });

  OrderHistoryEntity copyWith({bool? isCompleted}) => OrderHistoryEntity(
        orderId: orderId,
        deliveryCode: deliveryCode,
        placedAt: placedAt,
        deliveryMode: deliveryMode,
        deliveryAddress: deliveryAddress,
        subOrders: subOrders,
        subtotal: subtotal,
        deliveryFee: deliveryFee,
        vat: vat,
        grandTotal: grandTotal,
        isCompleted: isCompleted ?? this.isCompleted,
        cartItems: cartItems,
      );
}
