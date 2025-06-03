import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/profile.dart';
import '../config/config.dart';

class ProfileController {
  Future<Profile> fetchUserProfile(String token) async {
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/api/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      return Profile.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to load profile (status ${response.statusCode})');
    }
  }

 Future<Profile> updateUserProfile({
  required String token, 
  required int id,       
  required String name,
  required String email,
  required String phone,
  File? profileImage,
}) async {
  final uri = Uri.parse('${AppConfig.baseUrl}/api/profile/$id');

  final request = http.MultipartRequest('PUT', uri);

  request.headers['Authorization'] = 'Bearer $token';
  request.fields['name'] = name;
  request.fields['email'] = email;
  request.fields['phone'] = phone;

  if (profileImage != null) {
    final imageFile = await http.MultipartFile.fromPath(
      'profile_picture',
      profileImage.path,
    );
    request.files.add(imageFile);
  }

  final streamedResponse = await request.send();

  final response = await http.Response.fromStream(streamedResponse);

  if (response.statusCode == 200) {
    return Profile.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('อัปเดตโปรไฟล์ไม่สำเร็จ (${response.statusCode})');
  }
}




}
