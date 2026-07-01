import '../repositories/address_repository.dart';

class DeleteAddressUseCase {
  final AddressRepository _repository;

  const DeleteAddressUseCase(this._repository);

  Future<bool> call(String id) => _repository.deleteAddress(id);
}
