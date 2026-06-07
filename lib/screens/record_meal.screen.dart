import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_app_final_project/main.dart';
import 'package:recipe_app_final_project/services/logging.service.dart';
import 'package:recipe_app_final_project/services/pantry.service.dart';
import 'package:recipe_app_final_project/services/recipe.service.dart';
import '../models/recipe.model.dart';
import '../theme/app_colors.theme.dart';

class RecordMealScreen extends StatefulWidget {
  const RecordMealScreen({super.key});

  @override
  State<RecordMealScreen> createState() => _RecordMealScreenState();
}

class _RecordMealScreenState extends State<RecordMealScreen> {
  List<Recipe> _availableRecipes = [];
  Recipe? _selectedRecipe;
  final TextEditingController _servingsController = TextEditingController(
    text: '1',
  );
  RecipeService recipeService = getIt<RecipeService>();
  PantryService pantryService = getIt<PantryService>();
  LoggingService loggingService = getIt<LoggingService>();

  @override
  void initState() {
    super.initState();
    loggingService.logAction('ScreenView', 'RecordMealScreen');
    _loadAvailableRecipes(1);
  }

  @override
  void dispose() {
    _servingsController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailableRecipes(int servings) async {
    final recipes = await recipeService.findRecipeByEnoughIngredients(
      servings: servings,
    );

    setState(() {
      _availableRecipes = recipes;

      if (_availableRecipes.isNotEmpty) {
        _selectedRecipe = _availableRecipes.first;
      } else {
        _selectedRecipe = null;
      }
    });
  }

  void _onUpgradePantry() async {
    if (_selectedRecipe == null) return;
    final int servings = int.tryParse(_servingsController.text) ?? 0;

    if (servings > 0) {
      await pantryService.deductIngredients(
        _selectedRecipe!,
        servings: servings,
      );
      loggingService.logAction(
        'PantryUpdate',
        'Cooked ${_selectedRecipe!.title} for $servings servings',
      );
      loggingService.logAction('Navigation', 'Back_From_RecordMealScreen');

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          loggingService.logAction(
                            'Navigation',
                            'Back_From_RecordMealScreen',
                          );
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.purpleButton,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Record cooking a meal',
                          style: GoogleFonts.italiana(
                            fontSize: 32,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                  const SizedBox(height: 50),

                  Text(
                    'Recipe',
                    style: GoogleFonts.robotoSerif(
                      fontSize: 26,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: 250,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<Recipe>(
                        value: _selectedRecipe,
                        isExpanded: true,
                        hint: const Text('Select recipe'),
                        icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                        style: GoogleFonts.robotoSerif(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        items: _availableRecipes.map((recipe) {
                          return DropdownMenuItem<Recipe>(
                            value: recipe,
                            child: Text(
                              recipe.title,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedRecipe = val);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  Text(
                    'Servings',
                    style: GoogleFonts.robotoSerif(
                      fontSize: 26,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: 80,
                    child: TextField(
                      controller: _servingsController,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.robotoSerif(fontSize: 16),
                      onChanged: (val) async {
                        await _loadAvailableRecipes(int.tryParse(val) ?? 1);
                      },
                      decoration: InputDecoration(
                        hintText: '0',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              bottom: 30,
              right: 24,
              child: ElevatedButton(
                onPressed: _onUpgradePantry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.purpleButton,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Upgrade pantry!',
                  style: GoogleFonts.robotoSerif(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
