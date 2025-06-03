import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:my_app/routes/app_routes.dart';
import '../controllers/auth_controller.dart';
import '../models/firebase.dart';
import '../models/user.dart';
import 'admin/admin_dashboard_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'forgetpassword_view.dart';
class LoginView extends StatefulWidget {
  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _controller = AuthController();
  String? _error;
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  
void _login() async {
  if (_email.text.isEmpty || _password.text.isEmpty) {
    setState(() => _error = "กรุณากรอกอีเมลและรหัสผ่าน");
    return;
  }

  setState(() {
    _error = null;
    _isLoading = true;
  });

  try {
    final result = await _controller.login(_email.text, _password.text);

    if (result != null) {
      final user = result['user'];
      final token = result['token'];
      final userId = user.id;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setInt('userId', userId);
      await prefs.setString('userName', user.name);
      await prefs.setString('userEmail', user.email);
      await prefs.setString('userRole', user.role);
      await prefs.setBool('isLoggedIn', true);


      if (user.role == 'admin') {
        Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.userMain);
      }
    } else {
      setState(() => _error = "อีเมลหรือรหัสผ่านไม่ถูกต้อง");
    }
  } catch (e) {
    print('Login error: $e');
    setState(() => _error = "เกิดข้อผิดพลาดในการเข้าสู่ระบบ");
  } finally {
    setState(() => _isLoading = false);
  }
}


Future<void> _loginWithGoogle() async {
  final authService = FirebaseAuthService();
  final success = await authService.signInWithGoogle();

  if (success) {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isLoggedIn', true);

  Navigator.pushReplacementNamed(context, AppRoutes.userMain);
}

}




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 40),
                
                // Logo and App Name
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.restaurant,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        "ครัวไทย",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "เข้าสู่ระบบเพื่อค้นพบสูตรอาหารที่คุณชื่นชอบ",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 60),
                
                // Email Field
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'อีเมล',
                    hintText: 'example@email.com',
                    prefixIcon: Icon(Icons.email_outlined, color: Colors.orange),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.orange),
                    ),
                    floatingLabelStyle: TextStyle(color: const Color.fromARGB(255, 153, 143, 129)),
                    contentPadding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                
                SizedBox(height: 20),
                
                // Password Field
                TextField(
                  controller: _password,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'รหัสผ่าน',
                    hintText: '••••••••',
                    prefixIcon: Icon(Icons.lock_outline, color: Colors.orange),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible 
                          ? Icons.visibility_off_outlined 
                          : Icons.visibility_outlined,
                        color: Colors.grey[600],
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.orange),
                    ),
                    floatingLabelStyle: TextStyle(color: Colors.orange),
                    contentPadding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                
                // Forgot Password Link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
    context,
    MaterialPageRoute(builder: (context) =>PhoneResetPasswordView()),
  );
                    },
                    child: Text(
                      'ลืมรหัสผ่าน?',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                
                // Error Message
                if (_error != null)
                  Container(
                    padding: EdgeInsets.all(12),
                    margin: EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _error!,
                            style: TextStyle(color: Colors.red[700]),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                SizedBox(height: 20),
                
                // Login Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'เข้าสู่ระบบ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
                
                SizedBox(height: 20),
                
                // Divider
                Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'หรือ',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                
                SizedBox(height: 20),
                
               Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Container(
      width: 56,
      height: 56,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: _loginWithGoogle, // ✅ เรียกฟังก์ชันเมื่อกด
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Image.asset(
            'assets/images/google_logo.png',
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.error, color: Colors.red);
            },
          ),
        ),
      ),
    ),
  ],
),


                SizedBox(height: 40),
                
                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'ยังไม่มีบัญชีผู้ใช้? ',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/register'),
                      child: Text(
                        'สมัครสมาชิก',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
 
}