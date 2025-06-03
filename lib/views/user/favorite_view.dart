import 'package:flutter/material.dart';
import '../../controllers/favorite_controller.dart';
import '../../controllers/favorite_manager_controller.dart';
import '../../models/recipe.dart';

class FavoriteView extends StatefulWidget {
  const FavoriteView({super.key});

  @override
  State<FavoriteView> createState() => _FavoriteViewState();
}

class _FavoriteViewState extends State<FavoriteView> {
  List<Recipe> _favorites = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final favorites = await FavoriteController.getFavorites();
      FavoriteManager.instance.clearFavorites();
      favorites.forEach(FavoriteManager.instance.addFavorite);
      setState(() => _favorites = FavoriteManager.instance.favorites);
    } catch (e) {
      debugPrint('❌ Failed to load favorites: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(),
      body: _favorites.isEmpty ? _buildEmptyView() : _buildFavoritesList(),
    );
  }

  AppBar _buildAppBar() => AppBar(
        backgroundColor: Colors.orange,
        elevation: 1,
        centerTitle: true,
        title: const Text(
          'เมนูที่กด ❤️',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
        ),
      );

  Widget _buildEmptyView() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('ยังไม่มีเมนูที่คุณชื่นชอบ', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
          ],
        ),
      );

  Widget _buildFavoritesList() => ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        itemCount: _favorites.length,
        itemBuilder: (context, index) => _buildRecipeCard(_favorites[index]),
      );

  Widget _buildRecipeCard(Recipe recipe) => Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRecipeImages(recipe),
            _buildRecipeInfo(recipe),
          ],
        ),
      );

  Widget _buildRecipeImages(Recipe recipe) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: Stack(
          children: [
            recipe.images.isNotEmpty
                ? SizedBox(
                    height: 200,
                    child: PageView.builder(
                      itemCount: recipe.images.length,
                      itemBuilder: (context, imgIndex) => Image.network(
                        'http://10.0.2.2:8080${recipe.images[imgIndex]}',
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildImageError(),
                      ),
                    ),
                  )
                : _buildImageError(),
            _buildCookTimeBadge(recipe),
          ],
        ),
      );

  Widget _buildImageError() => Container(
        height: 200,
        color: Colors.grey[200],
        alignment: Alignment.center,
        child: Icon(Icons.image_not_supported, size: 48, color: Colors.grey[400]),
      );

  Widget _buildCookTimeBadge(Recipe recipe) => Positioned(
        top: 12,
        right: 12,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.access_time, size: 16, color: Colors.white),
              const SizedBox(width: 4),
              Text('${recipe.cookTime} นาที', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      );

  Widget _buildRecipeInfo(Recipe recipe) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    recipe.title,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    FavoriteManager.instance.isFavorite(recipe)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: FavoriteManager.instance.isFavorite(recipe) ? Colors.red : Colors.grey,
                    size: 26,
                  ),
                  splashRadius: 24,
                  tooltip: FavoriteManager.instance.isFavorite(recipe) ? 'ลบออกจากรายการโปรด' : 'เพิ่มในรายการโปรด',
                  onPressed: () => _toggleFavorite(recipe),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              recipe.description,
              style: const TextStyle(fontSize: 14, color: Colors.grey, height: 1.4),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text('รายละเอียด'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange,
                      side: const BorderSide(color: Colors.orange),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('ทำอาหาร'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  void _toggleFavorite(Recipe recipe) {
    final isFavoriteNow = FavoriteManager.instance.isFavorite(recipe);

    setState(() {
      if (isFavoriteNow) {
        FavoriteManager.instance.removeFavorite(recipe);
      } else {
        FavoriteManager.instance.addFavorite(recipe);
      }
    });

    final snackBar = SnackBar(
      content: Row(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 400),
            builder: (context, scale, child) => Transform.scale(
              scale: scale,
              child: Icon(
                isFavoriteNow ? Icons.favorite_border : Icons.favorite,
                color: isFavoriteNow ? Colors.white : Colors.red,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              isFavoriteNow ? 'ลบออกจากรายการโปรดแล้ว' : 'เพิ่มลงในรายการโปรดเรียบร้อย',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor: isFavoriteNow ? Colors.red : Colors.green,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      duration: const Duration(seconds: 3),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
