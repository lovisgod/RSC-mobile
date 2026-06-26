import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';

import '../constants/api_constants.dart';
import '../errors/exceptions.dart';

class DioClient {
  late final Dio _dio;
  final PersistCookieJar cookieJar;

  DioClient(this.cookieJar) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout: ApiConstants.sendTimeout,
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      CookieManager(cookieJar),
      _ErrorInterceptor(),
      if (kDebugMode) LogInterceptor(requestBody: true, responseBody: true),
    ]);
  }

  Dio get dio => _dio;
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
        handler.next(err.copyWith(
          error: const NetworkException(
            'Connection timed out. Check your internet.',
          ),
        ));

      case DioExceptionType.receiveTimeout:
        handler.next(err.copyWith(
          error: const NetworkException(
            'Server took too long to respond.',
          ),
        ));

      case DioExceptionType.connectionError:
        handler.next(err.copyWith(
          error: const NetworkException('No internet connection.'),
        ));

      case DioExceptionType.badResponse:
        final status = err.response?.statusCode;
        switch (status) {
          case 502:
            handler.next(err.copyWith(
              error: const ServerException(
                message: 'Could not send verification code. Please try again.',
                statusCode: 502,
              ),
            ));
          case 401:
            final msg = _extractFirstError(err.response);
            handler.next(err.copyWith(
              error: ServerException(message: msg, statusCode: 401),
            ));
          case 409:
            final msg = _extractFirstError(err.response);
            handler.next(err.copyWith(
              error: ServerException(message: msg, statusCode: 409),
            ));
          default:
            final msg = _extractFirstError(err.response);
            handler.next(err.copyWith(
              error: ServerException(
                message: msg,
                statusCode: status,
              ),
            ));
        }

      default:
        handler.next(err.copyWith(
          error: const ServerException(
            message: 'Something went wrong. Please try again.',
          ),
        ));
    }
  }

  String _extractFirstError(Response<dynamic>? response) {
    try {
      final body = response?.data;
      if (body is Map) {
        final data = body['data'];
        if (data is Map) {
          final errors = data['errors'];
          if (errors is List && errors.isNotEmpty) {
            return errors.first.toString();
          }
        }
        final message = body['message'];
        if (message is String && message.isNotEmpty) return message;
      }
    } catch (_) {}
    return 'Something went wrong. Please try again.';
  }
}
