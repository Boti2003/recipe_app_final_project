import 'package:isar/isar.dart';
import 'package:recipe_app_final_project/models/pantry_item.model.dart';
import 'package:recipe_app_final_project/models/recipe.model.dart';

class PantryService {
  final Isar isar;

  PantryService(this.isar);

  Future<List<PantryItem>> getAllPantryItem() async {
    return await isar.pantryItems.where().findAll();
  }

  Future<void> deletePantryItem(Id id) async {
    await isar.writeTxn(() async {
      await isar.pantryItems.delete(id);
    });
  }

  Future<void> saveRecipe(PantryItem item) async {
    await isar.writeTxn(() async {
      await isar.pantryItems.put(item);
    });
  }

  Future<void> deductIngredients(Recipe recipe, {int servings = 1}) async {
    final pantryItems = await isar.pantryItems.where().findAll();

    await isar.writeTxn(() async {
      for (final ingredient in recipe.ingredients) {
        final reqName = (ingredient.name ?? '').trim().toLowerCase();
        final reqQty = (ingredient.quantity ?? 0.0) * servings;

        if (reqQty <= 0.0) continue;

        try {
          final matchingItem = pantryItems.firstWhere((item) {
            final pantryName = item.name.trim().toLowerCase();
            final pantryQty = item.quantity ?? 0.0;

            return pantryName == reqName &&
                item.unit == ingredient.unit &&
                pantryQty >= reqQty;
          });

          matchingItem.quantity = (matchingItem.quantity ?? 0.0) - reqQty;

          await isar.pantryItems.put(matchingItem);
        } catch (e) {
          print(
            'Error: there is not enough ${ingredient.name} in the pantry to deduct for recipe ${recipe.title}',
          );
        }
      }
    });
  }
}
