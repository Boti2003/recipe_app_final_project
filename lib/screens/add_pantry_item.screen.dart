import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isar/isar.dart';
import 'package:recipe_app_final_project/enums/cooking_unit.enum.dart';
import 'package:recipe_app_final_project/models/pantry_item.model.dart';
import 'package:recipe_app_final_project/services/logging.service.dart';
import 'package:recipe_app_final_project/services/pantry.service.dart';
import 'package:recipe_app_final_project/theme/app_colors.theme.dart';
import '../main.dart';

class AddPantryItemScreen extends StatefulWidget {
  const AddPantryItemScreen({super.key});

  @override
  State<AddPantryItemScreen> createState() => _AddPantryItemScreenState();
}

class _AddPantryItemScreenState extends State<AddPantryItemScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();
  CookingUnit _selectedUnit = CookingUnit.g;
  late PantryService pantryService;
  LoggingService loggingService = getIt<LoggingService>();

  @override
  void initState() {
    super.initState();
    loggingService.logAction('ScreenView', 'AddPantryItemScreen');
    pantryService = getIt<PantryService>();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  Future<void> _saveItem() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final quantity = double.tryParse(_qtyController.text) ?? 0.0;

    final newItem = PantryItem()
      ..name = title
      ..quantity = quantity
      ..unit = _selectedUnit;

    await pantryService.saveRecipe(newItem);

    if (mounted) {
      loggingService.logAction(
        'PantryUpdate',
        'Added ${newItem.name} (${newItem.quantity} ${newItem.unit})',
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      floatingActionButton: InkWell(
        onTap: _saveItem,
        child: Container(
          width: 75,
          height: 75,
          decoration: const BoxDecoration(
            color: AppColors.purpleButton,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.save, color: Colors.white, size: 45),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                          'Back_From_AddPantryItemScreen',
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
                    'Add to pantry',
                    style: GoogleFonts.italiana(
                      fontSize: 40,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              const SizedBox(height: 50),

              Text(
                'Title',
                style: GoogleFonts.robotoSerif(
                  fontSize: 26,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _titleController,
                  style: GoogleFonts.robotoSerif(fontSize: 16),
                  decoration: _inputDecoration(hint: 'Type title'),
                ),
              ),
              const SizedBox(height: 30),

              Text(
                'Quantity',
                style: GoogleFonts.robotoSerif(
                  fontSize: 26,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 100,
                child: TextField(
                  controller: _qtyController,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.robotoSerif(fontSize: 16),
                  decoration: _inputDecoration(hint: '0'),
                ),
              ),
              const SizedBox(height: 30),

              Text(
                'Measure',
                style: GoogleFonts.robotoSerif(
                  fontSize: 26,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: 120,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<CookingUnit>(
                    value: _selectedUnit,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                    style: GoogleFonts.robotoSerif(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    items: CookingUnit.values.map((unit) {
                      return DropdownMenuItem(
                        value: unit,
                        child: Text(unit.name),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedUnit = val);
                      }
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

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }
}
