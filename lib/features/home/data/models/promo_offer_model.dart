import '../../domain/entities/promo_offer.dart';

class PromoOfferModel {
  final String id;
  final String code;
  final String title;
  final String body;
  final String discountTarget;
  final int discountPercent;
  final String scope;
  final String? outletId;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final bool isActive;
  final String? deepLink;
  final String? imageUrl;

  const PromoOfferModel({
    required this.id,
    required this.code,
    required this.title,
    required this.body,
    required this.discountTarget,
    required this.discountPercent,
    required this.scope,
    this.outletId,
    this.startsAt,
    this.endsAt,
    required this.isActive,
    this.deepLink,
    this.imageUrl,
  });

  factory PromoOfferModel.fromJson(Map<String, dynamic> json) {
    return PromoOfferModel(
      id: json['id'] as String,
      code: json['code'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      discountTarget: json['discountTarget'] as String? ?? 'ORDER',
      discountPercent: (json['discountPercent'] as num?)?.toInt() ?? 0,
      scope: json['scope'] as String? ?? 'ALL_OUTLETS',
      outletId: json['outletId'] as String?,
      startsAt: DateTime.tryParse(json['startsAt'] as String? ?? ''),
      endsAt: DateTime.tryParse(json['endsAt'] as String? ?? ''),
      isActive: json['isActive'] as bool? ?? true,
      deepLink: json['deepLink'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  PromoOffer toEntity() => PromoOffer(
    id: id,
    code: code,
    title: title,
    body: body,
    discountTarget: discountTarget,
    discountPercent: discountPercent,
    scope: scope,
    outletId: outletId,
    startsAt: startsAt,
    endsAt: endsAt,
    isActive: isActive,
    deepLink: deepLink,
    imageUrl: imageUrl,
  );
}
