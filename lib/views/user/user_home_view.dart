import 'package:flutter/material.dart';
import 'package:my_app/views/user/chatgemini_view.dart';
import 'package:my_app/views/user/favorite_view.dart';
import 'package:flutter/services.dart';
import '../../controllers/favorite_controller.dart';
import '../../controllers/favorite_manager_controller.dart';
import '../../controllers/recipe_controller.dart';
import '../../models/recipe.dart';
import 'recipedetail_view.dart';
import 'search_view.dart';

class UserHomeView extends StatefulWidget {
  final void Function(int index) onTabChange;
  const UserHomeView({super.key, required this.onTabChange});
  @override
  _UserHomeViewState createState() => _UserHomeViewState();
}

class _UserHomeViewState extends State<UserHomeView> {
  final RecipeController _controller = RecipeController();
  late Future<List<Recipe>> _futureRecipes;
  Set<int> _favoriteIds = {};
  int countRecipe = 0;
  bool isFavorite = false;
  int _selectedCategoryIndex = 0;
  final List<String> _categories = [
    'แนะนำ',
    'ยอดนิยม',
    'ทำง่าย',
    'สุขภาพ',
    'มังสวิรัติ'
  ];

  @override
void initState() {
  super.initState();
  _loadFavorites();
  _futureRecipes = _loadRecipesWithCounts();
}


Future<void> _loadFavorites() async {
  try {
    final favorites = await FavoriteController.getFavorites();
    FavoriteManager.instance.clearFavorites();
    favorites.forEach(FavoriteManager.instance.addFavorite);
    setState(() {});
  } catch (e) {
    print('❌ โหลด favorites ล้มเหลว: $e');
  }
}
Future<List<Recipe>> _loadRecipesWithCounts() async {
  final recipes = await _controller.fetchAllRecipes();
  for (var recipe in recipes) {
    final count = await FavoriteController.checkcountFavorite(recipe.id);
    recipe.favoriteCount = count;
  }
  return recipes;
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.orange,
        elevation: 0,
        title: Text(
          'สูตรอาหารแนะนำ',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.black87),
            onPressed: () => widget.onTabChange(1), // ✅ ไปหน้า Search
          ),
          IconButton(
            icon: Icon(Icons.bookmark_border, color: Colors.black87),
            onPressed: () => widget.onTabChange(2), // ✅ ไปหน้า Favorite
          ),
        ],
      ),
      body: Column(
        children: [
          // Categories
          Container(
            height: 60,
            color: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategoryIndex = index;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 12),
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: _selectedCategoryIndex == index
                          ? Colors.orange
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _categories[index],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _selectedCategoryIndex == index
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Recipes List
          Expanded(
            child: FutureBuilder<List<Recipe>>(
              future: _futureRecipes,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child: CircularProgressIndicator(
                    color: Colors.orange,
                  ));
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            size: 48, color: Colors.red[300]),
                        SizedBox(height: 16),
                        Text(
                          'เกิดข้อผิดพลาด: ${snapshot.error}',
                          style: TextStyle(color: Colors.red[300]),
                        ),
                      ],
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.restaurant,
                            size: 64, color: Colors.grey[400]),
                        SizedBox(height: 16),
                        Text(
                          'ยังไม่มีเมนูอาหาร',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final recipes = snapshot.data!;
                return ListView.builder(
                  padding: EdgeInsets.only(top: 16, bottom: 32),
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = recipes[index];
                    
                    return Container(
                      margin: EdgeInsets.fromLTRB(16, 0, 16, 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Recipe Image
                          ClipRRect(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(16)),
                            child: Stack(
                              children: [
                                recipe.images.isNotEmpty
                                    ? SizedBox(
                                        height: 200,
                                        child: PageView.builder(
                                          itemCount: recipe.images.length,
                                          itemBuilder: (context, imgIndex) {
                                            return Image.network(
                                              'http://10.0.2.2:8080${recipe.images[imgIndex]}',
                                              width: double.infinity,
                                              height: 200,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  Container(
                                                height: 200,
                                                color: Colors.grey[200],
                                                alignment: Alignment.center,
                                                child: Icon(
                                                  Icons.broken_image,
                                                  size: 48,
                                                  color: Colors.grey[400],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      )
                                    : Container(
                                        height: 200,
                                        color: Colors.grey[200],
                                        alignment: Alignment.center,
                                        child: Icon(
                                          Icons.image_not_supported,
                                          size: 48,
                                          color: Colors.grey[400],
                                        ),
                                      ),

                                // Cook time badge
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          '${recipe.cookTime} นาที',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Recipe Info
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        recipe.title,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        FavoriteManager.instance
                                                .isFavorite(recipe)
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: FavoriteManager.instance
                                                .isFavorite(recipe)
                                            ? Colors.red
                                            : Colors.grey,
                                        size: 26,
                                      ),
                                      splashRadius: 24,
                                      tooltip: FavoriteManager.instance
                                              .isFavorite(recipe)
                                          ? 'ลบออกจากรายการโปรด'
                                          : 'เพิ่มในรายการโปรด',
                                onPressed: () async {
  final isFavoriteNow = FavoriteManager.instance.isFavorite(recipe);
  setState(() {
    if (isFavoriteNow) {
      FavoriteManager.instance.removeFavorite(recipe);
    } else {
      FavoriteManager.instance.addFavorite(recipe);
    }
  });

  try {
    int newCount = recipe.favoriteCount;
    
    if (isFavoriteNow) {
      newCount = await FavoriteController.removeFavorite(recipe.id);
    } else {
      newCount = await FavoriteController.addFavorite(recipe.id);
    }
    setState(() {
      recipe.favoriteCount = newCount;
    });

  } catch (e) {
    print('❌ เกิดข้อผิดพลาดในการอัปเดต backend: $e');
  }

  HapticFeedback.vibrate();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 400),
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: Icon(
                  isFavoriteNow ? Icons.favorite_border : Icons.favorite,
                  color: isFavoriteNow ? Colors.white : Colors.red,
                ),
              );
            },
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              isFavoriteNow
                  ? 'ลบออกจากรายการโปรดแล้ว'
                  : 'เพิ่มลงในรายการโปรดเรียบร้อย',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor: isFavoriteNow ? Colors.red : Colors.green,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      duration: Duration(seconds: 1),
    ),
  );
},

                                    ),
                                  ],
                                ),
                                Row(
  children: [
    Icon(
      Icons.favorite,
      color: Colors.red,
      size: 18,
    ),
    SizedBox(width: 4),
    Text(
      '${recipe.favoriteCount} คน',
      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
    ),
  ],
),

                                SizedBox(height: 8),
                                Text(
                                  recipe.description,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                    height: 1.4,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RecipeDetailView(recipe: recipe), // ส่งข้อมูล
        ),
      );
    },
                                        child: Text('รายละเอียด'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.orange,
                                          side:
                                              BorderSide(color: Colors.orange),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                      ),
                                    ),
                                   
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
        
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        child: Icon(Icons.chat_bubble_sharp, color: Colors.white, size: 28),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatgeminiView(),
            ),
          );
        },
      )
    );
  }
}
