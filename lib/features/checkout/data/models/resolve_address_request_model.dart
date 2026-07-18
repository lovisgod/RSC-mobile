class ResolveAddressRequestModel {
  final String input;
  final String suggestionId;
  final String provider;
  final String? sessionToken;

  const ResolveAddressRequestModel({
    required this.input,
    required this.suggestionId,
    required this.provider,
    this.sessionToken,
  });

  Map<String, dynamic> toJson() => {
    'input': input,
    'suggestionId': suggestionId,
    'provider': provider,
    'sessionToken': sessionToken ?? '',
  };
}
