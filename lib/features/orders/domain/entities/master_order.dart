import 'sub_order.dart';

class MasterOrder {
  final String id;
  final String userId;
  // PENDING | CONFIRMED | PREPARING | READY | DISPATCHED | DELIVERED | CANCELLED
  final String status;
  final double totalAmount;
  final double deliveryFee;
  final String deliveryAddress;
  final String createdAt; // ISO 8601
  final List<SubOrder> subOrders;

  const MasterOrder({
    required this.id,
    required this.userId,
    required this.status,
    required this.totalAmount,
    required this.deliveryFee,
    required this.deliveryAddress,
    required this.createdAt,
    required this.subOrders,
  });
}
