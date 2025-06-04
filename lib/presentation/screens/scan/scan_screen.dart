import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_decorations.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
        ),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppDecorations.cardDecoration,
              child: Column(
                children: [
                  Icon(
                    Icons.camera_enhance,
                    size: 64,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '3-Photo Facial Analysis',
                    style: AppTextStyles.heading2,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We\'ll guide you through taking 3 photos for the most accurate facial measurements.',
                    style: AppTextStyles.bodySecondary,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Photo Steps
            _buildPhotoStep(
              context,
              stepNumber: 1,
              title: 'Front View',
              description: 'Face the camera directly with a neutral expression',
              icon: Icons.face,
              onTap: () {
                context.push('/scan/front');
              },
            ),
            
            const SizedBox(height: 12),
            
            _buildPhotoStep(
              context,
              stepNumber: 2,
              title: 'Right Profile',
              description: 'Turn your head 90° to the right',
              icon: Icons.face_retouching_natural,
              onTap: () {
                context.push('/scan/right');
              },
            ),
            
            const SizedBox(height: 12),
            
            _buildPhotoStep(
              context,
              stepNumber: 3,
              title: 'Left Profile',
              description: 'Turn your head 90° to the left',
              icon: Icons.face_retouching_natural,
              onTap: () {
                context.push('/scan/left');
              },
            ),
            
            const SizedBox(height: 24),
            
            // Tips
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Tips for Best Results',
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Ensure good lighting\n• Remove glasses if possible\n• Keep a neutral expression\n• Hold the phone steady',
                    style: AppTextStyles.bodySecondary,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Start Button
            ElevatedButton(
              onPressed: () {
                context.push('/scan/front');
              },
              child: const Text('Start Front Photo'),
            ),
            
            // Extra bottom padding
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoStep(
    BuildContext context, {
    required int stepNumber,
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: AppDecorations.cardDecoration,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Text(
            stepNumber.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          title,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          description,
          style: AppTextStyles.bodySecondary,
        ),
        trailing: Icon(
          icon,
          color: AppColors.primary,
          size: 32,
        ),
        onTap: onTap,
      ),
    );
  }
} 