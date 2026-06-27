import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/change_password_request_model.dart';
import '../models/forgot_password_request_model.dart';
import '../models/forgot_password_response_model.dart';
import '../models/login_request_model.dart';
import '../models/login_response_model.dart';
import '../models/register_request_model.dart';
import '../models/register_response_model.dart';
import '../models/resend_otp_request_model.dart';
import '../models/resend_otp_response_model.dart';
import '../models/reset_password_request_model.dart';
import '../models/verify_otp_request_model.dart';
import '../models/verify_otp_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<RegisterResponseModel> register(RegisterRequestModel request);
  Future<VerifyOtpResponseModel> verifyOtp(VerifyOtpRequestModel request);
  Future<LoginResponseModel> login(LoginRequestModel request);
  Future<void> logout();
  Future<ForgotPasswordResponseModel> forgotPassword(
    ForgotPasswordRequestModel request,
  );
  Future<void> resetPassword(ResetPasswordRequestModel request);
  Future<void> changePassword(ChangePasswordRequestModel request);
  Future<ResendOtpResponseModel> resendVerificationCode(
    ResendOtpRequestModel request,
  );
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _client;

  const AuthRemoteDataSourceImpl(this._client);

  @override
  Future<RegisterResponseModel> register(RegisterRequestModel request) async {
    try {
      final response = await _client.dio.post(
        ApiConstants.register,
        data: request.toJson(),
      );
      return RegisterResponseModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<VerifyOtpResponseModel> verifyOtp(VerifyOtpRequestModel request) async {
    try {
      final response = await _client.dio.post(
        ApiConstants.verifyUser,
        data: request.toJson(),
      );
      return VerifyOtpResponseModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<LoginResponseModel> login(LoginRequestModel request) async {
    try {
      final response = await _client.dio.post(
        ApiConstants.login,
        data: request.toJson(),
      );
      return LoginResponseModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _client.dio.post(ApiConstants.logout);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<ForgotPasswordResponseModel> forgotPassword(
    ForgotPasswordRequestModel request,
  ) async {
    try {
      final response = await _client.dio.post(
        ApiConstants.forgotPassword,
        data: request.toJson(),
      );
      return ForgotPasswordResponseModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<void> resetPassword(ResetPasswordRequestModel request) async {
    try {
      await _client.dio.post(
        ApiConstants.resetPassword,
        data: request.toJson(),
      );
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<ResendOtpResponseModel> resendVerificationCode(
    ResendOtpRequestModel request,
  ) async {
    try {
      final response = await _client.dio.post(
        ApiConstants.resendVerificationCode,
        data: request.toJson(),
      );
      return ResendOtpResponseModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<void> changePassword(ChangePasswordRequestModel request) async {
    try {
      await _client.dio.post(
        ApiConstants.changePassword,
        data: request.toJson(),
      );
    } on DioException catch (e) {
      final error = e.error;
      if (error is ServerException && error.statusCode == 401) {
        final msg = error.message.toLowerCase();
        if (msg.contains('authentication') ||
            msg.contains('session') ||
            msg.contains('unauthorized')) {
          throw const AuthException('Session expired. Please log in again.');
        }
        throw const AuthException('Current password is incorrect.');
      }
      throw _mapError(e);
    }
  }

  Exception _mapError(DioException e) {
    final error = e.error;
    if (error is ServerException) return AuthException(error.message);
    if (error is NetworkException) return AuthException(error.message);
    return const AuthException('Something went wrong. Please try again.');
  }
}
