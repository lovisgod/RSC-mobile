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

  // Fallback coordinates (Victoria Island, Lagos) for the someone-else
  // geofence flow and manually typed addresses never resolved via the
  // address-suggestions API. The API requires latitude/longitude regardless
  // of delivery mode.
  static const double _placeholderLatitude = 6.4474;
  static const double _placeholderLongitude = 3.4542;

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

    // For delivery use the recipient address when ordering for someone else;
    // takeout carries a placeholder — the backend requires a non-empty,
    // min-5-char deliveryAddress regardless of mode.
    final String deliveryAddress;
    if (!isDelivery) {
      deliveryAddress = _takeoutAddressPlaceholder;
    } else if (checkout.isOrderingForSomeoneElse) {
      deliveryAddress = checkout.recipientAddress;
    } else {
      deliveryAddress = checkout.deliveryAddress;
    }

    // Coordinates come from, in priority order: a resolved autocomplete
    // pick, a saved address selected via "Use Default Address", or the
    // placeholder for the someone-else geofence flow / untouched manual text.
    final useRealCoords = isDelivery && !checkout.isOrderingForSomeoneElse;
    final selectedAddress = checkout.selectedAddress;
    final latitude = !useRealCoords
        ? _placeholderLatitude
        : checkout.currentLatitude ??
            selectedAddress?.latitude ??
            _placeholderLatitude;
    final longitude = !useRealCoords
        ? _placeholderLongitude
        : checkout.currentLongitude ??
            selectedAddress?.longitude ??
            _placeholderLongitude;

    // Calculate Minor values (in kobo/cents)
    // subtotal from cart is in major units (Naira)
    final subtotalMinor = (cart.subtotal * 100).round();
    final deliveryFeeMinor = isDelivery ? platformCharges.deliveryFeeMinor : 0;
    final serviceFeeMinor = platformCharges.serviceFeeMinor;

    // platformCommissionMinor = (platformCommissionBps / 10000) * subtotalMinor
    final platformCommissionMinor =
        (subtotalMinor * platformCharges.platformCommissionBps / 10000).round();

    // vatMinor = (defaultVatBps / 10000) * subtotalMinor
    final vatMinor =
        (subtotalMinor * platformCharges.defaultVatBps / 10000).round();

    final totalMinor = subtotalMinor +
        deliveryFeeMinor +
        serviceFeeMinor +
        vatMinor +
        platformCommissionMinor;

    return InitiatePaymentRequestModel(
      items: items,
      deliveryMode: isDelivery ? _modeDelivery : _modeTakeout,
      deliveryAddress: deliveryAddress,
      deliveryLatitude: latitude,
      deliveryLongitude: longitude,
      subtotalMinor: subtotalMinor,
      deliveryFeeMinor: deliveryFeeMinor,
      serviceFeeMinor: serviceFeeMinor,
      vatMinor: vatMinor,
      platformCommissionMinor: platformCommissionMinor,
      totalMinor: totalMinor,
      // Only send recipientPhone when ordering for someone else and the
      // field is non-empty; null suppresses the key from the JSON body.
      recipientPhone: checkout.isOrderingForSomeoneElse &&
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
