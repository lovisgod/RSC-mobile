class RiderLocationEntity {
  final String riderId;
  final String masterOrderId;
  final double latitude;
  final double longitude;
  final DateTime recordedAt;

  const RiderLocationEntity({
    required this.riderId,
    required this.masterOrderId,
    required this.latitude,
    required this.longitude,
    required this.recordedAt,
  });
}
