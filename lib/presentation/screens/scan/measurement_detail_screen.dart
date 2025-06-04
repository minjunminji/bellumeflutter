import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';

class MeasurementDetailScreen extends StatelessWidget {
  const MeasurementDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Measurement Details'),
        backgroundColor: AppColors.background,
      ),
      body: Center(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.straighten,
                size: 100,
                color: AppColors.primary,
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Measurement Detail Screen',
                style: AppTextStyles.heading1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Detailed measurement information',
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