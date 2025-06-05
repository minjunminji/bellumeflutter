import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:google_mlkit_face_mesh_detection/google_mlkit_face_mesh_detection.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';

class FaceMeshService {
  static final FaceMeshService _instance = FaceMeshService._internal();
  factory FaceMeshService() => _instance;
  FaceMeshService._internal();

  late FaceMeshDetector _faceMeshDetector;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      final options = FaceMeshDetectorOptions.faceMesh;
      _faceMeshDetector = FaceMeshDetector(option: options); 
      _isInitialized = true;
      print('Face mesh service initialized successfully with Google ML Kit');
    } catch (e) {
      print('Failed to initialize face mesh service: $e');
      _isInitialized = false;
    }
  }

  Future<List<ui.Offset>> detectMesh(Uint8List jpegImageBytes) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Write JPEG bytes to a temporary file
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/temp_face_image_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await tempFile.writeAsBytes(jpegImageBytes);

      // Try different image rotations for side profiles
      final List<InputImageRotation> rotations = [
        InputImageRotation.rotation0deg,   // Original orientation
        InputImageRotation.rotation90deg,  // Try rotating for side profiles
        InputImageRotation.rotation270deg, // Try other rotation
      ];

      List<ui.Offset> bestResult = [];
      
      for (final rotation in rotations) {
        try {
          // Create InputImage from file path with different rotations
          final inputImage = InputImage.fromFilePath(tempFile.path);
          
          final List<FaceMesh> meshes = await _faceMeshDetector.processImage(inputImage);
          
          if (meshes.isNotEmpty) {
            final mesh = meshes.first;
            final landmarks = <ui.Offset>[];
            for (final point in mesh.points) {
              landmarks.add(ui.Offset(point.x, point.y));
            }
            
            // If we found more points with this rotation, use it
            if (landmarks.length > bestResult.length) {
              bestResult = landmarks;
              print('FaceMeshService: Found ${landmarks.length} points with rotation $rotation');
            }
            
            // If we found a good number of points, we can stop trying
            if (landmarks.length > 400) {
              break;
            }
          }
        } catch (e) {
          print('FaceMeshService: Error with rotation $rotation: $e');
          continue;
        }
      }
      
      // Clean up temp file
      try {
        await tempFile.delete();
      } catch (e) {
        print('Warning: Could not delete temp file: $e');
      }
      
      if (bestResult.isEmpty) {
        print('No face meshes detected by FaceMeshService with any rotation');
        return [];
      }

      print('FaceMeshService Detected ${bestResult.length} face mesh points (best result)');
      return bestResult;
    } catch (e) {
      print('Error in FaceMeshService detecting face mesh: $e');
      return [];
    }
  }

  void dispose() {
    if (_isInitialized) {
      _faceMeshDetector.close();
      _isInitialized = false;
    }
  }
} 