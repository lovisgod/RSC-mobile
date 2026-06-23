import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../constants/api_constants.dart';
import '../constants/storage_keys.dart';
import '../errors/exceptions.dart';

@lazySingleton
class DioClient {
  late final Dio _dio;

  DioClient(FlutterSecureStorage secureStorage) {
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
      _AuthInterceptor(secureStorage),
      _ErrorInterceptor(),
      if (kDebugMode) LogInterceptor(requestBody: true, responseBody: true),
    ]);
  }

  Dio get dio => _dio;
}

class _AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _secureStorage;

  _AuthInterceptor(this._secureStorage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _secureStorage.read(key: StorageKeys.accessToken);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        handler.next(
          err.copyWith(error: const NetworkException('Connection timed out')),
        );

      case DioExceptionType.connectionError:
        handler.next(
          err.copyWith(error: const NetworkException('No internet connection')),
        );

      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        final message = _extractMessage(err.response);
        if (statusCode == 401) {
          handler.next(err.copyWith(error: const UnauthorizedException()));
        } else if (statusCode == 404) {
          handler.next(err.copyWith(error: const NotFoundException()));
        } else {
          handler.next(
            err.copyWith(
              error: ServerException(message: message, statusCode: statusCode),
            ),
          );
        }

      default:
        handler.next(
          err.copyWith(
            error: ServerException(message: err.message ?? 'Unknown error'),
          ),
        );
    }
  }

  String _extractMessage(Response<dynamic>? response) {
    try {
      final data = response?.data;
      if (data is Map) return (data['message'] as String?) ?? 'Server error';
    } catch (_) {}
    return 'Server error';
  }
}
