/// Request body for `POST /api/v1/delivery/resolve-address`. Supports two
/// shapes: resolving a prior autocomplete suggestion ([suggestionId] set —
/// the existing flow), or resolving raw GPS coordinates / a free-text query
/// directly ([suggestionId] null — "Option A" in the backend changelog).
class ResolveAddressRequestModel {
  final String input;
  final String? suggestionId;
  final String provider;
  final String? sessionToken;

  const ResolveAddressRequestModel({
    required this.input,
    this.suggestionId,
    required this.provider,
    this.sessionToken,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'input': input, 'provider': provider};
    // suggestionId/sessionToken are only meaningful for the autocomplete
    // flow — omitted entirely for a raw input (GPS/free-text) resolve.
    if (suggestionId != null) {
      map['suggestionId'] = suggestionId;
      map['sessionToken'] = sessionToken ?? '';
    }
    return map;
  }
}
