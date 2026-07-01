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

  // TODO: Hardcoded coordinates until address geocoding/autocomplete is
  // implemented (Victoria Island, Lagos placeholder). The API requires
  // latitude/longitude regardless of delivery mode.
  static const double _placeholderLatitude = 6.4474;
  static const double _placeholderLongitude = 3.4542;

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
    // takeout carries no address.
    final String deliveryAddress;
    if (!isDelivery) {
      deliveryAddress = '';
    } else if (checkout.isOrderingForSomeoneElse) {
      deliveryAddress = checkout.recipientAddress;
    } else {
      deliveryAddress = checkout.deliveryAddress;
    }

    return InitiatePaymentRequestModel(
      items: items,
      deliveryMode: isDelivery ? _modeDelivery : _modeTakeout,
      deliveryAddress: deliveryAddress,
      deliveryLatitude: _placeholderLatitude,
      deliveryLongitude: _placeholderLongitude,
    );
  }
}
