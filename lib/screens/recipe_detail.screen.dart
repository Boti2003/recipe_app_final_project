import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_app_final_project/enums/tag_type.enum.dart';
import 'package:recipe_app_final_project/models/recipe.model.dart';
import 'package:recipe_app_final_project/screens/recipe_form.screen.dart';
import 'package:recipe_app_final_project/services/logging.service.dart';
import 'package:recipe_app_final_project/services/recipe.service.dart';
import 'package:recipe_app_final_project/theme/app_colors.theme.dart';

import '../main.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  late Recipe _currentRecipe;
  LoggingService loggingService = getIt<LoggingService>();

  @override
  void initState() {
    super.initState();
    loggingService.logAction('ScreenView', 'RecipeDetailScreen');

    _currentRecipe = widget.recipe;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: InkWell(
                  onTap: () {
                    loggingService.logAction(
                      'Navigation',
                      'Back_From_RecipeDetailScreen',
                    );
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.purpleButton,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      _currentRecipe.title,
                      style: GoogleFonts.italiana(
                        fontSize: 48,
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 0,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.yellowBox,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: Colors.black,
                          ),
                          onPressed: () async {
                            loggingService.logAction(
                              'Navigation',
                              'EditRecipe_From_RecipeDetailScreen',
                            );
                            final updatedRecipe = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    RecipeFormScreen(recipe: _currentRecipe),
                              ),
                            );
                            if (updatedRecipe != null && mounted) {
                              setState(() {
                                _currentRecipe = updatedRecipe as Recipe;
                              });
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.black,
                          ),
                          onPressed: () async {
                            final bool?
                            confirmDeletion = await showDialog<bool>(
                              context: context,
                              builder: (BuildContext dialogContext) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  title: const Text('Delete Recipe'),
                                  content: Text(
                                    'Are you sure you want to delete "${_currentRecipe.title}"?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(
                                        dialogContext,
                                      ).pop(false),
                                      child: const Text(
                                        'Cancel',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(dialogContext).pop(true),
                                      child: const Text(
                                        'Delete',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (confirmDeletion != true) return;

                            final service = getIt<RecipeService>();
                            await service.deleteRecipe(_currentRecipe.id);

                            if (context.mounted) {
                              loggingService.logAction(
                                'Recipe',
                                'Delete_Recipe',
                              );
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.yellowBox,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ingredients',
                              style: GoogleFonts.robotoSerif(
                                fontSize: 22,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 12),

                            ..._currentRecipe.ingredients.map(
                              (ing) => Padding(
                                padding: const EdgeInsets.only(bottom: 4.0),
                                child: Text(
                                  '• ${ing.quantity == ing.quantity?.toInt() ? ing.quantity?.toInt() : ing.quantity} ${ing.unit?.name} ${ing.name}',
                                  style: GoogleFonts.robotoSerif(fontSize: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    Expanded(
                      flex: 4,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.yellowBox,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child:
                            _currentRecipe.imagePath != null &&
                                _currentRecipe.imagePath!.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: kIsWeb
                                    ? Image.network(
                                        _currentRecipe.imagePath!,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.file(
                                        File(_currentRecipe.imagePath!),
                                        fit: BoxFit.cover,
                                      ),
                              )
                            : const Center(
                                child: Icon(
                                  Icons.fastfood,
                                  size: 80,
                                  color: Colors.black87,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.yellowBox,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Steps',
                      style: GoogleFonts.robotoSerif(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),

                    ..._currentRecipe.steps.asMap().entries.map((entry) {
                      int index = entry.key + 1;
                      String stepText = entry.value.description;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6.0),
                        child: Text(
                          '$index. $stepText',
                          style: GoogleFonts.robotoSerif(fontSize: 16),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _currentRecipe.tags.map((tag) {
                  Color pillColor;
                  switch (tag.type) {
                    case TagType.cuisine:
                      pillColor = AppColors.tagCuisine;
                      break;
                    case TagType.mealType:
                      pillColor = AppColors.tagMealType;
                      break;
                    case TagType.dietaryPreference:
                      pillColor = AppColors.tagDietary;
                      break;
                    default:
                      pillColor = Colors.grey.shade300;
                  }

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: pillColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      tag.name,
                      style: GoogleFonts.robotoSerif(
                        color: Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
