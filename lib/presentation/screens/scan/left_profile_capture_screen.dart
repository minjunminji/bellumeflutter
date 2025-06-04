import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';

class LeftProfileCaptureScreen extends StatelessWidget {
  const LeftProfileCaptureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Left Profile'),
        backgroundColor: AppColors.background,
      ),
      body: Center(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.face_retouching_natural,
                size: 100,
                color: AppColors.primary,
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Left Profile Capture',
                style: AppTextStyles.heading1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Camera integration coming soon',
                style: AppTextStyles.bodySecondary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              ElevatedButton(
                onPressed: () => context.go('/scan/processing'),
                child: const Text('Simulate Capture'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 