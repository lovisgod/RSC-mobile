import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/repositories/rating_repository.dart';
import '../models/rate_menu_item_request_model.dart';

class RatingRepositoryImpl implements RatingRepository {
  final DioClient _client;

  const RatingRepositoryImpl(this._client);

  @override
  Future<void> rateMenuItem(
    String menuItemId,
    int rating, {
    String? comment,
  }) async {
    try {
      await _client.dio.post(
        ApiConstants.rateMenuItem.replaceAll('{id}', menuItemId),
        data: RateMenuItemRequestModel(rating: rating, comment: comment)
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
