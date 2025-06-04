import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_colors.dart';
import 'dashboard_screen.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';
import '../scan/scan_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 1; // Start with dashboard (middle tab)

  // List of screens for each tab
  final List<Widget> _screens = [
    const ChatScreen(),
    const DashboardScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  bool _shouldShowFloatingActionButton() {
    // Hide FAB until user has done their first scan
    // For now, always hide since this is for first-time users
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textLight,
        backgroundColor: AppColors.cardBackground,
        elevation: 8,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'icons/chatunfill.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                AppColors.textLight,
                BlendMode.srcIn,
              ),
            ),
            activeIcon: SvgPicture.asset(
              'icons/chatfill.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                AppColors.primary,
                BlendMode.srcIn,
              ),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'icons/dashunfill.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                AppColors.textLight,
                BlendMode.srcIn,
              ),
            ),
            activeIcon: SvgPicture.asset(
              'icons/dashfill.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                AppColors.primary,
                BlendMode.srcIn,
              ),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'icons/profileunfill.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                AppColors.textLight,
                BlendMode.srcIn,
              ),
            ),
            activeIcon: SvgPicture.asset(
              'icons/profilefill.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                AppColors.primary,
                BlendMode.srcIn,
              ),
            ),
            label: '',
          ),
        ],
      ),
      floatingActionButton: _shouldShowFloatingActionButton() ? FloatingActionButton.extended(
        onPressed: () {
          _navigateToScanWithAnimation();
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.camera_alt),
        label: const Text('Start Scan'),
      ) : null,
    );
  }

  void _navigateToScanWithAnimation() {
    // Get the render box of the FAB to get its position
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const ScanScreen(),
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Get screen size
          final size = MediaQuery.of(context).size;
          
          // FAB position (bottom right)
          final fabOffset = Offset(size.width - 100, size.height - 100);
          
          // Scale animation from FAB position
          return AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              final scale = Tween<double>(
                begin: 0.0,
                end: 1.0,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ));
              
              return Transform.scale(
                scale: scale.value,
                alignment: Alignment.bottomRight,
                child: child,
              );
            },
            child: child,
          );
        },
      ),
    );
  }
} 