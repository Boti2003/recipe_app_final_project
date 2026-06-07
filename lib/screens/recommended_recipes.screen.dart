import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_app_final_project/main.dart';
import 'package:recipe_app_final_project/models/tag.model.dart';
import 'package:recipe_app_final_project/screens/recipe_detail.screen.dart';
import 'package:recipe_app_final_project/services/logging.service.dart';
import 'package:recipe_app_final_project/services/recipe.service.dart';
import '../theme/app_colors.theme.dart'; // Módosítsd a te útvonaladra

class RecommendedRecipesScreen extends StatefulWidget {
  final Tag selectedCuisine;
  final Tag selectedType;

  // A képernyő megnyitásakor át kell adni, hogy mit keresünk
  const RecommendedRecipesScreen({
    super.key,
    required this.selectedCuisine,
    required this.selectedType,
  });

  @override
  State<RecommendedRecipesScreen> createState() =>
      _RecommendedRecipesScreenState();
}

class _RecommendedRecipesScreenState extends State<RecommendedRecipesScreen> {
  List<RecommendedRecipe> _recommendations = [];
  bool _isLoading = true;
  RecipeService recipeService = getIt<RecipeService>();
  LoggingService loggingService = getIt<LoggingService>();

  @override
  void initState() {
    super.initState();
    _fetchRecommendations();
  }

  Future<void> _fetchRecommendations() async {
    final results = await recipeService.getRecommendations(
      widget.selectedCuisine,
      widget.selectedType,
    );

    if (mounted) {
      setState(() {
        _recommendations = results;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      loggingService.logAction(
                        'Navigation',
                        'Back_From_RecommendedRecipeScreen',
                      );
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(50),
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
                      'Recommendations',
                      style: GoogleFonts.italiana(
                        fontSize: 36,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _recommendations.isEmpty
                  ? Center(
                      child: Text(
                        'No recipes found for ${widget.selectedCuisine.name} ${widget.selectedType.name}.',
                        style: GoogleFonts.robotoSerif(fontSize: 18),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Container(
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
                          itemCount: _recommendations.length,
                          itemBuilder: (context, index) {
                            return _buildFigmaRecipeCard(
                              _recommendations[index],
                            );
                          },
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFigmaRecipeCard(RecommendedRecipe item) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          loggingService.logAction(
            'Navigation',
            'To_RecipeDetailScreen_From_RecommendedRecipeScreen',
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeDetailScreen(recipe: item.recipe),
            ),
          );
        },
        borderRadius: BorderRadius.circular(15),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      item.recipe.title,
                      style: GoogleFonts.italiana(
                        fontSize: 28,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textColor,
                      ),
                    ),
                  ),
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: VerticalDivider(
                  color: Colors.black87,
                  thickness: 1,
                  width: 1,
                ),
              ),

              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Missing',
                        style: GoogleFonts.italiana(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      if (item.missingIngredients.isEmpty)
                        Text(
                          '• None!',
                          style: GoogleFonts.robotoSerif(
                            fontSize: 14,
                            color: Colors.green,
                          ),
                        )
                      else
                        ...item.missingIngredients.map(
                          (missingItem) => Text(
                            '• $missingItem',
                            style: GoogleFonts.robotoSerif(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                    ],
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
