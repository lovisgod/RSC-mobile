import '../entities/delivery_address_entity.dart';
import '../repositories/address_repository.dart';

class GetAddressesUseCase {
  final AddressRepository _repository;

  const GetAddressesUseCase(this._repository);

  Future<List<DeliveryAddressEntity>> call() => _repository.getAddresses();
}
