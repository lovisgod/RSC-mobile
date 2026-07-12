class ReorderModifierModel {
  final String modifierId;

  const ReorderModifierModel({required this.modifierId});

  factory ReorderModifierModel.fromJson(Map<String, dynamic> json) {
    return ReorderModifierModel(
      modifierId: json['modifierId'] as String? ?? '',
    );
  }
}
