import 'package:flutter/material.dart';
import '../../models/recipe.dart';

class RecipeDetailView extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailView({Key? key, required this.recipe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(recipe.title),
        backgroundColor: Colors.orange,
        elevation: 2,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // ✅ รูปภาพเมนูอาหาร
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: recipe.images.isNotEmpty
                    ? SizedBox(
                        height: 220,
                        child: PageView.builder(
                          itemCount: recipe.images.length,
                          itemBuilder: (context, imgIndex) {
                            return Image.network(
                              'http://10.0.2.2:8080${recipe.images[imgIndex]}',
                              width: double.infinity,
                              height: 220,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                height: 220,
                                color: Colors.grey[200],
                                alignment: Alignment.center,
                                child: Icon(Icons.broken_image,
                                    size: 48, color: Colors.grey[400]),
                              ),
                            );
                          },
                        ),
                      )
                    : Container(
                        height: 220,
                        color: Colors.grey[300],
                        alignment: Alignment.center,
                        child: Icon(Icons.image_not_supported,
                            size: 48, color: Colors.grey[500]),
                      ),
              ),
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.timer, size: 16, color: Colors.white),
                      SizedBox(width: 6),
                      Text('${recipe.cookTime} นาที',
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 24),

          // ✅ ชื่อเมนู
          Text(
            recipe.title,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          SizedBox(height: 12),

          // ✅ กล่องคำอธิบาย
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              recipe.description,
              style:
                  TextStyle(fontSize: 16, color: Colors.grey[800], height: 1.6),
            ),
          ),

          SizedBox(height: 28),

          // ✅ รายละเอียดย่อย เช่น portion / calorie (optionally add more)
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.access_time, color: Colors.orange),
                  title: Text('เวลาทำอาหาร'),
                  trailing: Text('${recipe.cookTime} นาที'),
                ),
                Divider(),
              ],
            ),
          ),

          SizedBox(height: 28),

          // ✅ ปุ่มทำอาหาร
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => _buildTimerDialog(context, recipe),
                );
              },
              icon: Icon(Icons.restaurant_menu),
              label: Text('เริ่มทำอาหาร'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14),
                textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildTimerDialog(BuildContext context,Recipe recipe) {
  int seconds = 0;
  late final ValueNotifier<int> timeLeft;
  timeLeft = ValueNotifier(seconds);

  void startTimer() {
    seconds = recipe.cookTime * 60;
    timeLeft.value = seconds;
    Future.doWhile(() async {
      await Future.delayed(Duration(seconds: 1));
      if (timeLeft.value > 0) {
        timeLeft.value--;
        return true;
      }
      return false;
    });
  }

  startTimer();

  return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: EdgeInsets.only(top: 24),
      contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      title: Column(
        children: [
          Icon(Icons.timer, size: 48, color: Colors.orange),
          SizedBox(height: 8),
          Text(
            '⏱ กำลังทำอาหาร',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      content: ValueListenableBuilder<int>(
        valueListenable: timeLeft,
        builder: (context, value, _) {
          final minutes = (value ~/ 60).toString().padLeft(2, '0');
          final secs = (value % 60).toString().padLeft(2, '0');
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 8),
              Text(
                '$minutes:$secs',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange,
                  letterSpacing: 2,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'อย่าลืมเช็คอาหารนะ! 🍳',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          );
        },
      ),
      actionsPadding: EdgeInsets.only(bottom: 16, right: 12),
      actions: [
        TextButton.icon(
          icon: Icon(Icons.close),
          label: Text('ปิด'),
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: Colors.orange,
            textStyle: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
}
