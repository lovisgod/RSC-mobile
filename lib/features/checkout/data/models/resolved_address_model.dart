class ResolvedAddressModel {
  final String addressLine;
  final String city;
  final String state;
  final String label;
  final String displayName;
  final double latitude;
  final double longitude;
  final String provider;

  const ResolvedAddressModel({
    required this.addressLine,
    required this.city,
    required this.state,
    required this.label,
    required this.displayName,
    required this.latitude,
    required this.longitude,
    required this.provider,
  });

  factory ResolvedAddressModel.fromJson(Map<String, dynamic> json) {
    return ResolvedAddressModel(
      addressLine: json['addressLine'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      label: json['label'] as String,
      displayName: json['displayName'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      provider: json['provider'] as String,
    );
  }
}
