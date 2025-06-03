import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/config.dart';
import '../models/recipe.dart';

class FavoriteController {
  static Future<int> addFavorite(int? recipeId) async {
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getInt('userId');
  final token = prefs.getString('token');

  if (recipeId == null || userId == null || token == null) {
    throw Exception('ไม่พบข้อมูลที่จำเป็น');
  }

  final response = await http.post(
    Uri.parse('${AppConfig.baseUrl}/api/favorites'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({
      'recipe_id': recipeId,
      'user_id': userId,
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['count'] ?? 0;
  } else {
    throw Exception('เพิ่มเมนูโปรดล้มเหลว');
  }
}
static Future<int> checkcountFavorite(int recipeId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  if (token == null) throw Exception('Token not found');

  final response = await http.get(
    Uri.parse('${AppConfig.baseUrl}/api/favorites/count/$recipeId'),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['count'] ?? 0;
  } else {
    throw Exception('เช็คเมนูโปรดล้มเหลว');
  }
}



static Future<int> removeFavorite(int? recipeId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  final userId = prefs.getInt('userId');

  if (recipeId == null || userId == null || token == null) {
    throw Exception('ไม่พบ ID ของสูตรอาหารหรือผู้ใช้');
  }

  final response = await http.delete(
    Uri.parse('${AppConfig.baseUrl}/api/favorites/$recipeId'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode != 200) {
    throw Exception('ลบเมนูโปรดล้มเหลว');
  }

  final data = jsonDecode(response.body);
  return data['count'] ?? 0;
}

  static Future<List<Recipe>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/api/favorites'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );


    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Recipe.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load favorites');
    }
  }
 


}
