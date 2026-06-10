import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'home_screen.dart';
import 'trek_list_screen.dart';
import 'saved_routes_screen.dart';
import 'profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int currentIndex = 0;

  final screens = const [
    HomeScreen(),
    TrekListScreen(),
    SavedRoutesScreen(),
    ProfileScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: AppColors.brand,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: selected ? AppColors.brand : AppColors.textGrey,
            );
          }),
        ),
        child: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (index) =>
              setState(() => currentIndex = index),
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.home_outlined, color: AppColors.textGrey),
                selectedIcon: Icon(Icons.home, color: Colors.white),
                label: 'Home'),
            NavigationDestination(
                icon: Icon(Icons.terrain_outlined, color: AppColors.textGrey),
                selectedIcon: Icon(Icons.terrain, color: Colors.white),
                label: 'Treks'),
            NavigationDestination(
                icon: Icon(Icons.bookmark_border, color: AppColors.textGrey),
                selectedIcon: Icon(Icons.bookmark, color: Colors.white),
                label: 'Saved'),
            NavigationDestination(
                icon: Icon(Icons.person_outline, color: AppColors.textGrey),
                selectedIcon: Icon(Icons.person, color: Colors.white),
                label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
