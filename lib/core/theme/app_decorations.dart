import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppDecorations {
  static final cardDecoration = BoxDecoration(
    color: AppColors.cardBackground,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );
  
  static final primaryButton = BoxDecoration(
    color: AppColors.primary,
    borderRadius: BorderRadius.circular(8),
  );
  
  static final captureButton = BoxDecoration(
    color: AppColors.primary,
    shape: BoxShape.circle,
    border: Border.all(color: Colors.white, width: 4),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );
} 