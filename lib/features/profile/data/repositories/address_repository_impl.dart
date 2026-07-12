import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/delivery_address_entity.dart';
import '../../domain/repositories/address_repository.dart';
import '../models/create_address_request_model.dart';
import '../models/delivery_address_model.dart';

class AddressRepositoryImpl implements AddressRepository {
  final DioClient _client;

  const AddressRepositoryImpl(this._client);

  @override
  Future<List<DeliveryAddressEntity>> getAddresses() async {
    try {
      final response = await _client.dio.get(ApiConstants.deliveryAddresses);
      final data = response.data['data'] as List;
      return data
          .map(
            (json) =>
                DeliveryAddressModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<DeliveryAddressEntity> getAddressById(String id) async {
    try {
      final response = await _client.dio.get(
        ApiConstants.deliveryAddressById(id),
      );
      return DeliveryAddressModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<DeliveryAddressEntity> createAddress(
    CreateAddressRequestModel request,
  ) async {
    try {
      final response = await _client.dio.post(
        ApiConstants.deliveryAddresses,
        data: request.toJson(),
      );
      return DeliveryAddressModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<DeliveryAddressEntity> updateAddress(
    String id,
    CreateAddressRequestModel request,
  ) async {
    try {
      final response = await _client.dio.patch(
        ApiConstants.deliveryAddressById(id),
        data: request.toJson(),
      );
      return DeliveryAddressModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<bool> deleteAddress(String id) async {
    try {
      final response = await _client.dio.delete(
        ApiConstants.deliveryAddressById(id),
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return data['deleted'] as bool? ?? true;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<DeliveryAddressEntity> setDefaultAddress(String id) async {
    try {
      final response = await _client.dio.patch(
        ApiConstants.setDefaultAddressPath(id),
      );
      return DeliveryAddressModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Exception _mapError(DioException e) {
    final error = e.error;
    if (error is ServerException) {
      if (error.statusCode == 404) {
        return const AuthException('Address not found.');
      }
      // 401 handling (session expiry) is centralized in SessionInterceptor.
      return AuthException(error.message);
    }
    if (error is NetworkException) return AuthException(error.message);
    return const AuthException('Something went wrong. Please try again.');
  }
}
