import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/services/camera_service.dart';
import '../../../data/services/facial_landmark_service.dart';

class FrontCaptureScreen extends StatefulWidget {
  const FrontCaptureScreen({super.key});

  @override
  State<FrontCaptureScreen> createState() => _FrontCaptureScreenState();
}

class _FrontCaptureScreenState extends State<FrontCaptureScreen> {
  final CameraService _cameraService = CameraService();
  final FacialLandmarkService _landmarkService = FacialLandmarkService();
  
  bool _isInitialized = false;
  bool _isProcessing = false;
  bool _isCapturing = false;
  String _statusMessage = 'Initializing camera...';
  FaceDetectionResult? _lastDetection;
  Timer? _detectionTimer;
  int _countdownSeconds = 0;
  Timer? _countdownTimer;
  int _frameSkipCounter = 0;
  static const int _frameSkipRate = 10;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _detectionTimer?.cancel();
    _countdownTimer?.cancel();
    _cameraService.stopImageStream();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      setState(() {
        _statusMessage = 'Initializing camera...';
      });

      await _cameraService.initialize();
      await _landmarkService.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _statusMessage = kIsWeb 
              ? 'Camera ready - web platform (limited features)'
              : 'Position your face in the frame';
        });

        // Start image stream for landmark detection (skip on web)
        if (!kIsWeb) {
          await _cameraService.startImageStream(_onCameraImage);
        } else {
          // On web, simulate detection without image stream
          _startWebSimulation();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = 'Camera error: ${e.toString()}';
        });
      }
    }
  }

  void _startWebSimulation() {
    // For web platform, simulate face detection without image stream
    _detectionTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      final detection = _landmarkService.simulateLandmarkDetection();
      setState(() {
        _lastDetection = detection;
        _updateStatusMessage(detection);
      });

      // Check if we should auto-capture (less aggressive on web)
      if (_shouldAutoCapture(detection) && !kIsWeb) {
        _startCountdown();
      } else {
        _cancelCountdown();
      }
    });
  }

  void _onCameraImage(CameraImage image) async {
    _frameSkipCounter++;
    if (_frameSkipCounter % _frameSkipRate != 0) {
      return;
    }

    if (_isProcessing || _isCapturing) return;

    _isProcessing = true;

    try {
      final detection = await _landmarkService.detectLandmarks(image)
          .timeout(const Duration(milliseconds: 500));
      
      if (mounted) {
        setState(() {
          _lastDetection = detection;
          _updateStatusMessage(detection);
        });

        // Check if we should auto-capture
        if (_shouldAutoCapture(detection)) {
          _startCountdown();
        } else {
          _cancelCountdown();
        }
      }
    } catch (e) {
      print('Error processing camera image: $e');
    } finally {
      _isProcessing = false;
    }
  }

  bool _shouldAutoCapture(FaceDetectionResult detection) {
    // Disable auto-capture completely for development
    return false;
    
    // Original logic (disabled for now):
    // return detection.isFaceDetected && 
    //        detection.headPose == HeadPose.frontal && 
    //        detection.confidence > 0.9 &&
    //        !_isCapturing &&
    //        !kIsWeb;
  }

  void _updateStatusMessage(FaceDetectionResult detection) {
    if (!detection.isFaceDetected) {
      _statusMessage = 'No face detected - position yourself in frame';
    } else if (detection.confidence < 0.5) {
      _statusMessage = 'Face detection confidence low - improve lighting';
    } else {
      switch (detection.headPose) {
        case HeadPose.frontal:
          _statusMessage = 'Perfect! Press camera button to capture';
          break;
        case HeadPose.leftProfile:
          _statusMessage = 'Turn your head slightly to the right';
          break;
        case HeadPose.rightProfile:
          _statusMessage = 'Turn your head slightly to the left';
          break;
        case HeadPose.unknown:
          _statusMessage = 'Position your face straight towards camera';
          break;
      }
    }
  }

  void _startCountdown() {
    if (_countdownTimer != null) return; // Already counting down

    _countdownSeconds = 3;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _countdownSeconds--;
      });

      if (_countdownSeconds <= 0) {
        _countdownTimer?.cancel();
        _countdownTimer = null;
        _capturePhoto();
      }
    });
  }

  void _cancelCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    setState(() {
      _countdownSeconds = 0;
    });
  }

  Future<void> _capturePhoto() async {
    if (_isCapturing) return;

    setState(() {
      _isCapturing = true;
      _statusMessage = 'Capturing...';
    });

    try {
      await _cameraService.stopImageStream();
      await Future.delayed(const Duration(milliseconds: 100));
      
      final photo = await _cameraService.takePicture();
      
      if (mounted) {
        // Navigate to photo approval screen
        context.push('/scan/approval', extra: photo.path);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = 'Error capturing photo: ${e.toString()}';
          _isCapturing = false;
        });
        
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (!kIsWeb) {
          try {
            await _cameraService.startImageStream(_onCameraImage);
          } catch (streamError) {
            print('Error restarting image stream: $streamError');
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Front Photo', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isInitialized 
          ? _buildCameraView()
          : _buildInitializingView(),
    );
  }

  Widget _buildInitializingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: AppSpacing.lg),
          Text(
            _statusMessage,
            style: AppTextStyles.body.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCameraView() {
    final controller = _cameraService.controller;
    if (controller == null) {
      return _buildInitializingView();
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Camera preview with proper aspect ratio handling
        _buildCameraPreview(controller),

        // Debug: Facial landmarks overlay
        if (_lastDetection != null) _buildLandmarksOverlay(),

        // Face detection overlay
        if (_lastDetection != null) _buildFaceOverlay(),

        // Debug: Stats overlay
        if (_lastDetection != null) _buildStatsOverlay(),

        // Countdown overlay
        if (_countdownSeconds > 0) _buildCountdownOverlay(),

        // Instructions at bottom
        Positioned(
          bottom: 100,
          left: 0,
          right: 0,
          child: Container(
            margin: AppSpacing.screenPadding,
            padding: AppSpacing.cardPadding,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  _statusMessage,
                  style: AppTextStyles.body.copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Manual capture only - press camera button when ready',
                  style: AppTextStyles.caption.copyWith(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),

        // Manual capture button
        Positioned(
          bottom: 30,
          left: 0,
          right: 0,
          child: Center(
            child: FloatingActionButton(
              onPressed: _isCapturing ? null : _capturePhoto,
              backgroundColor: AppColors.primary,
              child: _isCapturing 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Icon(Icons.camera_alt, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCameraPreview(CameraController controller) {
    final size = MediaQuery.of(context).size;
    
    // For development, let's use a simpler approach that doesn't stretch
    return ClipRect(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: size.width,
          height: size.width / controller.value.aspectRatio,
          child: CameraPreview(controller),
        ),
      ),
    );
  }

  Widget _buildLandmarksOverlay() {
    if (_lastDetection == null || _lastDetection!.landmarks.isEmpty) {
      return const SizedBox.shrink();
    }

    final size = MediaQuery.of(context).size;
    
    return Positioned.fill(
      child: CustomPaint(
        painter: LandmarksPainter(
          landmarks: _lastDetection!.landmarks,
          screenSize: size,
        ),
      ),
    );
  }

  Widget _buildStatsOverlay() {
    if (_lastDetection == null) return const SizedBox.shrink();

    // Calculate pitch and yaw from landmarks (simplified)
    final pitch = _calculatePitch(_lastDetection!.landmarks);
    final yaw = _calculateYaw(_lastDetection!.landmarks);
    final roll = _calculateRoll(_lastDetection!.landmarks);

    return Positioned(
      top: 100,
      left: 20,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'DEBUG STATS',
              style: const TextStyle(
                color: Colors.yellow,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Confidence: ${(_lastDetection!.confidence * 100).toStringAsFixed(1)}%',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
            Text(
              'Head Pose: ${_lastDetection!.headPose.name}',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
            Text(
              'Pitch: ${pitch.toStringAsFixed(1)}°',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
            Text(
              'Yaw: ${yaw.toStringAsFixed(1)}°',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
            Text(
              'Roll: ${roll.toStringAsFixed(1)}°',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
            Text(
              'Landmarks: ${_lastDetection!.landmarks.length}',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  double _calculatePitch(List<FacialLandmark> landmarks) {
    if (landmarks.length < 5) return 0.0;
    
    // Simple pitch calculation using nose and mouth landmarks
    final nose = landmarks[0]; // nose tip
    final leftMouth = landmarks[3];
    final rightMouth = landmarks[4];
    
    final mouthY = (leftMouth.y + rightMouth.y) / 2;
    final pitch = (nose.y - mouthY) * 60; // Scale to degrees
    
    return pitch;
  }

  double _calculateYaw(List<FacialLandmark> landmarks) {
    if (landmarks.length < 3) return 0.0;
    
    // Simple yaw calculation using eye landmarks
    final leftEye = landmarks[1];
    final rightEye = landmarks[2];
    
    final eyeDistance = (rightEye.x - leftEye.x).abs();
    final yaw = (0.5 - (leftEye.x + rightEye.x) / 2) * 120; // Scale to degrees
    
    return yaw;
  }

  double _calculateRoll(List<FacialLandmark> landmarks) {
    if (landmarks.length < 3) return 0.0;
    
    // Simple roll calculation using eye landmarks
    final leftEye = landmarks[1];
    final rightEye = landmarks[2];
    
    final deltaY = rightEye.y - leftEye.y;
    final deltaX = rightEye.x - leftEye.x;
    final roll = (deltaY / deltaX.abs()) * 45; // Scale to degrees
    
    return roll;
  }

  Widget _buildFaceOverlay() {
    // Simple face detection indicator
    return Positioned(
      top: 50,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _lastDetection!.isFaceDetected 
              ? Colors.green.withOpacity(0.8)
              : Colors.red.withOpacity(0.8),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _lastDetection!.isFaceDetected ? Icons.face : Icons.face_retouching_off,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              '${(_lastDetection!.confidence * 100).toInt()}%',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountdownOverlay() {
    return Center(
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.9),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            _countdownSeconds.toString(),
            style: AppTextStyles.heading1.copyWith(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

// Custom painter for drawing facial landmarks
class LandmarksPainter extends CustomPainter {
  final List<FacialLandmark> landmarks;
  final Size screenSize;

  LandmarksPainter({
    required this.landmarks,
    required this.screenSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.cyan
      ..strokeWidth = 2.0
      ..style = PaintingStyle.fill;

    final outlinePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Draw landmarks as small circles
    for (int i = 0; i < landmarks.length; i++) {
      final landmark = landmarks[i];
      
      // Convert normalized coordinates (0-1) to screen coordinates
      final x = landmark.x * size.width;
      final y = landmark.y * size.height;
      
      // Draw landmark point
      canvas.drawCircle(
        Offset(x, y),
        4.0,
        paint,
      );
      
      // Draw white outline
      canvas.drawCircle(
        Offset(x, y),
        4.0,
        outlinePaint,
      );
    }

    // Draw connections between key landmarks
    if (landmarks.length >= 5) {
      final linePaint = Paint()
        ..color = Colors.cyan.withOpacity(0.6)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;

      // Draw lines between eyes
      if (landmarks.length >= 3) {
        _drawLine(canvas, landmarks[1], landmarks[2], linePaint, size);
      }
      
      // Draw lines between mouth corners
      if (landmarks.length >= 5) {
        _drawLine(canvas, landmarks[3], landmarks[4], linePaint, size);
      }
      
      // Draw line from nose to mouth center
      if (landmarks.length >= 5) {
        final mouthCenter = FacialLandmark(
          (landmarks[3].x + landmarks[4].x) / 2,
          (landmarks[3].y + landmarks[4].y) / 2,
          0.0,
        );
        _drawLine(canvas, landmarks[0], mouthCenter, linePaint, size);
      }
    }
  }

  void _drawLine(Canvas canvas, FacialLandmark start, FacialLandmark end, Paint paint, Size size) {
    canvas.drawLine(
      Offset(start.x * size.width, start.y * size.height),
      Offset(end.x * size.width, end.y * size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(LandmarksPainter oldDelegate) {
    return oldDelegate.landmarks != landmarks;
  }
} 