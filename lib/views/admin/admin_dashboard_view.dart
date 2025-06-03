import 'package:flutter/material.dart';
import '../admin/add_recipe_view.dart';
import '../admin/manage_users_view.dart';
import 'posted_recipes_view.dart';
class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('แดชบอร์ดผู้ดูแลระบบ'),
        centerTitle: true,
        backgroundColor: Colors.orange[700],
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/login');
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'เมนูจัดการ',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.orange[800],
              ),
            ),
            const SizedBox(height: 20),
            _buildCardButton(
              context,
              icon: Icons.food_bank_outlined,
              title: 'ดูรายการอาาหาร',
              color: Colors.orange,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PostedRecipesView()),
                );
              },
            ),
             const SizedBox(height: 20),
            _buildCardButton(
              context,
              icon: Icons.receipt_long,
              title: 'จัดการสูตรอาหาร',
              color: Colors.orange,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddRecipeView()),
                );
              },
            ),
            const SizedBox(height: 20),
            _buildCardButton(
              context,
              icon: Icons.people,
              title: 'จัดการผู้ใช้งาน',
              color: Colors.blueGrey,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ManageUsersView()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
