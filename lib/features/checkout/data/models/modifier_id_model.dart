/// A single selected modifier reference in the initiate-payment payload.
///
/// [modifierId] is the real backend UUID captured at item-selection time
/// (ItemDetailScreen → CartItemEntity.selectedModifiers → here) — never a
/// client-generated id.
class ModifierIdModel {
  final String modifierId;

  const ModifierIdModel({required this.modifierId});

  Map<String, dynamic> toJson() => {'modifierId': modifierId};
}
