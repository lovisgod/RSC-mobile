import '../../../menu/domain/entities/category.dart';

/// Maps a single object from the outlet response's `menuCategories` array.
class MenuCategoryModel {
  final String id;
  final String outletId;
  final String name;
  final int sortOrder;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  const MenuCategoryModel({
    required this.id,
    required this.outletId,
    required this.name,
    required this.sortOrder,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory MenuCategoryModel.fromJson(Map<String, dynamic> json) {
    return MenuCategoryModel(
      id: json['id'] as String? ?? '',
      outletId: json['outletId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? ''),
      deletedAt: DateTime.tryParse(json['deletedAt'] as String? ?? ''),
    );
  }

  MenuCategory toEntity() => MenuCategory(
    id: id,
    outletId: outletId,
    name: name,
    sortOrder: sortOrder,
    isActive: isActive,
  );
}
