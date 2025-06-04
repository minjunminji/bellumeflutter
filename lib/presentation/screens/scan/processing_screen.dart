import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';

class ProcessingScreen extends StatefulWidget {
  const ProcessingScreen({super.key});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  @override
  void initState() {
    super.initState();
    // Simulate processing time
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        context.go('/scan/results-intro');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                strokeWidth: 4,
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Analyzing Your Photos',
                style: AppTextStyles.heading1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Our AI is processing your facial measurements...',
                style: AppTextStyles.bodySecondary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'This may take a few moments',
                style: AppTextStyles.caption,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 