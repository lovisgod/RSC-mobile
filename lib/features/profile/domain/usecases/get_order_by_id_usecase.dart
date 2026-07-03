import '../entities/order_history_entity.dart';
import '../repositories/order_repository.dart';

class GetOrderByIdUseCase {
  const GetOrderByIdUseCase(this._repository);

  final OrderRepository _repository;

  Future<OrderHistoryEntity> call(String orderId) =>
      _repository.getOrderById(orderId);
}
