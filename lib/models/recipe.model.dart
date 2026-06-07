import 'package:isar/isar.dart';
import 'package:recipe_app_final_project/enums/cooking_unit.enum.dart';
import 'tag.model.dart';

part 'recipe.model.g.dart';

@collection
class Recipe {
  Id id = Isar.autoIncrement;

  late String title;
  String? imagePath;

  List<RecipeIngredient> ingredients = [];
  List<RecipeStep> steps = [];
  final tags = IsarLinks<Tag>();
}

@embedded
class RecipeIngredient {
  String? name;
  double? quantity;

  @Enumerated(EnumType.name)
  CookingUnit? unit;
}

@embedded
class RecipeStep {
  late String description;
}
