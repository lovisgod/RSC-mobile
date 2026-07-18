class RefundRequestModel {
  /// Order total in minor units (kobo) — passed through from the API's
  /// `totalMinor`, never converted.
  final int amountMinor;
  final String reason;

  const RefundRequestModel({required this.amountMinor, required this.reason});

  Map<String, dynamic> toJson() => {
    'amountMinor': amountMinor,
    'reason': reason,
  };
}
