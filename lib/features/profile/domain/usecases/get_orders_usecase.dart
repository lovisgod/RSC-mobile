import '../entities/order_history_entity.dart';
import '../repositories/order_repository.dart';

class GetOrdersUseCase {
  const GetOrdersUseCase(this._repository);

  final OrderRepository _repository;

  Future<List<OrderHistoryEntity>> call() => _repository.getOrders();
}
