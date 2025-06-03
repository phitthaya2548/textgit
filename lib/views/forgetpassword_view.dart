import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../controllers/auth_controller.dart';

class PhoneResetPasswordView extends StatefulWidget {
  @override
  _PhoneResetPasswordViewState createState() => _PhoneResetPasswordViewState();
}

class _PhoneResetPasswordViewState extends State<PhoneResetPasswordView> {
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();

  String? _verificationId;
  String? _message;
  bool _otpSent = false;
  bool _isLoading = false;

  String formatThaiPhone(String phone) {
    phone = phone.trim().replaceAll(' ', '').replaceAll('-', '');
    if (phone.startsWith('0') && phone.length == 10) {
      return '+66' + phone.substring(1);
    } else if (phone.startsWith('+66')) {
      return phone;
    } else {
      return '';
    }
  }

  Future<void> _sendOTP() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });

    final rawPhone = _phoneController.text.trim();
    final formattedPhone = formatThaiPhone(rawPhone);

    if (formattedPhone.isEmpty) {
      setState(() {
        _message =
            "❌ รูปแบบเบอร์ไม่ถูกต้อง ต้องเป็น 08xxxxxxxx หรือ +66xxxxxxxxx";
        _isLoading = false;
      });
      return;
    }

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: formattedPhone,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
        setState(() => _message = "✅ ยืนยันอัตโนมัติแล้ว");
      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() => _message = "❌ ส่ง OTP ล้มเหลว: ${e.message}");
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
          _otpSent = true;
          _message = "📩 ส่ง OTP สำเร็จแล้ว";
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );

    setState(() => _isLoading = false);
  }

  Future<void> _verifyOTPAndChangePassword() async {
    final smsCode = _otpController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    if (_verificationId == null ||
        smsCode.isEmpty ||
        newPassword.length < 6 ||
        email.isEmpty ||
        phone.isEmpty) {
      setState(() =>
          _message = "❌ กรุณากรอกข้อมูลให้ครบ (OTP, Email, Phone, รหัสผ่าน)");
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;

      await user!.updatePassword(newPassword);

      final result =
          await AuthController.forgotPassword(email, phone, newPassword);

      setState(() {
        _message = result;

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _message = "❌ ยืนยัน OTP ล้มเหลว: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("เปลี่ยนรหัสผ่านผ่านเบอร์โทร"),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SvgPicture.asset(
                      'assets/images/mobilephone_79875 1.svg',
                      color: Colors.orange,
                      height: 24,
                      width: 24,
                    ),
                  ),
                  labelText: "เบอร์โทร",
                  labelStyle: TextStyle(
                      color: const Color.fromARGB(255, 133, 130, 125)),
                  hintText: "เบอร์โทร",
                  hintStyle: TextStyle(
                      color: const Color.fromARGB(255, 133, 130, 125)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.orange),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.orange),
                  )),
            ),
            SizedBox(height: 10),
            if (_otpSent)
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "อีเมลที่ผูกไว้",
                  hintText: "example@email.com",
                  border: OutlineInputBorder(),
                ),
              ),
            SizedBox(height: 10),
            if (_otpSent)
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "รหัส OTP",
                  border: OutlineInputBorder(),
                ),
              ),
            SizedBox(height: 10),
            if (_otpSent)
              TextField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "รหัสผ่านใหม่",
                  border: OutlineInputBorder(),
                ),
              ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed:
                        _otpSent ? _verifyOTPAndChangePassword : _sendOTP,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                      shadowColor: const Color.fromARGB(224, 19, 19, 19)
                          .withOpacity(0.9),
                    ),
                    child: Text(
                        _otpSent ? "ยืนยัน OTP และเปลี่ยนรหัสผ่าน" : "ส่ง OTP",
                        style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
                        ),
                  ),
            if (_message != null) ...[
              SizedBox(height: 20),
              Text(
                _message!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _message!.startsWith("✅")
                      ? Colors.green
                      : _message!.startsWith("⚠️")
                          ? Colors.orange
                          : Colors.red,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
