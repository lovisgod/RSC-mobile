import '../entities/order_history_entity.dart';

abstract class OrderRepository {
  Future<List<OrderHistoryEntity>> getOrders();
  Future<OrderHistoryEntity> getOrderById(String id);
}
