import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';

class PhotoApprovalScreen extends StatelessWidget {
  const PhotoApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Review Photos'),
        backgroundColor: AppColors.background,
      ),
      body: Center(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 100,
                color: AppColors.success,
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Photo Approval Screen',
                style: AppTextStyles.heading1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Review and approve captured photos',
                style: AppTextStyles.bodySecondary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              ElevatedButton(
                onPressed: () => context.go('/scan/processing'),
                child: const Text('Approve Photos'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 