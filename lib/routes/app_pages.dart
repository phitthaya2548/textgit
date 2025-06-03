import 'package:flutter/material.dart';
import '../views/login_view.dart';
import '../views/register_view.dart';
import '../views/admin/admin_dashboard_view.dart';
import '../views/user/user_home_view.dart';
import 'app_routes.dart';
import '../views/user/main_navigation_view.dart';
import '../views/admin/edit_recipe_view.dart';

class AppPages {
  static final Map<String, WidgetBuilder> routes = {
    AppRoutes.login: (context) => LoginView(),
    AppRoutes.register: (context) => RegisterView(),
    AppRoutes.adminDashboard: (context) => AdminDashboardView(),
    AppRoutes.userMain: (context) => MainNavigationView(), // ✅ เพิ่ม route นี้
    AppRoutes.editRecipe: (context) => EditRecipeView(), 
  };
}
