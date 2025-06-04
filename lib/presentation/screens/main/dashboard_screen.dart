import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_decorations.dart';
import '../../providers/auth_provider.dart';
import '../scan/scan_screen.dart';
import 'main_navigation_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Add top padding for status bar
            SizedBox(height: MediaQuery.of(context).padding.top + 4),
            
            // Bellume title - now aligned with body content
            Text(
              'Bellume',
              style: AppTextStyles.heading2.copyWith(
                color: AppColors.primary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Separator line
            Container(
              height: 1,
              color: AppColors.textLight.withOpacity(0.2),
            ),
            
            const SizedBox(height: AppSpacing.xl),
            
            // Latest Scan Results Section
            _buildLatestResultsSection(context),
            
            const SizedBox(height: AppSpacing.xl),
            
            // Quick Stats Section
            _buildQuickStatsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildLatestResultsSection(BuildContext context) {
    // For demo purposes, we'll show placeholder content
    // In a real app, this would check for existing scan results
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Latest Results',
          style: AppTextStyles.heading2,
        ),
        const SizedBox(height: AppSpacing.md),
        
        // Placeholder for no results yet
        Container(
          padding: AppSpacing.cardPadding,
          decoration: AppDecorations.cardDecoration,
          child: Column(
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 48,
                color: AppColors.textLight,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'No scans yet',
                style: AppTextStyles.heading2.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => const ScanScreen(),
                      transitionDuration: const Duration(milliseconds: 300),
                      reverseTransitionDuration: const Duration(milliseconds: 300),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
                    ),
                  );
                },
                child: const Text('Start Your First Scan'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Stats',
          style: AppTextStyles.heading2,
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.camera_alt,
                title: 'Total Scans',
                value: '0',
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildStatCard(
                icon: Icons.trending_up,
                title: 'Improvements',
                value: '0',
                color: AppColors.success,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: AppDecorations.cardDecoration,
      child: Column(
        children: [
          Icon(
            icon,
            size: 32,
            color: color,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTextStyles.heading1.copyWith(
              color: color,
            ),
          ),
          Text(
            title,
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
} 