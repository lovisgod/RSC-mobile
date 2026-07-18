import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/repositories/refund_repository.dart';
import '../models/refund_request_model.dart';

class RefundRepositoryImpl implements RefundRepository {
  final DioClient _client;

  const RefundRepositoryImpl(this._client);

  @override
  Future<void> requestRefund(
    String reference,
    int amountMinor,
    String reason,
  ) async {
    try {
      await _client.dio.post(
        ApiConstants.requestRefund.replaceAll('{reference}', reference),
        data: RefundRequestModel(amountMinor: amountMinor, reason: reason)
            .toJson(),
      );
    } on DioException catch (e) {
      throw _mapError(e);
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
