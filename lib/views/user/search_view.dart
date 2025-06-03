import 'package:flutter/material.dart';
import '../../controllers/favorite_controller.dart';
import '../../controllers/favorite_manager_controller.dart';
import '../../controllers/recipe_controller.dart';
import '../../models/recipe.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _searchController = TextEditingController();
  final RecipeController _controller = RecipeController();
  List<Recipe> _results = [];
  List<Recipe> _favorites = [];
  bool _isLoading = false;
  String? _error;

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
      print('❌ โหลดเมนูโปรดล้มเหลว: $e');
    }
  }

  Future<void> _search() async {
    final keyword = _searchController.text.trim();
    if (keyword.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await _controller.searchRecipes(keyword);
      setState(() => _results = results);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.orange,
        title: const Text('ค้นหาสูตรอาหาร'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSearchField(),
            const SizedBox(height: 16),
            if (_isLoading)
              const CircularProgressIndicator(color: Colors.orange),
            if (_error != null)
              Text('❌ $_error', style: const TextStyle(color: Colors.red)),
            if (!_isLoading && _results.isNotEmpty)
              Expanded(child: _buildResultsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() => TextField(
        controller: _searchController,
        decoration: InputDecoration(
          labelText: 'พิมพ์ชื่อเมนู',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              setState(() => _results.clear());
            },
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onSubmitted: (_) => _search(),
      );

  Widget _buildResultsList() => ListView.builder(
        itemCount: _results.length,
        itemBuilder: (context, index) => _buildRecipeCard(_results[index]),
      );

  Widget _buildRecipeCard(Recipe recipe) => Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRecipeImage(recipe),
            _buildRecipeInfo(recipe),
          ],
        ),
      );

  Widget _buildRecipeImage(Recipe recipe) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: recipe.images.isNotEmpty
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
      );

  Widget _buildImageError() => Container(
        height: 200,
        color: Colors.grey[200],
        alignment: Alignment.center,
        child: const Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
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
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                  tooltip: FavoriteManager.instance.isFavorite(recipe)
                      ? 'ลบออกจากรายการโปรด'
                      : 'เพิ่มในรายการโปรด',
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
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
      ),
    );
  }
}
