class ValidateAddressResponseModel {
  const ValidateAddressResponseModel({
    required this.deliverable,
    this.zoneName,
  });

  final bool deliverable;

  /// Null when [deliverable] is false.
  final String? zoneName;

  factory ValidateAddressResponseModel.fromJson(Map<String, dynamic> json) {
    final zone = json['zone'] as Map<String, dynamic>?;
    return ValidateAddressResponseModel(
      deliverable: json['deliverable'] as bool? ?? false,
      zoneName: zone?['name'] as String?,
    );
  }
}
