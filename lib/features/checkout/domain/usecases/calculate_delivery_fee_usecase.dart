import 'dart:math';

import 'package:collection/collection.dart';

import '../../../menu/domain/entities/outlet.dart';

/// Mirrors the backend's per-outlet delivery-fee formula
/// (POST /api/v1/payments/initiate strict validation). The backend now
/// rejects orders whose `deliveryFeeMinor` doesn't match this exact
/// calculation, so this must stay byte-for-byte consistent with it.
///
/// For a multi-outlet cart, the fee for each unique outlet is summed.
class CalculateDeliveryFeeUseCase {
  const CalculateDeliveryFeeUseCase();

  static const String _modelFlat = 'FLAT';
  static const String _modelPerKm = 'PER_KM';
  static const String _modelPerLocation = 'PER_LOCATION';

  /// Fallback flat fee (in minor units) when an outlet has no
  /// `deliveryFeeMinor` set at all.
  static const int _flatFallbackMinor = 150000;

  static const double _earthRadiusKm = 6371.0;

  /// [outletIds] are the unique outlets present in the cart. [zoneId] and
  /// [zoneName] come from the backend's validate-address response and are
  /// used to match `PER_LOCATION` overrides — zoneId first, then a
  /// case-insensitive locationName match.
  int call({
    required Set<String> outletIds,
    required List<Outlet> outlets,
    double? deliveryLatitude,
    double? deliveryLongitude,
    String? zoneId,
    String? zoneName,
  }) {
    final outletsById = {for (final outlet in outlets) outlet.id: outlet};

    var totalMinor = 0;
    for (final outletId in outletIds) {
      final outlet = outletsById[outletId];
      if (outlet == null) continue;
      totalMinor += _feeForOutlet(
        outlet,
        deliveryLatitude: deliveryLatitude,
        deliveryLongitude: deliveryLongitude,
        zoneId: zoneId,
        zoneName: zoneName,
      );
    }
    return totalMinor;
  }

  int _feeForOutlet(
    Outlet outlet, {
    double? deliveryLatitude,
    double? deliveryLongitude,
    String? zoneId,
    String? zoneName,
  }) {
    switch (outlet.deliveryPricingModel) {
      case _modelPerKm:
        return _perKmFee(outlet, deliveryLatitude, deliveryLongitude);
      case _modelPerLocation:
        return _perLocationFee(outlet, zoneId, zoneName);
      case _modelFlat:
      default:
        return outlet.deliveryFeeMinor > 0
            ? outlet.deliveryFeeMinor
            : _flatFallbackMinor;
    }
  }

  int _perKmFee(Outlet outlet, double? lat, double? lng) {
    final baseFeeMinor = outlet.deliveryBaseFeeMinor ?? 0;
    final pricePerKmMinor = outlet.deliveryPricePerKmMinor ?? 0;

    // Can't compute a distance-based fee without both ends of the route —
    // fall back to the outlet's flat fee (or the platform fallback) rather
    // than silently sending an unbacked delivery fee.
    if (lat == null ||
        lng == null ||
        outlet.latitude == null ||
        outlet.longitude == null) {
      return outlet.deliveryFeeMinor > 0
          ? outlet.deliveryFeeMinor
          : _flatFallbackMinor;
    }

    final distanceKm = _haversineKm(
      outlet.latitude!,
      outlet.longitude!,
      lat,
      lng,
    );
    final fee = baseFeeMinor + (distanceKm * pricePerKmMinor).round();
    return max(0, fee);
  }

  int _perLocationFee(Outlet outlet, String? zoneId, String? zoneName) {
    if (zoneId != null) {
      final byZoneId = outlet.deliveryLocationFees.firstWhereOrNull(
        (loc) => loc.zoneId == zoneId,
      );
      if (byZoneId != null) return byZoneId.feeMinor;
    }

    if (zoneName != null) {
      final lowerZoneName = zoneName.toLowerCase();
      final byName = outlet.deliveryLocationFees.firstWhereOrNull(
        (loc) => loc.locationName.toLowerCase() == lowerZoneName,
      );
      if (byName != null) return byName.feeMinor;
    }

    // No match — backend falls back to deliveryBaseFeeMinor, or rejects the
    // order as non-deliverable if that's also unset. We mirror the fallback
    // and let the initiate-payment call surface the backend's own error if
    // it disagrees.
    return outlet.deliveryBaseFeeMinor ?? 0;
  }

  double _haversineKm(double lat1, double lon1, double lat2, double lon2) {
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) *
            cos(_degToRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return _earthRadiusKm * c;
  }

  double _degToRad(double deg) => deg * (pi / 180);
}
