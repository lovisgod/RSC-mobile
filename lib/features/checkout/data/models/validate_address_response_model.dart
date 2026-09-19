class ValidateAddressResponseModel {
  const ValidateAddressResponseModel({
    required this.deliverable,
    this.zoneName,
    this.zoneId,
  });

  final bool deliverable;

  /// Null when [deliverable] is false.
  final String? zoneName;

  /// Null when [deliverable] is false, or the backend doesn't tag the zone
  /// with an id. Used to match `PER_LOCATION` delivery-fee overrides by
  /// zoneId before falling back to a locationName match.
  final String? zoneId;

  factory ValidateAddressResponseModel.fromJson(Map<String, dynamic> json) {
    final zone = json['zone'] as Map<String, dynamic>?;
    return ValidateAddressResponseModel(
      deliverable: json['deliverable'] as bool? ?? false,
      zoneName: zone?['name'] as String?,
      zoneId: zone?['id'] as String?,
    );
  }
}
