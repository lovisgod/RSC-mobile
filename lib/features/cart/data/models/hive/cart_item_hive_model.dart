import 'package:hive/hive.dart';

import '../../../../../core/constants/app_constants.dart';
import 'selected_modifier_hive_model.dart';

part 'cart_item_hive_model.g.dart';

@HiveType(typeId: AppConstants.cartHiveTypeId)
class CartItemHiveModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String menuItemId;

  @HiveField(2)
  late String outletId;

  @HiveField(3)
  late String outletName;

  @HiveField(4)
  late String outletEmoji;

  @HiveField(5)
  late String itemNameSnapshot;

  @HiveField(6)
  late double unitPrice;

  @HiveField(7)
  late double basePrice;

  @HiveField(8)
  late int quantity;

  @HiveField(9)
  late List<SelectedModifierHiveModel> selectedModifiers;

  @HiveField(10)
  late String itemImageUrl;
}
