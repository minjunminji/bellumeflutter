import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../data/models/scan_result.dart';
import 'facial_metrics_visualization_screen.dart';

class ScanDetailScreen extends StatefulWidget {
  final ScanResult scanResult;

  const ScanDetailScreen({
    super.key,
    required this.scanResult,
  });

  @override
  State<ScanDetailScreen> createState() => _ScanDetailScreenState();
}

class _ScanDetailScreenState extends State<ScanDetailScreen> {
  bool _isLoading = true;
  ui.Image? _loadedImage;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      final file = File(widget.scanResult.frontImagePath);
      if (!file.existsSync()) {
        throw Exception('Image file not found');
      }

      final bytes = await file.readAsBytes();
      final ui.Image image = await _loadImageFromBytes(bytes);
      
      setState(() {
        _loadedImage = image;
        _isLoading = false;
      });

      // Navigate to visualization after image is loaded
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => FacialMetricsVisualizationScreen(
              frontImage: image,
              meshPoints: [], // Empty mesh points since we don't have them stored
              metrics: widget.scanResult.metrics,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<ui.Image> _loadImageFromBytes(Uint8List bytes) async {
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Loading Scan Details'),
      ),
      body: Center(
        child: _isLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Loading scan visualization...',
                    style: AppTextStyles.bodySecondary,
                  ),
                ],
              )
            : _error != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading scan',
                        style: AppTextStyles.heading2.copyWith(color: Colors.red),
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
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Go Back'),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
      ),
    );
  }
} 