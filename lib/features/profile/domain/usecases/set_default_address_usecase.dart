import '../entities/delivery_address_entity.dart';
import '../repositories/address_repository.dart';

class SetDefaultAddressUseCase {
  final AddressRepository _repository;

  const SetDefaultAddressUseCase(this._repository);

  Future<DeliveryAddressEntity> call(String id) =>
      _repository.setDefaultAddress(id);
}
