import 'dart:developer' as developer;

import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/repositories/payment_repository.dart';
import '../models/initiate_payment_request_model.dart';
import '../models/initiate_payment_response_model.dart';
import '../models/platform_charges_model.dart';
import '../models/retry_payment_response_model.dart';
import '../models/verify_payment_response_model.dart';
import '../../domain/entities/platform_charges_entity.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  const PaymentRepositoryImpl(this._client);

  final DioClient _client;

  /// Deep link Moment redirects to after a retried checkout completes.
  static const String _returnUrl = 'rsc://payment/return';

  @override
  Future<InitiatePaymentResponseModel> initiatePayment(
    InitiatePaymentRequestModel request,
  ) async {
    final body = request.toJson();
    // Validation-phase logging of the full outgoing payload.
    developer.log(
      'POST ${ApiConstants.initiatePayment} request: $body',
      name: 'PaymentRepository',
    );

    try {
      final response = await _client.dio.post(
        ApiConstants.initiatePayment,
        data: body,
      );

      developer.log(
        'initiatePayment response (${response.statusCode}): ${response.data}',
        name: 'PaymentRepository',
      );

      final data =
          (response.data as Map<String, dynamic>)['data']
              as Map<String, dynamic>;
      return InitiatePaymentResponseModel.fromJson(data);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<PlatformChargesEntity> getPlatformCharges() async {
    try {
      final response = await _client.dio.get(ApiConstants.platformCharges);

      developer.log(
        'getPlatformCharges response (${response.statusCode}): ${response.data}',
        name: 'PaymentRepository',
      );

      return PlatformChargesModel.fromJson(
        response.data as Map<String, dynamic>,
      ).toEntity();
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<VerifyPaymentResponseModel> verifyPayment(String reference) async {
    try {
      final response = await _client.dio.get(
        ApiConstants.verifyPayment(reference),
      );

      developer.log(
        'verifyPayment response (${response.statusCode}): ${response.data}',
        name: 'PaymentRepository',
      );

      final data =
          (response.data as Map<String, dynamic>)['data']
              as Map<String, dynamic>;
      return VerifyPaymentResponseModel.fromJson(data);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<RetryPaymentResponseModel> retryPayment(String orderId) async {
    final path = ApiConstants.retryPayment.replaceAll('{orderId}', orderId);
    try {
      final response = await _client.dio.post(
        path,
        data: {'returnUrl': _returnUrl},
      );

      developer.log(
        'retryPayment response (${response.statusCode}): ${response.data}',
        name: 'PaymentRepository',
      );

      final data =
          (response.data as Map<String, dynamic>)['data']
              as Map<String, dynamic>;
      return RetryPaymentResponseModel.fromJson(data);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Exception _mapError(DioException e) {
    final error = e.error;
    if (error is ServerException) {
      // The DioClient interceptor already extracted errors[0]/message.
      // 401 handling (session expiry) is centralized in SessionInterceptor.
      return AuthException(error.message);
    }
    if (error is NetworkException) return AuthException(error.message);
    return const AuthException(AppStrings.paymentFailed);
  }
}
