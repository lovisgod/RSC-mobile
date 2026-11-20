class RiderLocationEntity {
  final String riderId;
  final String masterOrderId;
  final double latitude;
  final double longitude;
  final DateTime recordedAt;
  final int? etaMinutes;
  final double? distanceKm;
  final String? etaProvider;

  const RiderLocationEntity({
    required this.riderId,
    required this.masterOrderId,
    required this.latitude,
    required this.longitude,
    required this.recordedAt,
    this.etaMinutes,
    this.distanceKm,
    this.etaProvider,
  });
}
