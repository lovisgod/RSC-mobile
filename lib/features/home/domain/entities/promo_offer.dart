class PromoOffer {
  final String id;
  final String code;
  final String title;
  final String body;

  /// Raw backend enum value (only 'ORDER' confirmed so far) — kept as a
  /// string rather than a closed Dart enum since the full value set isn't
  /// documented yet. Render generically for any value that isn't 'ORDER'.
  final String discountTarget;
  final int discountPercent;

  /// Raw backend enum value — 'ALL_OUTLETS' or 'OUTLET' (outlet-scoped
  /// promos carry [outletId]). Treat anything else as global.
  final String scope;
  final String? outletId;

  final DateTime? startsAt;
  final DateTime? endsAt;
  final bool isActive;

  /// Format not settled yet on the backend side — currently always null in
  /// practice. See [PromoBannerCard]/[PromoDetailScreen] for the fallback
  /// behavior used until this is defined.
  final String? deepLink;
  final String? imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PromoOffer({
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
    this.createdAt,
    this.updatedAt,
  });

  bool get isOutletScoped => scope == 'OUTLET' && outletId != null;
}
