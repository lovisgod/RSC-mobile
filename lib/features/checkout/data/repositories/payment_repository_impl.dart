import 'dart:developer' as developer;

import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/repositories/payment_repository.dart';
import '../models/initiate_payment_request_model.dart';
import '../models/initiate_payment_response_model.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  const PaymentRepositoryImpl(this._client);

  final DioClient _client;

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

      final data = (response.data as Map<String, dynamic>)['data']
          as Map<String, dynamic>;
      return InitiatePaymentResponseModel.fromJson(data);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Exception _mapError(DioException e) {
    final error = e.error;
    if (error is ServerException) {
      if (error.statusCode == 401) {
        return const AuthException(AppStrings.sessionExpiredLogin);
      }
      // The DioClient interceptor already extracted errors[0]/message.
      return AuthException(error.message);
    }
    if (error is NetworkException) return AuthException(error.message);
    return const AuthException(AppStrings.paymentFailed);
  }
}
