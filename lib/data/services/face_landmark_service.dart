import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'dart:async'; // Added for Completer

class FaceLandmarkService {
  static final FaceLandmarkService _instance = FaceLandmarkService._internal();
  factory FaceLandmarkService() => _instance;
  FaceLandmarkService._internal();

  late FaceDetector _faceDetector;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final options = FaceDetectorOptions(
        enableContours: true,
        enableLandmarks: true,
        performanceMode: FaceDetectorMode.accurate, // Added for better accuracy
        enableClassification: false,
        enableTracking: false,
      );
      
      _faceDetector = FaceDetector(options: options);
      _isInitialized = true;
      print('Face landmark service initialized successfully with Google ML Kit');
    } catch (e) {
      print('Failed to initialize face landmark service: $e');
      _isInitialized = false;
    }
  }

  Future<ui.Image> _decodeImage(Uint8List jpegBytes) {
    final completer = Completer<ui.Image>();
    ui.decodeImageFromList(jpegBytes, completer.complete);
    return completer.future;
  }

  Uint8List _rgbaToBgra(Uint8List rgbaBytes) {
    final bgraBytes = Uint8List(rgbaBytes.length);
    for (var i = 0; i < rgbaBytes.length; i += 4) {
      bgraBytes[i] = rgbaBytes[i + 2]; // Blue
      bgraBytes[i + 1] = rgbaBytes[i + 1]; // Green
      bgraBytes[i + 2] = rgbaBytes[i];   // Red
      bgraBytes[i + 3] = rgbaBytes[i + 3]; // Alpha
    }
    return bgraBytes;
  }

  Future<List<ui.Offset>> detectLandmarks(Uint8List jpegImageBytes) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final ui.Image decodedImage = await _decodeImage(jpegImageBytes);
      final imageWidth = decodedImage.width;
      final imageHeight = decodedImage.height;

      final ByteData? rgbaByteData = await decodedImage.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (rgbaByteData == null) {
        print('Failed to get RGBA byte data from image.');
        return [];
      }
      final Uint8List rgbaBytes = rgbaByteData.buffer.asUint8List();
      final Uint8List bgraBytes = _rgbaToBgra(rgbaBytes);

      final inputImage = InputImage.fromBytes(
        bytes: bgraBytes,
        metadata: InputImageMetadata(
          size: ui.Size(imageWidth.toDouble(), imageHeight.toDouble()), 
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormat.bgra8888, 
          bytesPerRow: imageWidth * 4, 
        ),
      );

      final faces = await _faceDetector.processImage(inputImage);
      
      if (faces.isEmpty) {
        print('No faces detected by FaceLandmarkService');
        return []; // Return empty list, not mock landmarks for this specific service
      }

      final face = faces.first;
      final landmarks = <ui.Offset>[];

      void addLandmark(FaceLandmark? landmark) {
        if (landmark != null) {
          landmarks.add(ui.Offset(landmark.position.x.toDouble(), landmark.position.y.toDouble()));
        }
      }

      // Extract specific landmarks
      addLandmark(face.landmarks[FaceLandmarkType.leftEye]);
      addLandmark(face.landmarks[FaceLandmarkType.rightEye]);
      addLandmark(face.landmarks[FaceLandmarkType.noseBase]);
      addLandmark(face.landmarks[FaceLandmarkType.leftCheek]);
      addLandmark(face.landmarks[FaceLandmarkType.rightCheek]);
      addLandmark(face.landmarks[FaceLandmarkType.leftMouth]);
      addLandmark(face.landmarks[FaceLandmarkType.rightMouth]);
      addLandmark(face.landmarks[FaceLandmarkType.bottomMouth]);

      // Add all contour points
      face.contours.forEach((_, contour) {
        if (contour != null) {
          for (final point in contour.points) {
            landmarks.add(ui.Offset(point.x.toDouble(), point.y.toDouble()));
          }
        }
      });
      
      print('FaceLandmarkService Detected ${landmarks.length} facial landmarks');
      return landmarks;
    } catch (e) {
      print('Error in FaceLandmarkService detecting landmarks: $e');
      return [];
    }
  }

  void dispose() {
    if (_isInitialized) {
      _faceDetector.close();
      _isInitialized = false;
    }
  }
} 