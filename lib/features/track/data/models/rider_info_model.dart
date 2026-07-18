import '../../domain/entities/rider_info_entity.dart';

class RiderInfoModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String? avatarUrl;
  final String vehicleType;
  final String plateNumber;

  const RiderInfoModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.avatarUrl,
    required this.vehicleType,
    required this.plateNumber,
  });

  factory RiderInfoModel.fromJson(Map<String, dynamic> json) {
    return RiderInfoModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      vehicleType: json['vehicleType'] as String? ?? '',
      plateNumber: json['plateNumber'] as String? ?? '',
    );
  }

  RiderInfoEntity toEntity() => RiderInfoEntity(
    id: id,
    name: name,
    phone: phone,
    email: email,
    avatarUrl: avatarUrl,
    vehicleType: vehicleType,
    plateNumber: plateNumber,
  );
}
