import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';

class ResultsSummaryScreen extends StatelessWidget {
  const ResultsSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Results Summary'),
        backgroundColor: AppColors.background,
      ),
      body: Center(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.summarize,
                size: 100,
                color: AppColors.primary,
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Results Summary Screen',
                style: AppTextStyles.heading1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Summary of all measurements',
                style: AppTextStyles.bodySecondary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              ElevatedButton(
                onPressed: () => context.go('/scan/improvement-plan'),
                child: const Text('View Improvement Plan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 