import '../../../cart/domain/entities/cart_entity.dart';
import '../../data/models/initiate_payment_item_model.dart';
import '../../data/models/initiate_payment_request_model.dart';
import '../../data/models/modifier_id_model.dart';
import '../../presentation/cubit/checkout_state.dart';
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
  // geofence flow and manually typed addresses never resolved via Nominatim.
  // The API requires latitude/longitude regardless of delivery mode.
  static const double _placeholderLatitude = 6.4474;
  static const double _placeholderLongitude = 3.4542;

  // Backend requires deliveryAddress to be at least 5 characters even for
  // takeout orders, where the address is otherwise irrelevant.
  static const String _takeoutAddressPlaceholder = 'TAKEOUT';

  InitiatePaymentRequestModel call(CartEntity cart, CheckoutState checkout) {
    final isDelivery = checkout.selectedMode == DeliveryMode.delivery;

    final items = cart.items.map((item) {
      return InitiatePaymentItemModel(
        menuItemId: item.menuItemId,
        quantity: item.quantity,
        modifiers: item.selectedModifiers
            .map((m) => ModifierIdModel(modifierId: m.modifierId))
            .toList(),
        // One order-level instruction is applied to every item for now.
        customerNote: checkout.preparationInstructions,
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

    // Coordinates come from, in priority order: a Nominatim autocomplete
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

    return InitiatePaymentRequestModel(
      items: items,
      deliveryMode: isDelivery ? _modeDelivery : _modeTakeout,
      deliveryAddress: deliveryAddress,
      deliveryLatitude: latitude,
      deliveryLongitude: longitude,
    );
  }
}
