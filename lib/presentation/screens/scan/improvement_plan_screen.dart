import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';

class ImprovementPlanScreen extends StatelessWidget {
  const ImprovementPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Improvement Plan'),
        backgroundColor: AppColors.background,
      ),
      body: Center(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.trending_up,
                size: 100,
                color: AppColors.success,
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Improvement Plan Screen',
                style: AppTextStyles.heading1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Personalized improvement recommendations',
                style: AppTextStyles.bodySecondary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              ElevatedButton(
                onPressed: () => context.go('/dashboard'),
                child: const Text('Back to Dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 