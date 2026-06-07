import 'package:recipe_app_final_project/enums/cooking_unit.enum.dart';
import 'package:recipe_app_final_project/models/pantry_item.model.dart';
import 'package:recipe_app_final_project/models/recipe.model.dart';
import 'package:recipe_app_final_project/models/tag.model.dart';
import 'package:recipe_app_final_project/services/pantry.service.dart';
import 'package:recipe_app_final_project/services/recipe.service.dart';
import 'package:recipe_app_final_project/services/tag.service.dart';

import '../main.dart'; // a getIt miatt

Future<void> seedDummyRecipes() async {
  final recipeService = getIt<RecipeService>();
  final tagService = getIt<TagService>();
  final pantryService = getIt<PantryService>();
  final recipes = await recipeService.getAllRecipes();

  final italianTag = await tagService.getTagByName('Italian');
  final mainCourseTag = await tagService.getTagByName('Main Course');
  final portugueseTag = await tagService.getTagByName('Portuguese');
  final pescatarianTag = await tagService.getTagByName('Pescatarian');

  if (recipes.isEmpty) {
    // --- 1. Recept: A Figmás Pizza ---
    final pizzaRecipe = Recipe()
      ..title = 'Pizza'
      ..imagePath = null
      ..ingredients = [
        RecipeIngredient()
          ..name = 'flour'
          ..quantity = 500
          ..unit = CookingUnit.g,
        RecipeIngredient()
          ..name = 'salt'
          ..quantity = 10
          ..unit = CookingUnit.g,
        RecipeIngredient()
          ..name = 'water'
          ..quantity = 300
          ..unit = CookingUnit.ml,
        RecipeIngredient()
          ..name = 'yeast'
          ..quantity = 7
          ..unit = CookingUnit.g,
      ]
      ..steps = [
        RecipeStep()..description = 'Mix dry ingredients together.',
        RecipeStep()..description = 'Add water and yeast.',
        RecipeStep()
          ..description =
              'Knead the dough until smooth and let it double in size.',
        RecipeStep()
          ..description =
              'Shape the dough, add toppings, and bake at 250°C for 10 minutes.',
      ];

    // Dummy tagek a Pizzához

    final List<Tag> pizzaTags = [];
    if (italianTag != null) pizzaTags.add(italianTag);
    if (mainCourseTag != null) pizzaTags.add(mainCourseTag);

    await recipeService.saveRecipe(pizzaRecipe, pizzaTags);

    // --- 2. Recept: Sült Dourada ---
    final douradaRecipe = Recipe()
      ..title = 'Roasted Dourada'
      ..imagePath = null
      ..ingredients = [
        RecipeIngredient()
          ..name = 'dourada (sea bream)'
          ..quantity = 1
          ..unit = CookingUnit.pcs,
        RecipeIngredient()
          ..name = 'garlic'
          ..quantity = 2
          ..unit = CookingUnit.cloves,
        RecipeIngredient()
          ..name = 'lemon'
          ..quantity = 1
          ..unit = CookingUnit.pcs,
        RecipeIngredient()
          ..name = 'olive oil'
          ..quantity = 3.5
          ..unit = CookingUnit.tbsp,
      ]
      ..steps = [
        RecipeStep()
          ..description =
              'Clean the fish thoroughly and score the sides with a sharp knife.',
        RecipeStep()
          ..description =
              'Rub the fish inside and out with olive oil, salt, and minced garlic.',
        RecipeStep()
          ..description = 'Slice the lemon and stuff it inside the cavity.',
        RecipeStep()
          ..description =
              'Roast in a preheated oven at 200°C for 25-30 minutes until flaky.',
      ];

    // Dummy tagek a Douradához
    final List<Tag> douradaTags = [];
    if (portugueseTag != null) douradaTags.add(portugueseTag);
    if (pescatarianTag != null) douradaTags.add(pescatarianTag);

    await recipeService.saveRecipe(douradaRecipe, douradaTags);

    pantryService.saveRecipe(
      PantryItem()
        ..name = 'flour'
        ..quantity = 1000
        ..unit = CookingUnit.g,
    );

    pantryService.saveRecipe(
      PantryItem()
        ..name = 'milk'
        ..quantity = 1000
        ..unit = CookingUnit.ml,
    );

    print('Dummy receptek sikeresen betöltve!');
  }
}
