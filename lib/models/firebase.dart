import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../config/config.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> signInWithGoogle() async {
    try {
      // ✅ เริ่มต้น Google Sign-In
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return false;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) return false;

      // ✅ ดึง idToken จาก Firebase
      final idToken = await user.getIdToken();
      final prefs = await SharedPreferences.getInstance();

      // ✅ เรียก backend เพื่อแลก token + user info
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/firebase-login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'firebase_token': idToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final backendToken = data['token'];
        final userData = data['user'];
        await prefs.setString('token', backendToken);
        await prefs.setInt('userId', userData['id']);
        await prefs.setString('userEmail', userData['email']);
        await prefs.setString('userName', userData['name']);
        await prefs.setString('userPhoto', user.photoURL ?? '');
        await prefs.setBool('isLoggedIn', true); // ✅ เพิ่มบรรทัดนี้


        return true;
      } else {
        print('❌ Backend responded with ${response.statusCode}');
        print(response.body);
        return false;
      }
    } catch (e) {
      print('🔥 Google Sign-In Error: $e');
      return false;
    }
  }
}
