import 'package:isar/isar.dart';
import 'package:recipe_app_final_project/enums/cooking_unit.enum.dart';

part 'pantry_item.model.g.dart';

@collection
class PantryItem {
  Id id = Isar.autoIncrement;

  late String name;
  double? quantity;
  @Enumerated(EnumType.name)
  CookingUnit? unit;
}
