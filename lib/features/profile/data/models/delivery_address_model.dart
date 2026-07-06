import '../../domain/entities/delivery_address_entity.dart';

class DeliveryAddressModel extends DeliveryAddressEntity {
  const DeliveryAddressModel({
    required super.id,
    required super.customerId,
    required super.label,
    required super.addressLine,
    required super.city,
    required super.state,
    required super.latitude,
    required super.longitude,
    required super.isDefault,
    required super.createdAt,
  });

  factory DeliveryAddressModel.fromJson(Map<String, dynamic> json) {
    return DeliveryAddressModel(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
      label: json['label'] as String,
      addressLine: json['addressLine'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      isDefault: json['isDefault'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'customerId': customerId,
    'label': label,
    'addressLine': addressLine,
    'city': city,
    'state': state,
    'latitude': latitude,
    'longitude': longitude,
    'isDefault': isDefault,
    'createdAt': createdAt.toIso8601String(),
  };

  DeliveryAddressEntity toEntity() => this;
}
