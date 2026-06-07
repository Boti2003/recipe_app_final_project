import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isar/isar.dart';
import 'package:recipe_app_final_project/enums/cooking_unit.enum.dart';
import 'package:recipe_app_final_project/models/pantry_item.model.dart';
import 'package:recipe_app_final_project/screens/add_pantry_item.screen.dart';
import 'package:recipe_app_final_project/screens/record_meal.screen.dart';
import 'package:recipe_app_final_project/services/logging.service.dart';
import 'package:recipe_app_final_project/services/pantry.service.dart';
import 'package:recipe_app_final_project/theme/app_colors.theme.dart';
import '../main.dart';

class PantryScreen extends StatefulWidget {
  const PantryScreen({super.key});

  @override
  State<PantryScreen> createState() => _PantryScreenState();
}

class _PantryScreenState extends State<PantryScreen> {
  List<PantryItem> _pantryItems = [];
  late PantryService pantryService;
  LoggingService loggingService = getIt<LoggingService>();

  int? _editingItemId;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();
  CookingUnit _selectedUnit = CookingUnit.g;

  @override
  void initState() {
    super.initState();
    pantryService = getIt<PantryService>();
    _loadPantryItems();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  Future<void> _loadPantryItems() async {
    final items = await pantryService.getAllPantryItem();
    setState(() {
      _pantryItems = items;
    });
  }

  Future<void> _deleteItem(int id) async {
    await pantryService.deletePantryItem(id);
    _loadPantryItems();
  }

  void _startEditing(PantryItem item) {
    setState(() {
      _editingItemId = item.id;
      _nameController.text = item.name;
      _selectedUnit = item.unit ?? CookingUnit.g;

      if (item.quantity == null || item.quantity == 0) {
        _qtyController.text = '';
      } else if (item.quantity == item.quantity!.toInt()) {
        _qtyController.text = item.quantity!.toInt().toString();
      } else {
        _qtyController.text = item.quantity.toString();
      }
    });
  }

  void _cancelEditing() {
    setState(() {
      _editingItemId = null;
    });
    final item = _pantryItems.firstWhere(
      (i) => i.id == _editingItemId,
      orElse: () => PantryItem()..id = -1,
    );
    if (item.id != -1 && item.name.isEmpty) {
      _deleteItem(item.id);
    }
  }

  Future<void> _saveEditing(PantryItem originalItem) async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) return;

    originalItem.name = newName;
    originalItem.quantity = double.tryParse(_qtyController.text) ?? 0.0;
    originalItem.unit = _selectedUnit;

    await pantryService.saveRecipe(originalItem);

    setState(() {
      _editingItemId = null;
    });
    _loadPantryItems();
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
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          loggingService.logAction(
                            'Navigation',
                            'Back_From_PantryScreen',
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
                      const SizedBox(width: 20),
                      Expanded(
                        child: Text(
                          'Your pantry',
                          style: GoogleFonts.italiana(
                            fontSize: 40,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 36, 20, 20),
                      decoration: BoxDecoration(
                        color: AppColors.yellowBox,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: _pantryItems.isEmpty
                          ? const Text(
                              'Your pantry is empty.',
                              textAlign: TextAlign.center,
                            )
                          : ListView.builder(
                              itemCount: _pantryItems.length,
                              itemBuilder: (context, index) {
                                return _buildPantryItemRow(_pantryItems[index]);
                              },
                            ),
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              bottom: 30,
              left: 24,
              child: ElevatedButton(
                onPressed: () {
                  loggingService.logAction(
                    'Navigation',
                    'RecordMeal_From_PantryScreen',
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RecordMealScreen(),
                    ),
                  ).then((_) {
                    _loadPantryItems();
                  });
                },
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
                  'Record cooking a meal!',
                  style: GoogleFonts.robotoSerif(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 24,
              right: 24,
              child: InkWell(
                onTap: () {
                  loggingService.logAction(
                    'Navigation',
                    'AddPantryItem_From_PantryScreen',
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddPantryItemScreen(),
                    ),
                  ).then((_) {
                    _loadPantryItems();
                  });
                },
                child: Container(
                  width: 65,
                  height: 65,
                  decoration: const BoxDecoration(
                    color: AppColors.purpleButton,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 40),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatQuantity(double? quantity) {
    if (quantity == null || quantity == 0) return '0';

    if (quantity == quantity.toInt()) {
      return quantity.toInt().toString();
    } else {
      return quantity.toString();
    }
  }

  Widget _buildPantryItemRow(PantryItem item) {
    final bool isEditing = _editingItemId == item.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      height: 46,
      padding: const EdgeInsets.only(left: 8, right: 0),
      decoration: BoxDecoration(
        color: AppColors.editBox,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 4,
            child: isEditing
                ? Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 2,
                    ),
                    child: TextField(
                      controller: _nameController,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.robotoSerif(fontSize: 16),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.zero,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      item.name,
                      style: GoogleFonts.robotoSerif(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ),
          ),
          const VerticalDivider(
            color: Colors.black26,
            width: 1,
            indent: 8,
            endIndent: 8,
          ),

          Expanded(
            flex: 3,
            child: isEditing
                ? Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 2,
                    ),
                    child: TextField(
                      controller: _qtyController,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.robotoSerif(fontSize: 16),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.zero,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      _formatQuantity(item.quantity),
                      style: GoogleFonts.robotoSerif(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ),
          ),
          const VerticalDivider(
            color: Colors.black26,
            width: 1,
            indent: 8,
            endIndent: 8,
          ),

          Expanded(
            flex: 2,
            child: isEditing
                ? Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 2,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<CookingUnit>(
                        value: _selectedUnit,
                        isExpanded: true,
                        icon: const SizedBox.shrink(),
                        alignment: Alignment.center,
                        style: GoogleFonts.robotoSerif(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        items: CookingUnit.values.map((unit) {
                          return DropdownMenuItem(
                            value: unit,
                            child: Center(child: Text(unit.name)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedUnit = val);
                        },
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      item.unit?.name ?? CookingUnit.g.name,
                      style: GoogleFonts.robotoSerif(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ),
          ),

          const SizedBox(width: 8),

          Container(
            decoration: const BoxDecoration(
              color: AppColors.tagMealType,

              borderRadius: BorderRadius.only(
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(8),
                topLeft: Radius.circular(4),
                bottomLeft: Radius.circular(4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: isEditing
                  ? [
                      IconButton(
                        icon: const Icon(
                          Icons.check,
                          size: 20,
                          color: Colors.white,
                        ),
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        onPressed: () {
                          loggingService.logAction(
                            'Pantry',
                            'SaveEdit_PantryItem',
                          );
                          _saveEditing(item);
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          size: 20,
                          color: Colors.white,
                        ),
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.only(right: 8, left: 4),
                        onPressed: () {
                          loggingService.logAction(
                            'Pantry',
                            'CancelEdit_PantryItem',
                          );
                          _cancelEditing();
                        },
                      ),
                    ]
                  : [
                      IconButton(
                        icon: const Icon(
                          Icons.edit_outlined,
                          size: 20,
                          color: Colors.black87,
                        ),
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        onPressed: () {
                          loggingService.logAction(
                            'Pantry',
                            'StartEdit_PantryItem',
                          );
                          _startEditing(item);
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          size: 20,
                          color: Colors.black87,
                        ),
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.only(right: 8, left: 4),
                        onPressed: () {
                          loggingService.logAction(
                            'Pantry',
                            'Delete_PantryItem',
                          );
                          _deleteItem(item.id);
                        },
                      ),
                    ],
            ),
          ),
        ],
      ),
    );
  }
}
