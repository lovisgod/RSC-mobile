import 'reorder_item_model.dart';

class ReorderResponseModel {
  final String deliveryMode;
  final List<ReorderItemModel> items;
  final String deliveryAddress;
  final double deliveryLatitude;
  final double deliveryLongitude;

  const ReorderResponseModel({
    required this.deliveryMode,
    required this.items,
    required this.deliveryAddress,
    required this.deliveryLatitude,
    required this.deliveryLongitude,
  });

  factory ReorderResponseModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    return ReorderResponseModel(
      deliveryMode: json['deliveryMode'] as String? ?? '',
      items: rawItems is List
          ? rawItems
                .whereType<Map<String, dynamic>>()
                .map(ReorderItemModel.fromJson)
                .toList()
          : const [],
      deliveryAddress: json['deliveryAddress'] as String? ?? '',
      deliveryLatitude: (json['deliveryLatitude'] as num?)?.toDouble() ?? 0.0,
      deliveryLongitude: (json['deliveryLongitude'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
