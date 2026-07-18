import '../../domain/entities/rider_location_entity.dart';

class RiderLocationModel {
  final String riderId;
  final String masterOrderId;
  final double latitude;
  final double longitude;
  final DateTime recordedAt;

  const RiderLocationModel({
    required this.riderId,
    required this.masterOrderId,
    required this.latitude,
    required this.longitude,
    required this.recordedAt,
  });

  factory RiderLocationModel.fromJson(Map<String, dynamic> json) {
    return RiderLocationModel(
      riderId: json['riderId'] as String? ?? '',
      masterOrderId: json['masterOrderId'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      recordedAt:
          DateTime.tryParse(json['recordedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  RiderLocationEntity toEntity() => RiderLocationEntity(
    riderId: riderId,
    masterOrderId: masterOrderId,
    latitude: latitude,
    longitude: longitude,
    recordedAt: recordedAt,
  );
}
