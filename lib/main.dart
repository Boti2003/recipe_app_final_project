import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';
import 'package:isar/isar.dart';
import 'package:recipe_app_final_project/initialization/seed_tags.dart';
import 'package:recipe_app_final_project/models/interaction_log.model.dart';
import 'package:recipe_app_final_project/models/pantry_item.model.dart';
import 'package:recipe_app_final_project/models/recipe.model.dart';
import 'package:recipe_app_final_project/models/tag.model.dart';
import 'package:recipe_app_final_project/screens/home.screen.dart';
import 'package:recipe_app_final_project/services/logging.service.dart';
import 'package:recipe_app_final_project/services/pantry.service.dart';
import 'package:recipe_app_final_project/services/recipe.service.dart';
import 'package:recipe_app_final_project/services/tag.service.dart';

final getIt = GetIt.instance;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open([
    RecipeSchema,
    PantryItemSchema,
    InteractionLogSchema,
    TagSchema,
  ], directory: dir.path);

  getIt.registerSingleton<Isar>(isar);

  getIt.registerSingleton<TagService>(TagService(isar));
  getIt.registerSingleton<PantryService>(PantryService(isar));
  getIt.registerSingleton<RecipeService>(
    RecipeService(isar, getIt<PantryService>()),
  );
  getIt.registerSingleton<LoggingService>(LoggingService(isar));

  await seedTagsFromJson();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );
  }
}
