import 'package:isar/isar.dart';
import 'dart:math';
import 'package:recipe_app_final_project/enums/tag_type.enum.dart';
import 'package:recipe_app_final_project/models/recipe.model.dart';
import 'package:recipe_app_final_project/models/tag.model.dart';
import 'package:recipe_app_final_project/services/pantry.service.dart';

class RecommendedRecipe {
  final Recipe recipe;
  final List<String> missingIngredients;

  RecommendedRecipe({required this.recipe, required this.missingIngredients});
}

class RecipeService {
  final Isar isar;
  final PantryService pantryService;

  RecipeService(this.isar, this.pantryService);

  Future<List<Recipe>> getAllRecipes() async {
    final recipes = await isar.recipes.where().findAll();

    for (final recipe in recipes) {
      await recipe.tags.load();
    }
    return recipes;
  }

  Future<List<Recipe>> searchRecipes(String query) async {
    return await isar.recipes
        .filter()
        .titleContains(query, caseSensitive: false)
        .findAll();
  }

  Future<void> deleteRecipe(Id id) async {
    await isar.writeTxn(() async {
      await isar.recipes.delete(id);
    });
  }

  Future<List<Recipe>> findRecipeByEnoughIngredients({int servings = 1}) async {
    final recipes = await isar.recipes.where().findAll();
    final pantryItems = await pantryService.getAllPantryItem();

    List<Recipe> matchingRecipes = [];

    for (final recipe in recipes) {
      await recipe.tags.load();

      final hasAllIngredients = recipe.ingredients.every((ingredient) {
        final reqName = (ingredient.name ?? '').trim().toLowerCase();
        final reqQty = (ingredient.quantity ?? 0.0) * servings;

        if (reqQty <= 0.0) return true;

        return pantryItems.any((item) {
          final pantryName = item.name.trim().toLowerCase();
          final pantryQty = item.quantity ?? 0.0;

          return pantryName == reqName &&
              pantryQty >= reqQty &&
              item.unit == ingredient.unit;
        });
      });

      if (hasAllIngredients) {
        matchingRecipes.add(recipe);
      }
    }

    return matchingRecipes;
  }

  Future<Recipe?> getRandomOptimalRecipe() async {
    final allRecipes = await isar.recipes.where().findAll();
    if (allRecipes.isEmpty) return null;

    final pantryItems = await pantryService.getAllPantryItem();

    Map<int, int> missingCounts = {};

    for (var i = 0; i < allRecipes.length; i++) {
      final recipe = allRecipes[i];
      int missing = 0;

      for (final ingredient in recipe.ingredients) {
        final reqName = (ingredient.name ?? '').trim().toLowerCase();
        final reqQty = ingredient.quantity ?? 0.0;
        if (reqQty <= 0.0) continue;

        final bool hasEnough = pantryItems.any((item) {
          final pantryName = item.name.trim().toLowerCase();
          final pantryQty = item.quantity ?? 0.0;
          return pantryName == reqName &&
              pantryQty >= reqQty &&
              item.unit == ingredient.unit;
        });

        if (!hasEnough) missing++;
      }
      missingCounts[i] = missing;
    }

    List<int> sortedIndices = missingCounts.keys.toList();
    sortedIndices.sort(
      (a, b) => missingCounts[a]!.compareTo(missingCounts[b]!),
    );

    final random = Random();
    final topCount = min(3, sortedIndices.length);
    final winnerIndex = sortedIndices[random.nextInt(topCount)];

    return allRecipes[winnerIndex];
  }

  Future<List<RecommendedRecipe>> getRecommendations(
    Tag cuisine,
    Tag mealType,
  ) async {
    final allRecipes = await isar.recipes.where().findAll();
    final pantryItems = await pantryService
        .getAllPantryItem(); // vagy isar.pantryItems...

    List<RecommendedRecipe> results = [];

    for (final recipe in allRecipes) {
      await recipe.tags.load();
      if (!recipe.tags.contains(cuisine) || !recipe.tags.contains(mealType)) {
        continue;
      }

      List<String> missing = [];

      for (final ingredient in recipe.ingredients) {
        final reqName = (ingredient.name ?? '').trim().toLowerCase();
        final reqQty = ingredient.quantity ?? 0.0;

        if (reqQty <= 0.0) continue;

        final bool hasEnough = pantryItems.any((item) {
          final pantryName = item.name.trim().toLowerCase();
          final pantryQty = item.quantity ?? 0.0;
          return pantryName == reqName &&
              pantryQty >= reqQty &&
              item.unit == ingredient.unit;
        });

        if (!hasEnough) {
          missing.add(ingredient.name ?? 'Unknown ingredient');
        }
      }

      results.add(
        RecommendedRecipe(recipe: recipe, missingIngredients: missing),
      );
    }

    results.sort(
      (a, b) =>
          a.missingIngredients.length.compareTo(b.missingIngredients.length),
    );

    return results;
  }

  Future<void> saveRecipe(Recipe recipe, List<Tag> selectedTags) async {
    await isar.writeTxn(() async {
      await isar.recipes.put(recipe);

      await recipe.tags.load();
      final selectedIds = selectedTags.map((t) => t.id).toSet();
      final currentIds = recipe.tags.map((t) => t.id).toSet();

      final tagsToRemove = recipe.tags
          .where((t) => !selectedIds.contains(t.id))
          .toList();
      for (var tag in tagsToRemove) {
        recipe.tags.remove(tag);
      }

      final tagsToAdd = selectedTags
          .where((t) => !currentIds.contains(t.id))
          .toList();
      for (var tag in tagsToAdd) {
        recipe.tags.add(tag);
      }
      await recipe.tags.save();

      // 3. Logolás a tesztekhez
      /*await isar.interactionLogs.put(InteractionLog()
        ..timestamp = DateTime.now()
        ..actionType = 'Action'
        ..target = 'Save_Recipe');*/
    });
  }
}
