import 'package:hive/hive.dart';

import '../../../../../core/constants/app_constants.dart';

part 'selected_modifier_hive_model.g.dart';

@HiveType(typeId: AppConstants.selectedModifierHiveTypeId)
class SelectedModifierHiveModel extends HiveObject {
  @HiveField(0)
  late String modifierId;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late double priceDelta;
}
