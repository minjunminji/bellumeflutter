import 'package:flutter/material.dart';
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

class _MainNavigationScreenState extends State<MainNavigationScreen> 
    with TickerProviderStateMixin {
  int _currentIndex = 1; // Start with dashboard (middle tab)
  late AnimationController _indicatorController;
  late Animation<double> _indicatorAnimation;

  // List of screens for each tab
  final List<Widget> _screens = [
    const ChatScreen(),
    const DashboardScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _indicatorController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _indicatorAnimation = Tween<double>(
      begin: _currentIndex.toDouble(),
      end: _currentIndex.toDouble(),
    ).animate(CurvedAnimation(
      parent: _indicatorController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _indicatorController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index != _currentIndex) {
      setState(() {
        _indicatorAnimation = Tween<double>(
          begin: _currentIndex.toDouble(),
          end: index.toDouble(),
        ).animate(CurvedAnimation(
          parent: _indicatorController,
          curve: Curves.easeInOut,
        ));
        _currentIndex = index;
      });
      _indicatorController.forward(from: 0);
    }
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
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(
            top: BorderSide(
              color: Colors.grey,
              width: 0.5,
            ),
          ),
        ),
        child: Container(
          height: 50 + MediaQuery.of(context).padding.bottom,
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
          child: Column(
            children: [
              // Indicator section with animated sliding line
              Container(
                height: 2, // Made thinner (was 3)
                child: Stack(
                  children: [
                    // Background line
                    Container(
                      width: double.infinity,
                      height: 2,
                      color: Colors.grey.shade300,
                    ),
                    // Animated indicator line
                    AnimatedBuilder(
                      animation: _indicatorAnimation,
                      builder: (context, child) {
                        final screenWidth = MediaQuery.of(context).size.width;
                        final tabWidth = screenWidth / 3;
                        final position = _indicatorAnimation.value * tabWidth;
                        
                        return Positioned(
                          left: position,
                          child: Container(
                            width: tabWidth,
                            height: 2,
                            color: AppColors.primary,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              // Icon section
              Expanded(
                child: Row(
                  children: [
                    _buildNavBarItem(
                      index: 0,
                      unfilledIcon: 'icons/chatunfill.svg',
                      filledIcon: 'icons/chatfill.svg',
                    ),
                    _buildNavBarItem(
                      index: 1,
                      unfilledIcon: 'icons/dashunfill.svg',
                      filledIcon: 'icons/dashfill.svg',
                    ),
                    _buildNavBarItem(
                      index: 2,
                      unfilledIcon: 'icons/profileunfill.svg',
                      filledIcon: 'icons/profilefill.svg',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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

  Widget _buildNavBarItem({
    required int index,
    required String unfilledIcon,
    required String filledIcon,
  }) {
    final isActive = _currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        child: Container(
          height: 48, // Fixed height instead of 60
          child: Center(
            child: SvgPicture.asset(
              isActive ? filledIcon : unfilledIcon,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                isActive ? AppColors.primary : AppColors.textLight,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
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