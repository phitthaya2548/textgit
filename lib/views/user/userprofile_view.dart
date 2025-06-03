import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_app/controllers/profile_controller.dart';
import 'package:my_app/models/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ProfileView extends StatefulWidget {
  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  Profile? _profile;
  String? _errorMessage;
  bool _isEditing = false;
  bool _isSaving = false;
  bool _isLoading = false;
  String imageUrl = '';
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> logout(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      await FirebaseAuth.instance.signOut();
      final googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาดในการออกจากระบบ')),
      );
    }
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw Exception('Token not found');

      final profile = await ProfileController().fetchUserProfile(token);
      _nameController.text = profile.name;
      _emailController.text = profile.email;
      _phoneController.text = profile.phone;

      setState(() {
        _profile = profile;
        _errorMessage = null;
        imageUrl = 'http://10.0.2.2:8080${profile.profilePicture.startsWith("/") ? "" : "/"}${profile.profilePicture}';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'ไม่สามารถโหลดข้อมูลโปรไฟล์ได้';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  bool _validateInput() {
    if (!_emailController.text.contains('@')) {
      setState(() => _errorMessage = 'อีเมลไม่ถูกต้อง');
      return false;
    }
    if (_phoneController.text.length < 9) {
      setState(() => _errorMessage = 'เบอร์โทรศัพท์ต้องมีอย่างน้อย 9 ตัว');
      return false;
    }
    return true;
  }

  Future<void> _saveProfile() async {
    if (!_validateInput()) return;

    try {
      setState(() => _isSaving = true);
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null || _profile == null) throw Exception('Missing token or profile');

      final updated = await ProfileController().updateUserProfile(
        token: token,
        id: _profile!.id,
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        profileImage: _imageFile,
      );

      setState(() {
        _profile = updated;
        _isEditing = false;
        _errorMessage = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('บันทึกสำเร็จ')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาดในการบันทึก')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final selectedFile = File(pickedFile.path);
      setState(() => _imageFile = selectedFile);

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token != null && _profile != null) {
        try {
          await ProfileController().updateUserProfile(
            token: token,
            id: _profile!.id,
            name: _nameController.text,
            email: _emailController.text,
            phone: _phoneController.text,
            profileImage: selectedFile,
          );
          await _loadProfile();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('อัปโหลดรูปสำเร็จ')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('อัปโหลดรูปไม่สำเร็จ')),
          );
        }
      }
    }
  }

  Widget _buildAvatar() {
    return Align(
      alignment: Alignment.center,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.orange,
            backgroundImage: _imageFile != null
                ? FileImage(_imageFile!)
                : (_profile?.profilePicture != null && _profile!.profilePicture.isNotEmpty)
                    ? NetworkImage(imageUrl)
                    : AssetImage('assets/images/google_logo.png') as ImageProvider,
            child: (_imageFile == null && (_profile?.profilePicture == null || _profile!.profilePicture.isEmpty))
                ? Icon(Icons.person, size: 50, color: Colors.white)
                : null,
          ),
          if (_isEditing)
            Positioned(
              bottom: 0,
              right: 0,
              child: InkWell(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.camera_alt, size: 18, color: Colors.orange),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileFields() {
    return _isEditing
        ? Column(
            children: [
              TextField(controller: _nameController, decoration: InputDecoration(labelText: 'ชื่อผู้ใช้')),
              TextField(controller: _emailController, decoration: InputDecoration(labelText: 'อีเมล')),
              TextField(controller: _phoneController, decoration: InputDecoration(labelText: 'โทรศัพท์')),
            ],
          )
        : Column(
            children: [
              Text(_profile?.name ?? '-', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text(_profile?.email ?? '-', style: TextStyle(fontSize: 16, color: Colors.grey[700])),
            ],
          );
  }

  Widget _buildDetailCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          children: [
            ListTile(leading: Icon(Icons.badge, color: Colors.orange), title: Text('ชื่อผู้ใช้'), subtitle: Text(_profile?.name ?? '-')),
            Divider(),
            ListTile(leading: Icon(Icons.email, color: Colors.orange), title: Text('อีเมล'), subtitle: Text(_profile?.email ?? '-')),
            Divider(),
            ListTile(leading: Icon(Icons.phone, color: Colors.orange), title: Text('โทรศัพท์'), subtitle: Text(_profile?.phone ?? '-')),
            Divider(),
            ListTile(leading: Icon(Icons.security, color: Colors.orange), title: Text('บทบาท'), subtitle: Text(_profile?.role ?? '-')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.orange,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.logout),
          tooltip: 'ออกจากระบบ',
          onPressed: () async {
            final confirm = await showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text('ออกจากระบบ'),
                content: Text('คุณแน่ใจหรือไม่ว่าต้องการออกจากระบบ?'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('ยกเลิก')),
                  ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: Text('ตกลง')),
                ],
              ),
            );
            if (confirm == true) {
              logout(context);
            }
          },
        ),
        title: Text('โปรไฟล์ผู้ใช้งาน', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        actions: [
          if (_profile != null)
            IconButton(
              icon: _isSaving
                  ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Icon(_isEditing ? Icons.check : Icons.edit),
              onPressed: _isSaving
                  ? null
                  : () {
                      if (_isEditing) {
                        _saveProfile();
                      } else {
                        setState(() => _isEditing = true);
                      }
                    },
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProfile,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _errorMessage != null
              ? Center(child: Text(_errorMessage!, style: TextStyle(color: Colors.red)))
              : _profile == null
                  ? Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          _buildAvatar(),
                          SizedBox(height: 16),
                          _buildProfileFields(),
                          SizedBox(height: 24),
                          _buildDetailCard(),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }
}
