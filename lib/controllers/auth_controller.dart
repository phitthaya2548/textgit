import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../config/config.dart';
import '../models/user.dart';

class AuthController {
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final user = AppUser.fromJson(data['user']);
        final token = data['token'];

        return {
          'user': user,
          'token': token,
        };
      } else {
        return null;
      }
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

static Future<String> forgotPassword(String email, String phone, String newPassword) async {
  try {
    if (email.isEmpty || phone.isEmpty || newPassword.isEmpty) {
      return "❌ กรุณากรอกข้อมูลให้ครบถ้วน";
    }

    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/api/update-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'phone': phone,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode == 200) {
      return "เปลี่ยนรหัสผ่านสำเร็จ";
    } else {
      return "⚠️ Firebase สำเร็จ แต่ SQL ไม่สำเร็จ (${response.statusCode})";
    }
  } catch (e) {
    return "❌ เปลี่ยนรหัสผ่านล้มเหลว: $e";
  }
}


  Future<bool> register(String name, String email, String phone,
      String password, String role) async {
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/api/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'role': role,
      }),
    );
    return response.statusCode == 201;
  }
}
