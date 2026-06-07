import 'dart:io';
import 'package:flutter/services.dart';
import 'package:recipe_app_final_project/services/logging.service.dart';
import 'package:shake/shake.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:recipe_app_final_project/screens/pantry.screen.dart';
import 'package:recipe_app_final_project/screens/recipe_detail.screen.dart';
import 'package:recipe_app_final_project/screens/recipe_form.screen.dart';
import 'package:recipe_app_final_project/screens/recommendation.screen.dart';
import 'package:recipe_app_final_project/theme/app_colors.theme.dart';
import '../models/recipe.model.dart';
import '../services/recipe.service.dart';
import '../main.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Recipe> _recipes = [];
  bool _isLoading = true;
  ShakeDetector? _shakeDetector;
  LoggingService loggingService = getIt<LoggingService>();

  @override
  void initState() {
    super.initState();
    _loadRecipes();
    loggingService.logAction('ScreenView', 'HomeScreen');
    _shakeDetector = ShakeDetector.autoStart(
      onPhoneShake: (_) async {
        HapticFeedback.heavyImpact();

        final recipeService = getIt<RecipeService>();

        loggingService.logAction('SensorInput', 'Shake_To_Random_Recipe');
        final randomRecipe = await recipeService.getRandomOptimalRecipe();

        if (randomRecipe != null && mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeDetailScreen(recipe: randomRecipe),
            ),
          ).then((_) {
            _loadRecipes();
          });
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No recipes available yet! Add some first.'),
            ),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _shakeDetector?.stopListening();
    super.dispose();
  }

  Future<void> _loadRecipes({String query = ''}) async {
    setState(() => _isLoading = true);

    final recipeService = getIt<RecipeService>();
    final recipes = query.isEmpty
        ? await recipeService.getAllRecipes()
        : await recipeService.searchRecipes(query);

    setState(() {
      _recipes = recipes;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Recipes',
          style: GoogleFonts.italiana(
            fontSize: 48,
            fontWeight: FontWeight.w500,
            color: AppColors.textColor,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: Colors.grey),
            onPressed: () async {
              await getIt<LoggingService>().exportLogsToFileAndShare();

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Logs copied to clipboard! Paste it anywhere.',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Search',
                style: GoogleFonts.italiana(
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textColor,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _searchController,
                onChanged: (value) => _loadRecipes(query: value),
                decoration: InputDecoration(
                  hintText: 'Type in name of recipe',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: AppColors.searchBox,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _recipes.isEmpty
                  ? Center(
                      child: Container(
                        padding: const EdgeInsets.only(top: 50),
                        child: Text(
                          'No recipes found.',
                          style: GoogleFonts.italiana(
                            fontSize: 28,
                            color: AppColors.textColor,
                          ),
                        ),
                      ),
                    )
                  : Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 20.0,
                      ),
                      padding: const EdgeInsets.fromLTRB(
                        16.0,
                        36.0,
                        16.0,
                        16.0,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.yellowBox,
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _recipes.length,
                        itemBuilder: (context, index) {
                          final recipe = _recipes[index];
                          return Card(
                            color: AppColors.whiteCard,
                            margin: const EdgeInsets.only(bottom: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              title: Text(
                                recipe.title,
                                style: GoogleFonts.italiana(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textColor,
                                ),
                              ),
                              trailing:
                                  recipe.imagePath != null &&
                                      recipe.imagePath!.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(25),
                                      child: SizedBox(
                                        width: 50,
                                        height: 50,
                                        child: kIsWeb
                                            ? Image.network(
                                                recipe.imagePath!,
                                                fit: BoxFit.cover,
                                              )
                                            : Image.file(
                                                File(recipe.imagePath!),
                                                fit: BoxFit.cover,
                                              ),
                                      ),
                                    )
                                  : const Icon(Icons.fastfood),
                              onTap: () {
                                loggingService.logAction(
                                  'Navigation',
                                  'RecipeDetail_From_HomeScreen',
                                );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        RecipeDetailScreen(recipe: recipe),
                                  ),
                                ).then((_) {
                                  _loadRecipes();
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: Container(
        color: AppColors.lightGrey,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.add, size: 30),
              onPressed: () {
                loggingService.logAction(
                  'Navigation',
                  'AddRecipe_From_HomeScreen',
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecipeFormScreen(recipe: null),
                  ),
                ).then((_) {
                  _loadRecipes();
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.auto_awesome, size: 30),
              onPressed: () {
                loggingService.logAction(
                  'Navigation',
                  'RecommendRecipe_From_HomeScreen',
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RecommendationScreen(),
                  ),
                ).then((_) {
                  _loadRecipes();
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.kitchen, size: 30),
              onPressed: () {
                loggingService.logAction(
                  'Navigation',
                  'Pantry_From_HomeScreen',
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PantryScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
