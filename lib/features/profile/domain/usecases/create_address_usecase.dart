import '../../data/models/create_address_request_model.dart';
import '../entities/delivery_address_entity.dart';
import '../repositories/address_repository.dart';

class CreateAddressUseCase {
  final AddressRepository _repository;

  const CreateAddressUseCase(this._repository);

  Future<DeliveryAddressEntity> call(CreateAddressRequestModel request) =>
      _repository.createAddress(request);
}
