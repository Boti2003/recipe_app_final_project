import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_app_final_project/enums/tag_type.enum.dart';
import 'package:recipe_app_final_project/main.dart';
import 'package:recipe_app_final_project/models/tag.model.dart';
import 'package:recipe_app_final_project/screens/recommended_recipes.screen.dart';
import 'package:recipe_app_final_project/services/logging.service.dart';
import 'package:recipe_app_final_project/services/recipe.service.dart';
import 'package:recipe_app_final_project/services/tag.service.dart';
import '../theme/app_colors.theme.dart';

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({super.key});

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  Tag? _selectedMealType;
  Tag? _selectedCuisine;
  List<Tag> _allTags = [];
  TagService tagService = getIt<TagService>();
  RecipeService recipeService = getIt<RecipeService>();
  LoggingService loggingService = getIt<LoggingService>();

  @override
  void initState() {
    super.initState();
    loggingService.logAction('ScreenView', 'RecommendationScreen');
    _loadAllTags();
  }

  Future<void> _loadAllTags() async {
    final tags = await tagService.getAllTags();
    setState(() {
      _allTags = tags;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.purpleButton,
        onPressed: () {
          if (_selectedMealType != null && _selectedCuisine != null) {
            loggingService.logAction(
              'Navigation',
              'To_RecommendedRecipesScreen_From_RecommendationScreen',
            );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RecommendedRecipesScreen(
                  selectedCuisine: _selectedCuisine!,
                  selectedType: _selectedMealType!,
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please select both meal type and cuisine.'),
              ),
            );
          }
        },
        child: const Icon(Icons.auto_awesome, color: Colors.white, size: 30),
      ),

      body: SafeArea(
        child: Padding(
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
                        'Back_From_RecommendationScreen',
                      );
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.purpleButton,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Text(
                      'Recommend a recipe',
                      style: GoogleFonts.italiana(
                        fontSize: 36,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 50),

              Text(
                'What type of food would you like to make?',
                style: GoogleFonts.robotoSerif(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              Container(
                width: 150,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Tag>(
                    value: _selectedMealType,
                    isExpanded: true,
                    hint: const Text(''),
                    icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                    items: _allTags
                        .where((tag) => tag.type == TagType.mealType)
                        .map((Tag tag) {
                          return DropdownMenuItem<Tag>(
                            value: tag,
                            child: Text(tag.name),
                          );
                        })
                        .toList(),

                    onChanged: (newValue) {
                      setState(() {
                        _selectedMealType = newValue;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 40),

              Text(
                'Which cuisine are you craving now?',
                style: GoogleFonts.robotoSerif(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              Container(
                width: 150,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Tag>(
                    value: _selectedCuisine,
                    isExpanded: true,
                    hint: const Text(''),
                    icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                    items: _allTags
                        .where((tag) => tag.type == TagType.cuisine)
                        .map((Tag tag) {
                          return DropdownMenuItem<Tag>(
                            value: tag,
                            child: Text(tag.name),
                          );
                        })
                        .toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedCuisine = newValue;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
