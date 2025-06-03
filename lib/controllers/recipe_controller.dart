import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/config.dart';
import '../models/recipe.dart';

class RecipeController {
  Future<bool> addRecipeWithImages(Recipe recipe, List<File> images) async {
    var uri = Uri.parse('http://10.0.2.2:8080/api/recipes');
    var request = http.MultipartRequest('POST', uri);

    request.fields.addAll(recipe.toFields());

    for (var i = 0; i < images.length; i++) {
      var file = await http.MultipartFile.fromPath(
        'images',
        images[i].path,
      );
      request.files.add(file);
    }

    var response = await request.send();
    return response.statusCode == 201;
  }
  Future<void> deleteRecipe(int id) async {
  final uri = Uri.parse('${AppConfig.baseUrl}/api/recipes/$id');
  final response = await http.delete(uri);

  if (response.statusCode != 200) {
    throw Exception('Failed to delete recipe');
  }
  
}
Future<bool> updateRecipe(Recipe recipe) async {
  final uri = Uri.parse('${AppConfig.baseUrl}/api/recipes/${recipe.id}');
  final bodyData = jsonEncode(recipe.toJson());

  print('📤 PUT $uri');
  print('📦 Body: $bodyData');

  final response = await http.put(
    uri,
    headers: {'Content-Type': 'application/json'},
    body: bodyData,
  );

  print('📡 Status code: ${response.statusCode}');
  print('📨 Response: ${response.body}');

  if (response.statusCode == 200) {
    return true;
  } else {
    return false;
  }
}


  Future<List<Recipe>> fetchAllRecipes() async {
    final response =
        await http.get(Uri.parse('${AppConfig.baseUrl}/api/recipes'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Recipe.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load recipes');
    }
  }



  Future<List<Recipe>> searchRecipes(String query) async {
    final uri = Uri.parse('http://10.0.2.2:8080/api/recipes?search=$query');
    final res = await http.get(uri);

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((json) => Recipe.fromJson(json)).toList();
    } else {
      throw Exception('ค้นหาไม่สำเร็จ');
    }
  }
}
