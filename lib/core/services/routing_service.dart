import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/route_result.dart';
import '../utils/map_utils.dart';

// Google Directions API. Kept on a plain Dio instance separate from the
// app's DioClient so the customer's session cookie is never sent to a
// third-party host. The API key lives in the gitignored .env files.
class RoutingService {
  RoutingService() : _dio = Dio(BaseOptions(baseUrl: _baseUrl));

  static const String _baseUrl = 'https://maps.googleapis.com';

  final Dio _dio;

  Future<RouteResult?> getRoute(
    double fromLat,
    double fromLng,
    double toLat,
    double toLng,
  ) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/maps/api/directions/json',
        queryParameters: {
          'origin': '$fromLat,$fromLng',
          'destination': '$toLat,$toLng',
          'mode': 'driving',
          'key': dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '',
        },
      );

      final routes = response.data?['routes'] as List<dynamic>?;
      if (routes == null || routes.isEmpty) return null;

      final route = routes.first as Map<String, dynamic>;
      final leg =
          (route['legs'] as List<dynamic>).first as Map<String, dynamic>;
      final encodedPolyline =
          (route['overview_polyline'] as Map<String, dynamic>)['points']
              as String;

      return RouteResult(
        points: MapUtils.decodePolyline(encodedPolyline),
        distanceMeters: ((leg['distance'] as Map<String, dynamic>)['value']
                as num)
            .toDouble(),
        durationSeconds: ((leg['duration'] as Map<String, dynamic>)['value']
                as num)
            .toDouble(),
      );
    } catch (e) {
      debugPrint('[RSC Routing] Failed to fetch Google Directions route: $e');
      return null;
    }
  }
}
