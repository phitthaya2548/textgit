import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_app/controllers/recipe_controller.dart';
import 'package:my_app/models/recipe.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddRecipeView extends StatefulWidget {
  @override
  _AddRecipeViewState createState() => _AddRecipeViewState();
}

class _AddRecipeViewState extends State<AddRecipeView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _cookTimeController = TextEditingController();

  String? _error;
  String _selectedCategory = 'อาหารคาว';

  final List<String> _categories = [
    'อาหารคาว',
    'อาหารหวาน',
    'อาหารว่าง',
    'เครื่องดื่ม',
    'อาหารเจ',
    'อาหารมังสวิรัติ',
    'อาหารเพื่อสุขภาพ',
    'อาหารนานาชาติ'
  ];

  List<XFile> _images = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickMultipleImages() async {
    final List<XFile>? pickedImages = await _picker.pickMultiImage();
    if (pickedImages != null) {
      setState(() {
        _images = pickedImages;
      });
    }
  }

  void _submitRecipe() async {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      setState(() => _error = 'กรุณากรอกข้อมูลให้ครบถ้วน');
      return;
    }

    final prefs =
        await SharedPreferences.getInstance(); // ✅ ต้อง await ใน method
    final userId = prefs.getInt('userId');

    if (userId == null) {
      setState(() => _error = 'ไม่พบข้อมูลผู้ใช้งาน กรุณาเข้าสู่ระบบใหม่');
      return;
    }

    final recipe = Recipe(
      id: 0,
      title: _titleController.text,
      description: _descriptionController.text,
      cookTime: int.tryParse(_cookTimeController.text) ?? 0,
      createdBy: userId,
      images: [],
    );

    final imageFiles = _images.map((xfile) => File(xfile.path)).toList();

    final success =
        await RecipeController().addRecipeWithImages(recipe, imageFiles);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('เพิ่มสูตรอาหารเรียบร้อย'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      _titleController.clear();
      _descriptionController.clear();
      _cookTimeController.clear();
      setState(() {
        _error = null;
        _images.clear();
      });
    } else {
      setState(() {
        _error = '❌ เกิดข้อผิดพลาดในการบันทึกข้อมูล';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('เพิ่มสูตรอาหาร',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange[700],
        elevation: 0,
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              GestureDetector(
                onTap: _pickMultipleImages,
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _images.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.add_photo_alternate,
                                  size: 50, color: Colors.grey),
                              SizedBox(height: 10),
                              Text('เพิ่มรูปภาพอาหาร',
                                  style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.all(8),
                          itemCount: _images.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(_images[index].path),
                                  width: 120,
                                  height: 160,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'ชื่อเมนู',
                  hintText: 'เช่น ต้มยำกุ้ง, ผัดไทย',
                  prefixIcon:
                      Icon(Icons.restaurant_menu, color: Colors.orange[700]),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        BorderSide(color: Colors.orange[700]!, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'หมวดหมู่',
                  prefixIcon: Icon(Icons.category, color: Colors.orange[700]),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        BorderSide(color: Colors.orange[700]!, width: 2),
                  ),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                      value: category, child: Text(category));
                }).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cookTimeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'เวลาทำ (นาที)',
                  prefixIcon: Icon(Icons.timer, color: Colors.orange[700]),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        BorderSide(color: Colors.orange[700]!, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 6,
                decoration: InputDecoration(
                  labelText: 'รายละเอียด/วิธีทำ',
                  hintText: 'อธิบายขั้นตอนการทำอาหาร',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(bottom: 80),
                    child: Icon(Icons.description, color: Colors.orange[700]),
                  ),
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        BorderSide(color: Colors.orange[700]!, width: 2),
                  ),
                ),
              ),
              if (_error != null)
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[300]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(_error!,
                              style: const TextStyle(color: Colors.red))),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitRecipe,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[700],
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.save),
                    SizedBox(width: 8),
                    Text(
                      'บันทึกสูตรอาหาร',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
