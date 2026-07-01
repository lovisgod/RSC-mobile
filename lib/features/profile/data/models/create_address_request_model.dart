class CreateAddressRequestModel {
  // TODO: Replace with actual geocoded coordinates
  // when Google Places/Maps integration is added
  static const double placeholderLatitude = 6.4474;
  static const double placeholderLongitude = 3.4542;

  final String label;
  final String addressLine;
  final String city;
  final String state;
  final double latitude;
  final double longitude;
  final bool isDefault;

  const CreateAddressRequestModel({
    required this.label,
    required this.addressLine,
    required this.city,
    required this.state,
    required this.latitude,
    required this.longitude,
    required this.isDefault,
  });

  Map<String, dynamic> toJson() => {
    'label': label,
    'addressLine': addressLine,
    'city': city,
    'state': state,
    'latitude': latitude,
    'longitude': longitude,
    'isDefault': isDefault,
  };
}
