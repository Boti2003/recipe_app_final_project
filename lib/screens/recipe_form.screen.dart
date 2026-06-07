import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_app_final_project/enums/cooking_unit.enum.dart';
import 'package:recipe_app_final_project/enums/tag_type.enum.dart';
import 'package:recipe_app_final_project/main.dart';
import 'package:recipe_app_final_project/models/tag.model.dart';
import 'package:recipe_app_final_project/services/logging.service.dart';
import 'package:recipe_app_final_project/services/recipe.service.dart';
import 'package:recipe_app_final_project/services/tag.service.dart';
import '../models/recipe.model.dart';
import '../theme/app_colors.theme.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

class _IngredientRowData {
  final TextEditingController qtyController;
  CookingUnit unit;
  final TextEditingController nameController;

  _IngredientRowData({
    required this.qtyController,
    required this.unit,
    required this.nameController,
  });
}

class RecipeFormScreen extends StatefulWidget {
  final Recipe? recipe;

  const RecipeFormScreen({super.key, this.recipe});

  @override
  State<RecipeFormScreen> createState() => _RecipeFormScreenState();
}

class _RecipeFormScreenState extends State<RecipeFormScreen> {
  late bool isEditing;
  final TextEditingController _titleController = TextEditingController();
  late RecipeService _recipeService;
  late TagService _tagService;
  LoggingService loggingService = getIt<LoggingService>();
  List<Tag> _allTags = [];
  List<Tag> _selectedTags = [];
  String? _selectedImagePath;
  final ImagePicker _picker = ImagePicker();

  final List<_IngredientRowData> _ingredients = [];
  final List<TextEditingController> _steps = [];

  @override
  void initState() {
    super.initState();
    isEditing = widget.recipe != null;
    _recipeService = getIt<RecipeService>();
    _tagService = getIt<TagService>();
    loggingService.logAction(
      'ScreenView',
      isEditing ? 'EditRecipeScreen' : 'NewRecipeScreen',
    );

    _tagService.getAllTags().then((tags) {
      setState(() {
        _allTags = tags;
      });
    });

    if (isEditing) {
      _titleController.text = widget.recipe!.title;

      for (var ing in widget.recipe!.ingredients) {
        _ingredients.add(
          _IngredientRowData(
            qtyController: TextEditingController(text: ing.quantity.toString()),
            unit: ing.unit ?? CookingUnit.g,
            nameController: TextEditingController(text: ing.name),
          ),
        );
      }

      for (var step in widget.recipe!.steps) {
        _steps.add(TextEditingController(text: step.description));
      }

      _selectedTags = widget.recipe!.tags.toList();
      _selectedImagePath = widget.recipe!.imagePath;
    }
  }

  void _addIngredientRow() {
    setState(() {
      _ingredients.add(
        _IngredientRowData(
          qtyController: TextEditingController(text: '0'),
          unit: CookingUnit.g,
          nameController: TextEditingController(text: ''),
        ),
      );
    });
  }

