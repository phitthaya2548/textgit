// main_navigation_view.dart
import 'package:flutter/material.dart';
import 'user_home_view.dart';
import 'search_view.dart';
import 'favorite_view.dart';
import 'userprofile_view.dart';
import '../widgets/custom_bottom_nav.dart';

class MainNavigationView extends StatefulWidget {
  const MainNavigationView({super.key});

  @override
  State<MainNavigationView> createState() => _MainNavigationViewState();
}

class _MainNavigationViewState extends State<MainNavigationView> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      UserHomeView(onTabChange: _changeTab),
      SearchView(),
      FavoriteView(),
      ProfileView()
    ];
  }

  void _changeTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: _changeTab,
      ),
    );
  }
}
