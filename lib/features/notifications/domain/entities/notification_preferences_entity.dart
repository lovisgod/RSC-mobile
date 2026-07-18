class NotificationPreferencesEntity {
  final bool promotions;
  final bool discounts;
  final bool seasonalOffers;
  final bool orderStatus;

  const NotificationPreferencesEntity({
    required this.promotions,
    required this.discounts,
    required this.seasonalOffers,
    this.orderStatus = true,
  });

  const NotificationPreferencesEntity.defaults()
    : promotions = true,
      discounts = true,
      seasonalOffers = true,
      orderStatus = true;

  NotificationPreferencesEntity copyWith({
    bool? promotions,
    bool? discounts,
    bool? seasonalOffers,
  }) => NotificationPreferencesEntity(
    promotions: promotions ?? this.promotions,
    discounts: discounts ?? this.discounts,
    seasonalOffers: seasonalOffers ?? this.seasonalOffers,
    orderStatus: true,
  );
}
