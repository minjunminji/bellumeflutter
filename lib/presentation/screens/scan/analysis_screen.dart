import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:io';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../data/services/face_mesh_service.dart';
import '../../../data/services/facial_metrics_service.dart';
import '../../../data/services/scan_storage_service.dart';
import '../../providers/scan_history_provider.dart';
import 'facial_metrics_visualization_screen.dart';

class AnalysisScreen extends ConsumerStatefulWidget {
  final ui.Image? frontImage;
  final Uint8List? frontImageBytes;
  final ui.Image? sideImage;
  final Uint8List? sideImageBytes;
  final File? frontImageFile;
  final File? sideImageFile;

  const AnalysisScreen({
    super.key,
    this.frontImage,
    this.frontImageBytes,
    this.sideImage,
    this.sideImageBytes,
    this.frontImageFile,
    this.sideImageFile,
  });

  @override
  ConsumerState<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends ConsumerState<AnalysisScreen> {
  bool _isAnalyzing = true;
  String _currentStep = 'Initializing face detection...';
  List<Offset>? _meshPoints;
  Map<String, dynamic>? _metrics;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startAnalysis();
  }

  Future<void> _startAnalysis() async {
    try {
      setState(() {
        _currentStep = 'Detecting face mesh points...';
      });

      // Use front image for analysis (we haven't implemented side analysis yet)
      final imageToAnalyze = widget.frontImage;
      final imageBytesToAnalyze = widget.frontImageBytes;

      if (imageToAnalyze == null || imageBytesToAnalyze == null) {
        throw Exception('No image provided for analysis');
      }

      // Initialize face mesh service
      final faceMeshService = FaceMeshService();
      await faceMeshService.initialize();

      // Detect face mesh points
      final meshPoints = await faceMeshService.detectMesh(imageBytesToAnalyze);

      if (meshPoints.isEmpty) {
        throw Exception('No face detected in the image. Please try taking a clearer photo.');
      }

      setState(() {
        _meshPoints = meshPoints;
        _currentStep = 'Calculating facial metrics...';
      });

      // Calculate facial metrics
      final metricsService = FacialMetricsService();
      final metrics = await metricsService.calculateFrontProfileMetrics(meshPoints);

      setState(() {
        _metrics = metrics;
        _currentStep = 'Saving results...';
      });

      // Save scan result to local storage
      if (widget.frontImageFile != null) {
        try {
          await ScanStorageService.instance.saveScanResult(
            frontImage: widget.frontImageFile!,
            sideImage: widget.sideImageFile,
            metrics: metrics,
            meshPointsCount: meshPoints.length,
          );
          print('Scan result saved successfully');
          
          // Invalidate scan history providers to refresh dashboard data
          ref.invalidate(scanHistoryProvider);
          ref.invalidate(scanCountProvider);
          ref.invalidate(latestScanProvider);
          ref.invalidate(recentScansProvider);
          ref.invalidate(scanHistoryNotifierProvider);
        } catch (e) {
          print('Error saving scan result: $e');
          // Don't fail the analysis if saving fails
        }
      }

      setState(() {
        _currentStep = 'Analysis complete!';
        _isAnalyzing = false;
      });

      // Wait a moment to show completion, then navigate to results
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => FacialMetricsVisualizationScreen(
              frontImage: imageToAnalyze,
              meshPoints: meshPoints,
              metrics: metrics,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isAnalyzing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Analyzing Your Photos'),
      ),
      body: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_error != null) ...[
              // Error state
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Analysis Failed',
                      style: AppTextStyles.heading2.copyWith(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _error!,
                      style: AppTextStyles.bodySecondary,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Analysis state
              Container(
                padding: const EdgeInsets.all(32),
                decoration: AppDecorations.cardDecoration,
                child: Column(
                  children: [
                    if (_isAnalyzing) ...[
                      const CircularProgressIndicator(
                        strokeWidth: 3,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Analyzing Your Face',
                        style: AppTextStyles.heading2,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _currentStep,
                        style: AppTextStyles.bodySecondary,
                        textAlign: TextAlign.center,
                      ),
                    ] else ...[
                      const Icon(
                        Icons.check_circle,
                        size: 64,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Analysis Complete!',
                        style: AppTextStyles.heading2.copyWith(color: Colors.green),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Redirecting to your results...',
                        style: AppTextStyles.bodySecondary,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Progress indicators
              if (_isAnalyzing) ...[
                Column(
                  children: [
                    _buildProgressStep('Face Detection', _currentStep.contains('face mesh') || !_isAnalyzing),
                    _buildProgressStep('Metrics Calculation', _currentStep.contains('metrics') || !_isAnalyzing),
                    _buildProgressStep('Saving Results', _currentStep.contains('Saving') || !_isAnalyzing),
                    _buildProgressStep('Results Generation', !_isAnalyzing),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgressStep(String title, bool isCompleted) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isCompleted ? Colors.green : AppColors.textSecondary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: AppTextStyles.body.copyWith(
              color: isCompleted ? Colors.green : AppColors.textSecondary,
              fontWeight: isCompleted ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
} 