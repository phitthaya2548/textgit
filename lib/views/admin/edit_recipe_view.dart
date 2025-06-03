import 'package:flutter/material.dart';
import '../../controllers/recipe_controller.dart';
import '../../models/recipe.dart';

class EditRecipeView extends StatefulWidget {
  const EditRecipeView({super.key});

  @override
  State<EditRecipeView> createState() => _EditRecipeViewState();
}

class _EditRecipeViewState extends State<EditRecipeView> {
  late Recipe recipe;
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController cookTimeController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    recipe = ModalRoute.of(context)!.settings.arguments as Recipe;

    titleController = TextEditingController(text: recipe.title);
    descriptionController = TextEditingController(text: recipe.description);
    cookTimeController = TextEditingController(text: recipe.cookTime.toString());
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    cookTimeController.dispose();
    super.dispose();
  }

 void _saveChanges() async {
  final updatedRecipe = Recipe(
    id: recipe.id,
    title: titleController.text,
    description: descriptionController.text,
    cookTime: int.tryParse(cookTimeController.text) ?? 0,
    createdBy: recipe.createdBy,
    images: recipe.images,
  );

  final success = await RecipeController().updateRecipe(updatedRecipe);

  if (success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ บันทึกการแก้ไขเรียบร้อย')),
    );
    Navigator.pop(context);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('❌ บันทึกไม่สำเร็จ')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('แก้ไขเมนู'), backgroundColor: Colors.orange),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'ชื่อเมนู'),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'รายละเอียด'),
            ),
            TextField(
              controller: cookTimeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'เวลาทำ (นาที)'),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveChanges,
              child: Text('💾 บันทึก'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            ),
          ],
        ),
      ),
    );
  }
}
