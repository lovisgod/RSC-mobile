import '../../domain/entities/platform_charges_entity.dart';

class PlatformChargesModel {
  final int platformCommissionBps;
  final int defaultVatBps;
  final int deliveryFeeMinor;
  final int serviceFeeMinor;
  final String currency;

  PlatformChargesModel({
    required this.platformCommissionBps,
    required this.defaultVatBps,
    required this.deliveryFeeMinor,
    required this.serviceFeeMinor,
    required this.currency,
  });

  factory PlatformChargesModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return PlatformChargesModel(
      platformCommissionBps: data['platformCommissionBps'] ?? 0,
      defaultVatBps: data['defaultVatBps'] ?? 0,
      deliveryFeeMinor: data['deliveryFeeMinor'] ?? 0,
      serviceFeeMinor: data['serviceFeeMinor'] ?? 0,
      currency: data['currency'] ?? 'NGN',
    );
  }

  PlatformChargesEntity toEntity() => PlatformChargesEntity(
        platformCommissionBps: platformCommissionBps,
        defaultVatBps: defaultVatBps,
        deliveryFeeMinor: deliveryFeeMinor,
        serviceFeeMinor: serviceFeeMinor,
        currency: currency,
      );
}
