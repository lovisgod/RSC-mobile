import '../../data/models/reorder_response_model.dart';
import '../repositories/order_repository.dart';

class GetReorderDetailsUsecase {
  const GetReorderDetailsUsecase(this._repository);

  final OrderRepository _repository;

  Future<ReorderResponseModel> call(String orderId) =>
      _repository.getReorderDetails(orderId);
}
