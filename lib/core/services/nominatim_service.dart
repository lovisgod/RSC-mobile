import 'package:dio/dio.dart';

import '../models/nominatim_result.dart';

/// Address autocomplete backed by the free OpenStreetMap Nominatim API.
/// No API key required, but usage is rate-limited to 1 request/second by
/// Nominatim's policy — callers are expected to debounce (handled in
/// [CheckoutCubit], not here).
class NominatimService {
  NominatimService() : _dio = Dio();

  final Dio _dio;

  static const String _baseUrl = 'https://nominatim.openstreetmap.org';

  // RSC delivery zone bounding box (Ikoyi, VI, Banana Island, Lekki up to
  // Chevron). Restricts results to addresses we can actually deliver to.
  static const double _minLat = 6.3800;
  static const double _maxLat = 6.5500;
  static const double _minLng = 3.3500;
  static const double _maxLng = 3.6500;

  Future<List<NominatimResult>> searchAddress(String query) async {
    if (query.trim().length < 3) return [];

    try {
      final response = await _dio.get(
        '$_baseUrl/search',
        queryParameters: {
          'q': '$query Lagos Nigeria',
          'format': 'json',
          'limit': 5,
          'countrycodes': 'ng',
          'viewbox': '$_minLng,$_maxLat,$_maxLng,$_minLat',
          'bounded': 1,
          'addressdetails': 1,
          'accept-language': 'en',
        },
        options: Options(
          headers: {
            // Required by Nominatim's usage policy — never remove.
            'User-Agent': 'RSCFoodApp/1.0',
            'Referer': 'https://rscapp.xyz',
          },
        ),
      );

      final data = response.data;
      if (data is! List) return [];

      return data
          .whereType<Map<String, dynamic>>()
          .map(NominatimResult.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }
}
