import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

class CameraService {
  static final CameraService _instance = CameraService._internal();
  factory CameraService() => _instance;
  CameraService._internal();

  List<CameraDescription>? _cameras;
  CameraController? _controller;
  bool _isInitialized = false;

  List<CameraDescription>? get cameras => _cameras;
  CameraController? get controller => _controller;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Get available cameras
      _cameras = await availableCameras();
      
      if (_cameras == null || _cameras!.isEmpty) {
        throw Exception('No cameras available on this device');
      }

      print('Found ${_cameras!.length} cameras');
      for (var camera in _cameras!) {
        print('Camera: ${camera.name}, Direction: ${camera.lensDirection}');
      }

      // Find front-facing camera (preferred for facial analysis)
      CameraDescription selectedCamera;
      try {
        selectedCamera = _cameras!.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
        );
        print('Using front camera: ${selectedCamera.name}');
      } catch (e) {
        // If no front camera, use the first available camera
        selectedCamera = _cameras!.first;
        print('No front camera found, using: ${selectedCamera.name}');
      }

      // Initialize camera controller with web-compatible settings
      _controller = CameraController(
        selectedCamera,
        kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high, // Lower resolution for web
        enableAudio: false,
        imageFormatGroup: kIsWeb ? ImageFormatGroup.jpeg : ImageFormatGroup.yuv420, // JPEG for web compatibility
      );

      await _controller!.initialize();
      _isInitialized = true;

      print('Camera service initialized successfully');
      print('Camera resolution: ${_controller!.value.previewSize}');
    } catch (e) {
      print('Error initializing camera service: $e');
      _isInitialized = false;
      rethrow;
    }
  }

  Future<void> startImageStream(void Function(CameraImage) onImage) async {
    if (!_isInitialized || _controller == null) {
      throw Exception('Camera not initialized');
    }

    if (_controller!.value.isStreamingImages) {
      return; // Already streaming
    }

    if (kIsWeb) {
      // Image streaming is not well supported on web, skip for now
      print('Image streaming not supported on web platform');
      return;
    }

    try {
      // Ensure controller is still valid before starting stream
      if (!_controller!.value.isInitialized) {
        await _controller!.initialize();
      }
      
      await _controller!.startImageStream(onImage);
      print('Image stream started');
    } catch (e) {
      print('Error starting image stream: $e');
      rethrow;
    }
  }

  Future<void> stopImageStream() async {
    if (_controller != null && _controller!.value.isStreamingImages) {
      try {
        await _controller!.stopImageStream();
        print('Image stream stopped');
      } catch (e) {
        print('Error stopping image stream: $e');
        // Don't rethrow as this might be called during disposal
      }
    }
  }

  Future<XFile> takePicture() async {
    if (!_isInitialized || _controller == null) {
      throw Exception('Camera not initialized');
    }

    if (!_controller!.value.isInitialized) {
      throw Exception('Camera not ready');
    }

    // Stop image stream if running before taking picture
    if (_controller!.value.isStreamingImages) {
      await stopImageStream();
      // Give a moment for the stream to fully stop
      await Future.delayed(const Duration(milliseconds: 200));
    }

    try {
      final photo = await _controller!.takePicture();
      print('Photo captured: ${photo.path}');
      return photo;
    } catch (e) {
      print('Error taking picture: $e');
      rethrow;
    }
  }

  Future<void> switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) {
      print('Camera switching not available - only ${_cameras?.length ?? 0} cameras found');
      return; // No other cameras available
    }

    final currentCamera = _controller?.description;
    CameraDescription newCamera;

    if (currentCamera?.lensDirection == CameraLensDirection.front) {
      newCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!.first,
      );
    } else {
      newCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first,
      );
    }

    try {
      dispose();
      
      _controller = CameraController(
        newCamera,
        kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: kIsWeb ? ImageFormatGroup.jpeg : ImageFormatGroup.yuv420,
      );

      await _controller!.initialize();
      _isInitialized = true;
      print('Switched to camera: ${newCamera.name}');
    } catch (e) {
      print('Error switching camera: $e');
      rethrow;
    }
  }

  void dispose() {
    try {
      // Stop image stream first if running
      if (_controller?.value.isStreamingImages == true) {
        _controller!.stopImageStream().catchError((e) {
          print('Error stopping image stream during disposal: $e');
        });
      }
      
      _controller?.dispose();
      _controller = null;
      _isInitialized = false;
      print('Camera service disposed');
    } catch (e) {
      print('Error disposing camera service: $e');
    }
  }
} 