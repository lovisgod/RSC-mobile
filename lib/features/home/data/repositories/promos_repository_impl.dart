import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/promo_offer.dart';
import '../../domain/repositories/promos_repository.dart';
import '../models/promo_offer_model.dart';

class PromosRepositoryImpl implements PromosRepository {
  PromosRepositoryImpl(this._dioClient);

  final DioClient _dioClient;

  @override
  Future<List<PromoOffer>> getActivePromos() async {
    try {
      final response = await _dioClient.dio.get<dynamic>(ApiConstants.promos);
      final data = (response.data as Map<String, dynamic>?)?['data'];
      if (data is! List) return const [];
      return data
          .whereType<Map<String, dynamic>>()
          .map((json) => PromoOfferModel.fromJson(json).toEntity())
          .toList(growable: false);
    } on DioException catch (e) {
      final mapped = e.error;
      if (mapped is Exception) throw mapped;
      throw const ServerException(
        message: 'Could not load promos. Please try again.',
      );
    }
  }
}
