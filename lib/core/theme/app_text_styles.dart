import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  static TextStyle get heading1 => GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static TextStyle get heading2 => GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  
  static TextStyle get body => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );
  
  static TextStyle get bodySecondary => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );
  
  static TextStyle get caption => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );
  
  static TextStyle get button => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
} 