class AddressSuggestionModel {
  final String id;
  final String description;
  final String provider;
  final String? sessionToken;

  const AddressSuggestionModel({
    required this.id,
    required this.description,
    required this.provider,
    this.sessionToken,
  });

  factory AddressSuggestionModel.fromJson(Map<String, dynamic> json) {
    return AddressSuggestionModel(
      id: json['id'] as String,
      description: json['description'] as String,
      provider: json['provider'] as String,
      sessionToken: json['sessionToken'] as String?,
    );
  }
}
