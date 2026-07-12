import '../../data/models/reorder_response_model.dart';
import '../entities/order_history_entity.dart';

abstract class OrderRepository {
  Future<List<OrderHistoryEntity>> getOrders();
  Future<OrderHistoryEntity> getOrderById(String id);

  /// Reorder details for a past order — current-menu item ids/quantities/
  /// modifiers plus the delivery address/coordinates used on that order.
  Future<ReorderResponseModel> getReorderDetails(String orderId);
}
