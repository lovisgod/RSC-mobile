import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../track/data/models/rider_location_model.dart';
import '../../../track/domain/entities/rider_location_entity.dart';
import '../../domain/entities/order_history_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../models/order_detail_model.dart';
import '../models/order_summary_model.dart';
import '../models/reorder_response_model.dart';

class OrderRepositoryImpl implements OrderRepository {
  final DioClient _client;

  const OrderRepositoryImpl(this._client);

  @override
  Future<List<OrderHistoryEntity>> getOrders() async {
    try {
      final response = await _client.dio.get(ApiConstants.orders);
      // Confirmed shape: { "data": { "orders": [...], "total": n, ... } }.
      // Pagination fields (limit/offset/hasNext/hasPrevious) are ignored
      // for now — the first page is enough for the current UI.
      final dataMap = response.data['data'] as Map<String, dynamic>? ?? {};
      final list = dataMap['orders'] as List? ?? [];
      final total = (dataMap['total'] as num?)?.toInt() ?? 0;
      debugPrint('[RSC Orders] Total orders: $total (showing ${list.length})');

      final orders = list
          .whereType<Map<String, dynamic>>()
          .map((json) => OrderSummaryModel.fromJson(json).toEntity())
          .toList();
      debugPrint('[RSC Orders] Parsed ${orders.length} orders');
      debugPrint(
        '[RSC Orders] Active orders: '
        '${orders.where((o) => o.isActive).length}',
      );
      return orders;
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

  @override
  Future<ReorderResponseModel> getReorderDetails(String orderId) async {
    try {
      final response = await _client.dio.get(ApiConstants.reorderPath(orderId));
      final data = response.data['data'] as Map<String, dynamic>;
      return ReorderResponseModel.fromJson(data);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<RiderLocationEntity?> getRiderLocation(String orderId) async {
    try {
      final response = await _client.dio.get(
        ApiConstants.riderLocation.replaceAll('{id}', orderId),
      );
      final data = response.data['data'] as Map<String, dynamic>?;
      if (data == null) return null;
      return RiderLocationModel.fromJson(data).toEntity();
    } catch (_) {
      // 404 = no rider assigned yet; any other failure is swallowed too —
      // the next poll tick simply tries again.
      return null;
    }
  }

  Exception _mapError(DioException e) {
    final error = e.error;
    // 401 handling (session expiry) is centralized in SessionInterceptor.
    if (error is ServerException) return AuthException(error.message);
    if (error is NetworkException) return AuthException(error.message);
    return const AuthException('Something went wrong. Please try again.');
  }
}
