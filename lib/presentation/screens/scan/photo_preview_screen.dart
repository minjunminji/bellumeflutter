import 'package:flutter/material.dart';
import 'dart:io';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class PhotoPreviewScreen extends StatefulWidget {
  final File imageFile;
  final String photoType; // 'front' or 'side'
  final Function(File) onPhotoApproved;
  
  const PhotoPreviewScreen({
    super.key,
    required this.imageFile,
    required this.photoType,
    required this.onPhotoApproved,
  });

  @override
  State<PhotoPreviewScreen> createState() => _PhotoPreviewScreenState();
}

class _PhotoPreviewScreenState extends State<PhotoPreviewScreen> {
  bool _isProcessing = false;

  String get _title {
    return widget.photoType == 'front' ? 'Review Front Photo' : 'Review Side Photo';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close, color: Colors.white),
        ),
        title: Text(
          _title,
          style: AppTextStyles.heading2.copyWith(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          // Photo Preview
          Expanded(
            child: Container(
              width: double.infinity,
              child: Image.file(
                widget.imageFile,
                fit: BoxFit.contain,
              ),
            ),
          ),
          
          // Action buttons
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Color.fromARGB(220, 0, 0, 0),
                  Colors.transparent,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Text(
                    'How does this look?',
                    style: AppTextStyles.heading2.copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Make sure your face is clearly visible and well-lit.',
                    style: AppTextStyles.bodySecondary.copyWith(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _chooseAnotherPhoto,
                          icon: const Icon(Icons.photo_library, color: Colors.white),
                          label: const Text('Choose Another', style: TextStyle(color: Colors.white)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isProcessing ? null : _approvePhoto,
                          icon: const Icon(Icons.check),
                          label: const Text('Use This Photo'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _chooseAnotherPhoto() {
    Navigator.of(context).pop(); // Go back to selection
  }

  Future<void> _approvePhoto() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Call the callback with the approved image
      widget.onPhotoApproved(widget.imageFile);
      
      // Close this screen
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }
} 