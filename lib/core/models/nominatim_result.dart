class NominatimResult {
  final String displayName;
  final double latitude;
  final double longitude;
  final String? road;
  final String? suburb;
  final String? city;
  final String? state;

  const NominatimResult({
    required this.displayName,
    required this.latitude,
    required this.longitude,
    this.road,
    this.suburb,
    this.city,
    this.state,
  });

  factory NominatimResult.fromJson(Map<String, dynamic> json) {
    final address = json['address'] as Map<String, dynamic>?;
    return NominatimResult(
      displayName: json['display_name'] as String,
      latitude: double.parse(json['lat'] as String),
      longitude: double.parse(json['lon'] as String),
      road: address?['road'] as String?,
      suburb: address?['suburb'] as String?,
      city: address?['city'] as String? ?? address?['town'] as String?,
      state: address?['state'] as String?,
    );
  }

  /// Clean, short label for display — built from address parts rather than
  /// the full [displayName], which is too long and includes country/postcode.
  String get shortAddress {
    final parts = <String>[];
    if (road?.isNotEmpty == true) parts.add(road!);
    if (suburb?.isNotEmpty == true) parts.add(suburb!);
    if (city?.isNotEmpty == true) parts.add(city!);
    return parts.isNotEmpty
        ? parts.join(', ')
        : displayName.split(',').take(3).join(',').trim();
  }
}
