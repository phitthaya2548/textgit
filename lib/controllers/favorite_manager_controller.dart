import 'package:flutter/material.dart';
import '../../models/recipe.dart';

class FavoriteManager extends ChangeNotifier {
  static final FavoriteManager instance = FavoriteManager._internal();
  FavoriteManager._internal();

  final List<Recipe> _favorites = [];

  List<Recipe> get favorites => _favorites;

  void addFavorite(Recipe recipe) {
    if (!_favorites.any((r) => r.id == recipe.id)) {
      _favorites.add(recipe);
      notifyListeners();
    }
  }

  void removeFavorite(Recipe recipe) {
    _favorites.removeWhere((r) => r.id == recipe.id);
    notifyListeners();
  }

  bool isFavorite(Recipe recipe) {
    return _favorites.any((r) => r.id == recipe.id);
  }
  void clearFavorites() {
  _favorites.clear();
  notifyListeners();
}

}
