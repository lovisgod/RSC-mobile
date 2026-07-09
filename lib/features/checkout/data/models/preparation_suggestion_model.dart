import '../../domain/entities/preparation_suggestion_entity.dart';

class PreparationSuggestionModel {
  const PreparationSuggestionModel({
    required this.id,
    required this.text,
    required this.outletId,
    required this.isActive,
    required this.sortOrder,
  });

  final String id;
  final String text;
  final String outletId;
  final bool isActive;
  final int sortOrder;

  factory PreparationSuggestionModel.fromJson(Map<String, dynamic> json) {
    return PreparationSuggestionModel(
      id: json['id'] as String,
      text: json['text'] as String,
      outletId: json['outletId'] as String,
      isActive: json['isActive'] as bool? ?? false,
      sortOrder: json['sortOrder'] as int? ?? 0,
    );
  }

  PreparationSuggestionEntity toEntity() =>
      PreparationSuggestionEntity(id: id, text: text, outletId: outletId);
}
