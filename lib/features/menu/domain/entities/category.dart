class MenuCategory {
  final String id;
  final String outletId;
  final String name;
  final int sortOrder;
  final bool isActive;

  const MenuCategory({
    required this.id,
    required this.outletId,
    required this.name,
    required this.sortOrder,
    this.isActive = true,
  });
}
