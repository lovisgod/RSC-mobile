import '../../domain/entities/notification_preferences_entity.dart';

class NotificationPreferencesModel {
  final bool promotions;
  final bool discounts;
  final bool seasonalOffers;

  const NotificationPreferencesModel({
    required this.promotions,
    required this.discounts,
    required this.seasonalOffers,
  });

  factory NotificationPreferencesModel.fromJson(Map<String, dynamic> json) {
    return NotificationPreferencesModel(
      promotions: json['promotions'] as bool? ?? true,
      discounts: json['discounts'] as bool? ?? true,
      seasonalOffers: json['seasonalOffers'] as bool? ?? true,
    );
  }

  /// [orderStatus] is never user-controllable — always sent as `true`.
  Map<String, dynamic> toJson() => {
    'promotions': promotions,
    'discounts': discounts,
    'seasonalOffers': seasonalOffers,
    'orderStatus': true,
  };

  NotificationPreferencesEntity toEntity() => NotificationPreferencesEntity(
    promotions: promotions,
    discounts: discounts,
    seasonalOffers: seasonalOffers,
  );
}
