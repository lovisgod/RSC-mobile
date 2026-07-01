import 'modifier_id_model.dart';

/// One line item in the initiate-payment request.
///
/// [menuItemId] is the real backend UUID stored on the cart item from the
/// outlets API integration.
class InitiatePaymentItemModel {
  final String menuItemId;
  final int quantity;
  final List<ModifierIdModel> modifiers;
  final String customerNote;

  const InitiatePaymentItemModel({
    required this.menuItemId,
    required this.quantity,
    required this.modifiers,
    required this.customerNote,
  });

  Map<String, dynamic> toJson() => {
        'menuItemId': menuItemId,
        'quantity': quantity,
        // Always include `modifiers` — as an empty array when none are
        // selected (the API accepts []), so the key is never absent.
        'modifiers': modifiers.map((m) => m.toJson()).toList(),
        'customerNote': customerNote,
      };
}
