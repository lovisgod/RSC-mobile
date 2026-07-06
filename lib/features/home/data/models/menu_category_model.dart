import '../../../menu/domain/entities/category.dart';

/// Maps a single object from the outlet response's `menuCategories` array.
class MenuCategoryModel {
  final String id;
  final String outletId;
  final String name;
  final int sortOrder;
  final bool isActive;

  const MenuCategoryModel({
    required this.id,
    required this.outletId,
    required this.name,
    required this.sortOrder,
    required this.isActive,
  });

  factory MenuCategoryModel.fromJson(Map<String, dynamic> json) {
    return MenuCategoryModel(
      id: json['id'] as String? ?? '',
      outletId: json['outletId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
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
