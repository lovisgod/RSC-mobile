import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/order_history_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../models/order_detail_model.dart';
import '../models/order_summary_model.dart';

class OrderRepositoryImpl implements OrderRepository {
  final DioClient _client;

  const OrderRepositoryImpl(this._client);

  @override
  Future<List<OrderHistoryEntity>> getOrders() async {
    try {
      final response = await _client.dio.get(ApiConstants.orders);
      final data = response.data['data'] as List? ?? [];
      return data
          .whereType<Map<String, dynamic>>()
          .map((json) => OrderSummaryModel.fromJson(json).toEntity())
          .toList();
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<OrderHistoryEntity> getOrderById(String id) async {
    try {
      final response = await _client.dio.get(ApiConstants.orderById(id));
      final data = response.data['data'] as Map<String, dynamic>;
      return OrderDetailModel.fromJson(data).toEntity();
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Exception _mapError(DioException e) {
    final error = e.error;
    if (error is ServerException) {
      if (error.statusCode == 401) {
        return AuthException(AppStrings.sessionExpiredLogin);
      }
      return AuthException(error.message);
    }
    if (error is NetworkException) return AuthException(error.message);
    return const AuthException('Something went wrong. Please try again.');
  }
}
