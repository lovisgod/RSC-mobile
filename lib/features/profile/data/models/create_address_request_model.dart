/// [latitude]/[longitude] must always be real geocoded coordinates from the
/// resolve-address pipeline (or an existing saved address) — never
/// placeholders.
class CreateAddressRequestModel {
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