  Widget _buildStepRow(int index) {
    final controller = _steps[index];

    return Padding(
      key: ObjectKey(controller),
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(
            width: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              '${index + 1}.',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),

          Expanded(
            child: TextField(
              controller: controller,
              decoration: _inputDecoration(hint: 'Type a step...'),
              maxLines: null,
            ),
          ),
          const SizedBox(width: 8),

          ReorderableDragStartListener(
            index: index,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.open_with, color: Colors.black87),
            ),
          ),
          const SizedBox(width: 8),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(Icons.delete, color: Colors.black87),
              onPressed: () {
                setState(() {
                  controller.dispose();
                  _steps.removeAt(index);
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  void _addStepRow() {
    setState(() {
      _steps.add(TextEditingController());
    });
  }

  void _onReorderSteps(int oldIndex, int newIndex) {
    setState(() {
      final controller = _steps.removeAt(oldIndex);

      _steps.insert(newIndex, controller);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    for (var row in _ingredients) {
      row.qtyController.dispose();
      row.nameController.dispose();
    }
    for (var stepController in _steps) {
      stepController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.purpleButton,
        onPressed: () async {
          Recipe savedRecipe = isEditing ? widget.recipe! : Recipe();
          savedRecipe
            ..title = _titleController.text
            ..imagePath = _selectedImagePath
            ..ingredients = _ingredients
                .map(
                  (row) => RecipeIngredient()
                    ..name = row.nameController.text
                    ..quantity = double.tryParse(row.qtyController.text) ?? 0.0
                    ..unit = row.unit,
                )
                .toList()
            ..steps = _steps
                .map(
                  (controller) => RecipeStep()..description = controller.text,
                )
                .toList();

          await _recipeService.saveRecipe(savedRecipe, _selectedTags);

          if (mounted) {
            loggingService.logAction(
              'RecipeSave',
              isEditing
                  ? 'Edited_${savedRecipe.title}'
                  : 'Created_${savedRecipe.title}',
            );
            Navigator.pop(context, savedRecipe);
          }
        },
        child: const Icon(Icons.save, color: Colors.white, size: 30),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: InkWell(
                            onTap: () {
                              loggingService.logAction(
                                'Navigation',
                                isEditing
                                    ? 'Back_From_EditRecipeScreen'
                                    : 'Back_From_NewRecipeScreen',
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
                        ),
                        Text(
                          isEditing ? 'Edit recipe' : 'New recipe',
                          style: GoogleFonts.italiana(
                            fontSize: 40,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Title',
                                style: GoogleFonts.robotoSerif(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _titleController,
                                decoration: InputDecoration(
                                  hintText: 'Type title',
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
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),

                        Expanded(
                          flex: 4,
                          child: AspectRatio(
                            aspectRatio: 1.0,
                            child: InkWell(
                              onTap: _pickImage,
                              borderRadius: BorderRadius.circular(15),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.editBox,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.05,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),

                                child: _selectedImagePath != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: kIsWeb
                                            ? Image.network(
                                                _selectedImagePath!,
                                                fit: BoxFit.cover,
                                              )
                                            : Image.file(
                                                File(_selectedImagePath!),
                                                fit: BoxFit.cover,
                                              ),
                                      )
                                    : const Center(
                                        child: Icon(
                                          Icons.camera_alt_outlined,
                                          size: 80,
                                          color: Colors.black87,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.editBox,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ingredients',
                            style: GoogleFonts.robotoSerif(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),

                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _ingredients.length,
                            itemBuilder: (context, index) {
                              return _buildIngredientRow(index);
                            },
                          ),

                          const SizedBox(height: 12),

                          Center(
                            child: InkWell(
                              onTap: _addIngredientRow,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: AppColors.purpleButton,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
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
                        color: AppColors.editBox,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Steps',
                            style: GoogleFonts.robotoSerif(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),

                          ReorderableListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            buildDefaultDragHandles: false,
                            itemCount: _steps.length,
                            onReorderItem: _onReorderSteps,
                            itemBuilder: (context, index) {
                              return _buildStepRow(index);
                            },
                          ),

                          const SizedBox(height: 12),

                          Center(
                            child: InkWell(
                              onTap: _addStepRow,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: AppColors.purpleButton,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
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
                        color: AppColors.editBox,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tags',
                            style: GoogleFonts.robotoSerif(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),

                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _selectedTags.map((tag) {
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
                                  pillColor = Colors.grey;
                                  break;
                              }

                              return Chip(
                                backgroundColor: pillColor,
                                label: Text(tag.name),
                                deleteIcon: const Icon(Icons.close, size: 18),
                                onDeleted: () {
                                  setState(() {
                                    _selectedTags.removeWhere(
                                      (t) => t.id == tag.id,
                                    );
                                  });
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                side: BorderSide.none,
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 12),

                          Center(
                            child: InkWell(
                              onTap: _showTagSelectionDialog,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: AppColors.purpleButton,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIngredientRow(int index) {
    final rowData = _ingredients[index];

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              controller: rowData.qtyController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration(),
            ),
          ),
          const SizedBox(width: 8),

          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<CookingUnit>(
                  value: rowData.unit,
                  isExpanded: true,
                  items: CookingUnit.values.map((unit) {
                    return DropdownMenuItem(
                      value: unit,
                      child: Text(unit.name),
                    );
                  }).toList(),
                  onChanged: (newUnit) {
                    if (newUnit != null) {
                      setState(() => rowData.unit = newUnit);
                    }
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          Expanded(
            flex: 4,
            child: TextField(
              controller: rowData.nameController,
              decoration: _inputDecoration(hint: 'flour'),
            ),
          ),
          const SizedBox(width: 8),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(Icons.delete, color: Colors.black87),
              onPressed: () {
                setState(() {
                  rowData.qtyController.dispose();
                  rowData.nameController.dispose();
                  _ingredients.removeAt(index);
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }

  Future<void> _pickImage() async {
    final bool isDesktopOrWeb =
        kIsWeb ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux;

    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              if (!isDesktopOrWeb)
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Take a photo'),
                  onTap: () => Navigator.of(context).pop(ImageSource.camera),
                ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImagePath = pickedFile.path;
      });
    }
  }

  Future<void> _showTagSelectionDialog() async {
    List<Tag> tempSelectedTags = List.from(_selectedTags);

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: const Text('Select Tags'),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: TagType.values.map((tagType) {
                      final tagsInType = _allTags
                          .where((t) => t.type == tagType)
                          .toList();

                      if (tagsInType.isEmpty) return const SizedBox.shrink();

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tagType.name.toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),

                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: tagsInType.map((tag) {
                                final isSelected = tempSelectedTags.any(
                                  (t) => t.id == tag.id,
                                );

                                Color baseColor;
                                switch (tag.type) {
                                  case TagType.cuisine:
                                    baseColor = AppColors.tagCuisine;
                                    break;
                                  case TagType.mealType:
                                    baseColor = AppColors.tagMealType;
                                    break;
                                  case TagType.dietaryPreference:
                                    baseColor = AppColors.tagDietary;
                                    break;
                                  default:
                                    baseColor = Colors.grey;
                                    break;
                                }

                                return InkWell(
                                  onTap: () {
                                    setDialogState(() {
                                      if (isSelected) {
                                        tempSelectedTags.removeWhere(
                                          (t) => t.id == tag.id,
                                        );
                                      } else {
                                        tempSelectedTags.add(tag);
                                      }
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFF1B1464)
                                          : baseColor,
                                      borderRadius: BorderRadius.circular(20),
                                      border: isSelected
                                          ? Border.all(
                                              color: Colors.white,
                                              width: 2,
                                            )
                                          : Border.all(
                                              color: Colors.transparent,
                                              width: 2,
                                            ),
                                    ),
                                    child: Text(
                                      tag.name,
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.black87,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedTags = List.from(tempSelectedTags);
                    });
                    Navigator.pop(dialogContext);
                  },
                  child: const Text(
                    'Apply',
                    style: TextStyle(
                      color: AppColors.purpleButton,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
