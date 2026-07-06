class DeliveryAddressEntity {
  final String id;
  final String customerId;
  final String label;
  final String addressLine;
  final String city;
  final String state;
  final double latitude;
  final double longitude;
  final bool isDefault;
  final DateTime createdAt;

  const DeliveryAddressEntity({
    required this.id,
    required this.customerId,
    required this.label,
    required this.addressLine,
    required this.city,
    required this.state,
    required this.latitude,
    required this.longitude,
    required this.isDefault,
    required this.createdAt,
  });

  String get displayAddress => '$addressLine, $city, $state';

  DeliveryAddressEntity copyWith({bool? isDefault}) {
    return DeliveryAddressEntity(
      id: id,
      customerId: customerId,
      label: label,
      addressLine: addressLine,
      city: city,
      state: state,
      latitude: latitude,
      longitude: longitude,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt,
    );
  }
}
