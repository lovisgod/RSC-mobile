import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/profile_model.dart';
import '../models/update_profile_request_model.dart';
import '../models/update_profile_response_model.dart';
import '../models/verify_profile_change_request_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile();
  Future<UpdateProfileResponseModel> updateProfile(
    UpdateProfileRequestModel request,
  );
  Future<ProfileModel> uploadAvatar(File imageFile);
  Future<ProfileModel> verifyProfileChange(
    VerifyProfileChangeRequestModel request,
  );
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final DioClient _client;

  const ProfileRemoteDataSourceImpl(this._client);

  @override
  Future<ProfileModel> getProfile() async {
    try {
      final response = await _client.dio.get(ApiConstants.userMe);
      return ProfileModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      // 401 handling (session expiry) is centralized in SessionInterceptor.
      throw _mapError(e);
    }
  }

  @override
  Future<UpdateProfileResponseModel> updateProfile(
    UpdateProfileRequestModel request,
  ) async {
    try {
      final response = await _client.dio.post(
        ApiConstants.userMe,
        data: request.toJson(),
      );
      return UpdateProfileResponseModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<ProfileModel> uploadAvatar(File imageFile) async {
    try {
      final extension = imageFile.path.split('.').last.toLowerCase();
      final subtype = extension == 'png' ? 'png' : 'jpeg';
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
          contentType: MediaType('image', subtype),
        ),
      });
      final response = await _client.dio.post(
        ApiConstants.uploadAvatar,
        data: formData,
      );
      return ProfileModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      // 401 handling (session expiry) is centralized in SessionInterceptor.
      throw _mapError(e);
    }
  }

  @override
  Future<ProfileModel> verifyProfileChange(
    VerifyProfileChangeRequestModel request,
  ) async {
    try {
      final response = await _client.dio.post(
        ApiConstants.verifyProfileChange,
        data: request.toJson(),
      );
      return ProfileModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      // This endpoint's 401 means "wrong/expired OTP", not session expiry —
      // it's excluded from SessionInterceptor, so it still needs its own
      // 401 mapping here.
      throw _mapError(e, unauthorizedMessage: AppStrings.invalidOrExpiredCode);
    }
  }

  Exception _mapError(DioException e, {String? unauthorizedMessage}) {
    final error = e.error;
    if (error is ServerException) {
      if (error.statusCode == 401 && unauthorizedMessage != null) {
        return AuthException(unauthorizedMessage);
      }
      return AuthException(error.message);
    }
    if (error is NetworkException) return AuthException(error.message);
    return const AuthException('Something went wrong. Please try again.');
  }
}
