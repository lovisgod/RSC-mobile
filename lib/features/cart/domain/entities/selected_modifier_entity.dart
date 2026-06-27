class SelectedModifierEntity {
  final String modifierId;
  final String name;
  final double priceDelta;

  const SelectedModifierEntity({
    required this.modifierId,
    required this.name,
    required this.priceDelta,
  });

  @override
  bool operator ==(Object other) =>
      other is SelectedModifierEntity && other.modifierId == modifierId;

  @override
  int get hashCode => modifierId.hashCode;
}
