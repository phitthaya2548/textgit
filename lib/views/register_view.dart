import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';

class RegisterView extends StatefulWidget {
  @override
  _RegisterViewState createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _controller = AuthController();
  final _phone = TextEditingController();
  String? _error;
  String _selectedRole = 'user';
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _agreeToTerms = false;

  void _register() async {
    // Form validation
    if (_name.text.isEmpty || _email.text.isEmpty || _password.text.isEmpty || _phone.text.isEmpty) {
      setState(() => _error = "กรุณากรอกข้อมูลให้ครบทุกช่อง");
      return;
    }

    if (_password.text != _confirmPassword.text) {
      setState(() => _error = "รหัสผ่านไม่ตรงกัน กรุณาตรวจสอบอีกครั้ง");
      return;
    }

    if (!_agreeToTerms) {
      setState(() => _error = "กรุณายอมรับข้อตกลงและเงื่อนไขการใช้งาน");
      return;
    }

    setState(() {
      _error = null;
      _isLoading = true;
    });

    try {
      final success = await _controller.register(
        _name.text,
        _email.text,
        _phone.text,
        _password.text,
        _selectedRole,
        
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("ลงทะเบียนสำเร็จ กรุณาเข้าสู่ระบบ"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      } else {
        setState(() => _error = "การลงทะเบียนล้มเหลว อีเมลอาจถูกใช้งานแล้ว");
      }
    } catch (e) {
      setState(() => _error = "เกิดข้อผิดพลาดในการลงทะเบียน");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'สมัครสมาชิก',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 20),

                // App Logo (smaller than login)
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.restaurant,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        "สร้างบัญชีใหม่",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "กรอกข้อมูลเพื่อสร้างบัญชีผู้ใช้ใหม่",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 32),

                // Name Field
                TextField(
                  controller: _name,
                  decoration: InputDecoration(
                    labelText: 'ชื่อ-นามสกุล',
                    hintText: 'กรอกชื่อ-นามสกุล',
                    prefixIcon:
                        Icon(Icons.person_outline, color: Colors.orange),
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

                SizedBox(height: 16),

                // Email Field
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'อีเมล',
                    hintText: 'example@email.com',
                    prefixIcon:
                        Icon(Icons.email_outlined, color: Colors.orange),
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
               SizedBox(height: 16),
TextField(
  controller: _phone,
  keyboardType: TextInputType.phone,
  decoration: InputDecoration(labelText: 'เบอร์โทรศัพท์',
  prefixIcon: Icon(Icons.phone_outlined, color: Colors.orange),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular( 12),
    borderSide: BorderSide(color: Colors.grey[300]!),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: Colors.orange),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: Colors.orange),
  ),
  floatingLabelStyle: TextStyle(color: Colors.orange),
  contentPadding: EdgeInsets.symmetric(vertical: 16),),
),
                SizedBox(height: 16),

                // Password Field
                TextField(
                  controller: _password,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'รหัสผ่าน',
                    hintText: 'อย่างน้อย 8 ตัวอักษร',
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

                SizedBox(height: 16),

                // Confirm Password Field
                TextField(
                  controller: _confirmPassword,
                  obscureText: !_isConfirmPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'ยืนยันรหัสผ่าน',
                    hintText: 'กรอกรหัสผ่านอีกครั้ง',
                    prefixIcon: Icon(Icons.lock_outline, color: Colors.orange),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.grey[600],
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible;
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

                SizedBox(height: 20),

                // Role Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: InputDecoration(
                    labelText: "ประเภทบัญชี",
                    prefixIcon:
                        Icon(Icons.badge_outlined, color: Colors.orange),
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
                  items: [
                    DropdownMenuItem(
                        value: 'user', child: Text('ผู้ใช้ทั่วไป')),
                    DropdownMenuItem(
                        value: 'admin', child: Text('ผู้ดูแลระบบ')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value!;
                    });
                  },
                ),

                SizedBox(height: 24),

                // Terms and Conditions Checkbox
                Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _agreeToTerms,
                        activeColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _agreeToTerms = value!;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          text: 'ฉันยอมรับ',
                          style: TextStyle(color: Colors.grey[700]),
                          children: [
                            TextSpan(
                              text: ' ข้อตกลงและเงื่อนไขการใช้งาน',
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20),

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

                // Register Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _register,
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
                          'สร้างบัญชี',
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

                SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'มีบัญชีผู้ใช้แล้ว? ',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'เข้าสู่ระบบ',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
