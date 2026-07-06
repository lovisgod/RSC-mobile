class Modifier {
  final String id;
  final String groupId;
  final String name;

  /// Major-unit delta (already converted from `priceDeltaMinor / 100`).
  final double priceDelta;
  final bool isAvailable;
  final int sortOrder;
  final String outletId;

  const Modifier({
    required this.id,
    required this.groupId,
    required this.name,
    required this.priceDelta,
    this.isAvailable = true,
    this.sortOrder = 0,
    this.outletId = '',
  });
}
