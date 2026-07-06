import '../../data/models/create_address_request_model.dart';
import '../entities/delivery_address_entity.dart';
import '../repositories/address_repository.dart';

class UpdateAddressUseCase {
  final AddressRepository _repository;

  const UpdateAddressUseCase(this._repository);

  Future<DeliveryAddressEntity> call(
    String id,
    CreateAddressRequestModel request,
  ) => _repository.updateAddress(id, request);
}
