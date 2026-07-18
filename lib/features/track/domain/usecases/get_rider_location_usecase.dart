import '../../../profile/domain/repositories/order_repository.dart';
import '../entities/rider_location_entity.dart';

class GetRiderLocationUsecase {
  const GetRiderLocationUsecase(this._repository);

  final OrderRepository _repository;

  /// Null when no rider is assigned yet or the request fails — polling
  /// callers just skip that tick.
  Future<RiderLocationEntity?> call(String orderId) =>
      _repository.getRiderLocation(orderId);
}
