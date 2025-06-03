import 'package:flutter/material.dart';
import '../../controllers/recipe_controller.dart';
import '../../models/recipe.dart';
import '../../routes/app_routes.dart';
import 'edit_recipe_view.dart';
class PostedRecipesView extends StatefulWidget {
  const PostedRecipesView({super.key});

  @override
  State<PostedRecipesView> createState() => _PostedRecipesViewState();
}

class _PostedRecipesViewState extends State<PostedRecipesView> {
  final RecipeController _controller = RecipeController();
  late Future<List<Recipe>> _futureRecipes;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  void _loadRecipes() {
    _futureRecipes = _controller.fetchAllRecipes();
  }

  void _deleteRecipe(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('ยืนยันการลบ'),
        content: Text('คุณแน่ใจหรือไม่ว่าต้องการลบเมนูนี้?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('ยกเลิก')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('ลบ')),
        ],
      ),
    );

    if (confirmed == true) {
      await _controller.deleteRecipe(id);
      setState(() {
        _loadRecipes();
      });
    }
  }

  void _editRecipe(Recipe recipe) {
  Navigator.pushNamed(
  context,
  AppRoutes.editRecipe,
  arguments: recipe,
);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('รายการอาหารที่โพสต์'),
        backgroundColor: Colors.orange[700],
      ),
      body: FutureBuilder<List<Recipe>>(
        future: _futureRecipes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.orange));
          } else if (snapshot.hasError) {
            return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('ยังไม่มีอาหารที่โพสต์'));
          }

          final recipes = snapshot.data!;
          return ListView.builder(
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              return ListTile(
                leading: recipe.images.isNotEmpty
                    ? Image.network('http://10.0.2.2:8080${recipe.images[0]}', width: 50, height: 50, fit: BoxFit.cover)
                    : Icon(Icons.image_not_supported),
                title: Text(recipe.title),
                subtitle: Text('เวลา: ${recipe.cookTime} นาที'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _editRecipe(recipe),
                    ),
                    IconButton(
  icon: Icon(Icons.delete, color: Colors.red),
  onPressed: () => _deleteRecipe(recipe.id), // ✅ ส่ง id ที่ถูกต้องจาก recipe
),

                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
