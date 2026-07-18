class PlatformChargesEntity {
  final int platformCommissionBps;
  final int defaultVatBps;
  final int deliveryFeeMinor;
  final int serviceFeeMinor;
  final String currency;

  PlatformChargesEntity({
    required this.platformCommissionBps,
    required this.defaultVatBps,
    required this.deliveryFeeMinor,
    required this.serviceFeeMinor,
    required this.currency,
  });
}
