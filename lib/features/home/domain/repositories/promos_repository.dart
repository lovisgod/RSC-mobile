import '../entities/promo_offer.dart';

abstract class PromosRepository {
  /// Backend already filters to currently-active offers for a customer
  /// caller (confirmed against `GET /api/v1/notifications/promos` directly —
  /// no client-side active/date filtering needed here).
  Future<List<PromoOffer>> getActivePromos();
}
