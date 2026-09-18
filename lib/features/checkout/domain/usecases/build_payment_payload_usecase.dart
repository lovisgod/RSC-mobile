import 'package:flutter/foundation.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/id_generator.dart';
import '../../../cart/domain/entities/cart_entity.dart';
import '../../data/models/initiate_payment_item_model.dart';
import '../../data/models/initiate_payment_request_model.dart';
import '../../data/models/modifier_id_model.dart';
import '../../presentation/cubit/checkout_state.dart';
import '../entities/platform_charges_entity.dart';
import '../enums/delivery_mode.dart';

/// Maps the current cart + checkout selections into the initiate-payment
/// request body. All ids forwarded here (menuItemId, modifierId) are the real
/// backend UUIDs already stored on the cart entities.
class BuildPaymentPayloadUseCase {
  const BuildPaymentPayloadUseCase();

  // Backend enum values for deliveryMode.
  static const String _modeDelivery = 'DELIVERY';
  static const String _modeTakeout = 'TAKEOUT';

  // Backend requires deliveryAddress to be at least 5 characters even for
  // takeout orders, where the address is otherwise irrelevant.
  static const String _takeoutAddressPlaceholder = 'TAKEOUT';

  InitiatePaymentRequestModel call({
    required CartEntity cart,
    required CheckoutState checkout,
    required PlatformChargesEntity platformCharges,
  }) {
    final isDelivery = checkout.selectedMode == DeliveryMode.delivery;

    final items = cart.items.map((item) {
      return InitiatePaymentItemModel(
        menuItemId: item.menuItemId,
        quantity: item.quantity,
        modifiers: item.selectedModifiers
            .map((m) => ModifierIdModel(modifierId: m.modifierId))
            .toList(),
      );
    }).toList();

    // The delivery always goes to the address the ordering user entered —
    // "someone else" only adds a recipient phone on top. Takeout carries a
    // placeholder because the backend requires a non-empty, min-5-char
    // deliveryAddress regardless of mode.
    final deliveryAddress = isDelivery
        ? checkout.deliveryAddress
        : _takeoutAddressPlaceholder;

    debugPrint(
      '[RSC Checkout] Delivery coordinates: '
      '${checkout.currentLatitude}, ${checkout.currentLongitude}',
    );
    debugPrint('[RSC Checkout] Address verified: ${checkout.addressVerified}');
    debugPrint('[RSC Checkout] Delivery address: ${checkout.deliveryAddress}');

    // Coordinates are set exclusively by the address pipeline
    // (resolve-address → validate-address, a saved address, or a reorder
    // pre-fill). isFormValid guarantees them before the proceed button
    // activates; if they're missing something upstream broke — fail the
    // initiate call rather than dispatch a rider to fake coordinates.
    // Takeout has no delivery point, so it sends no coordinates at all.
    assert(
      !isDelivery ||
          (checkout.currentLatitude != null &&
              checkout.currentLongitude != null),
      'Real coordinates required for delivery',
    );
    final double? latitude;
    final double? longitude;
    if (!isDelivery) {
      latitude = null;
      longitude = null;
    } else {
      latitude = checkout.currentLatitude;
      longitude = checkout.currentLongitude;
      if (latitude == null || longitude == null) {
        throw StateError(AppStrings.deliveryCoordinatesMissing);
      }
    }

    // Calculate Minor values (in kobo/cents)
    // subtotal from cart is in major units (Naira)
    final subtotalMinor = (cart.subtotal * 100).round();
    // Sourced from CheckoutCubit's per-outlet calculation (CheckoutState is
    // the single source of truth) rather than recomputed here, so the value
    // sent to the backend always matches what was shown to the user and the
    // backend's own strict deliveryFeeMinor validation never mismatches.
    final deliveryFeeMinor = isDelivery ? checkout.deliveryFeeMinor : 0;
    final serviceFeeMinor = platformCharges.serviceFeeMinor;

    // platformCommissionMinor = (platformCommissionBps / 10000) * subtotalMinor
    // Sent to the backend for its own bookkeeping (the platform's cut of the
    // outlet's payout) — the backend's totalMinor validation includes it in
    // what the customer pays (confirmed against /payments/initiate's "Total
    // mismatch" response), so it's included in totalMinor below too.
    final platformCommissionMinor =
        (subtotalMinor * platformCharges.platformCommissionBps / 10000).round();

    // vatMinor = (defaultVatBps / 10000) * subtotalMinor
    final vatMinor = (subtotalMinor * platformCharges.defaultVatBps / 10000)
        .round();

    const discountMinor = 0; // No promo-code-at-checkout flow yet.

    final totalMinor =
        subtotalMinor +
        deliveryFeeMinor +
        serviceFeeMinor +
        vatMinor +
        platformCommissionMinor -
        discountMinor;

    return InitiatePaymentRequestModel(
      items: items,
      deliveryMode: isDelivery ? _modeDelivery : _modeTakeout,
      deliveryAddress: deliveryAddress,
      deliveryLatitude: latitude,
      deliveryLongitude: longitude,
      landmark: isDelivery && checkout.landmark.isNotEmpty
          ? checkout.landmark
          : null,
      subtotalMinor: subtotalMinor,
      deliveryFeeMinor: deliveryFeeMinor,
      serviceFeeMinor: serviceFeeMinor,
      vatMinor: vatMinor,
      discountMinor: discountMinor,
      platformCommissionMinor: platformCommissionMinor,
      totalMinor: totalMinor,
      returnUrl: AppConstants.paymentReturnUrl,
      idempotencyKey: IdGenerator.uuidV4(),
      // Only send recipientPhone when ordering for someone else and the
      // field is non-empty; null suppresses the key from the JSON body.
      recipientPhone:
          checkout.isOrderingForSomeoneElse &&
              checkout.recipientPhone.isNotEmpty
          ? checkout.recipientPhone
          : null,
      // Top-level preparation note — mirrors per-item customerNote for
      // backends that read it at the order level.
      preparationNote: checkout.preparationInstructions.isNotEmpty
          ? checkout.preparationInstructions
          : null,
    );
  }
}
