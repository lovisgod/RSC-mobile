import '../../data/models/create_address_request_model.dart';
import '../entities/delivery_address_entity.dart';

abstract class AddressRepository {
  Future<List<DeliveryAddressEntity>> getAddresses();

  Future<DeliveryAddressEntity> getAddressById(String id);

  Future<DeliveryAddressEntity> createAddress(
    CreateAddressRequestModel request,
  );

  Future<DeliveryAddressEntity> updateAddress(
    String id,
    CreateAddressRequestModel request,
  );

  Future<bool> deleteAddress(String id);

  Future<DeliveryAddressEntity> setDefaultAddress(String id);
}
