import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:async';
import '../../../data/services/face_mesh_service.dart';
import '../../../data/services/facial_metrics_service.dart';
import 'facial_metrics_visualization_screen.dart';

class DeveloperTestScreen extends StatefulWidget {
  const DeveloperTestScreen({super.key});

  @override
  State<DeveloperTestScreen> createState() => _DeveloperTestScreenState();
}

class _DeveloperTestScreenState extends State<DeveloperTestScreen> {
  final List<String> _imagePaths = [
    'assets/images/front profile.jpg',
    'assets/images/left profile.jpg', 
    'assets/images/right profile.jpg',
  ];

  final List<String> _imageLabels = [
    'Front View',
    'Left Profile',
    'Right Profile',
  ];

  List<Uint8List?> _imageData = [];
  List<ui.Image?> _decodedImages = [];
  List<List<Offset>?> _meshPoints = [];
  Map<String, dynamic>? _facialMetrics;
  bool _isLoading = true;
  bool _isDetecting = false;
  bool _isCalculatingMetrics = false;
  String _status = 'Loading images...';

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    try {
      setState(() => _status = 'Loading images from asset paths...');
      _imageData = List.generate(_imagePaths.length, (_) => null, growable: false);
      _decodedImages = List.generate(_imagePaths.length, (_) => null, growable: false);
      _meshPoints = List.filled(_imagePaths.length, null);

      for (int i = 0; i < _imagePaths.length; i++) {
        final path = _imagePaths[i];
        print('DeveloperTestScreen: Loading image data for: $path');
        try {
          final ByteData data = await rootBundle.load(path);
          _imageData[i] = data.buffer.asUint8List();
          print('DeveloperTestScreen: Successfully loaded image data for: $path, ${_imageData[i]?.length ?? 0} bytes');
          
          if (_imageData[i]?.isNotEmpty == true) {
            // Decode image immediately for caching
            final Completer<ui.Image> decodeCompleter = Completer<ui.Image>();
            ui.decodeImageFromList(_imageData[i]!, (ui.Image img) {
              if (!decodeCompleter.isCompleted) decodeCompleter.complete(img);
            });
            _decodedImages[i] = await decodeCompleter.future.timeout(const Duration(seconds: 10), 
              onTimeout: () {
                print('DeveloperTestScreen: Timeout decoding image for: $path');
                throw 'Timeout decoding image';
              }
            );
            print('DeveloperTestScreen: Successfully DECODED image for: $path, size: ${_decodedImages[i]?.width}x${_decodedImages[i]?.height}');
          } else {
            print('DeveloperTestScreen: Failed to load image data (data is empty after load) for: $path');
          }
        } catch (e,s) {
          print('DeveloperTestScreen: Error loading or initial-decoding image $path: $e\n$s');
          _imageData[i] = null;
          _decodedImages[i] = null;
        }
      }

      setState(() {
        _isLoading = false;
        _status = 'Images loaded successfully. Click "Detect Face Mesh" to analyze.';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _status = 'DeveloperTestScreen: Outer error loading images: $e';
      });
    }
  }

  Future<void> _detectFullMesh() async {
    setState(() {
      _isDetecting = true;
      _status = 'Detecting full face mesh (468 points)...';
      _facialMetrics = null;
    });
    
    try {
      final meshService = FaceMeshService();
      await meshService.initialize();
      
      for (int i = 0; i < _imageData.length; i++) {
        if (_imageData[i]?.isNotEmpty == true) {
          setState(() => _status = 'Processing ${_imageLabels[i]}...');
          
          final meshPoints = await meshService.detectMesh(_imageData[i]!);
          setState(() {
            _meshPoints[i] = meshPoints;
          });
          
          print('Detected ${meshPoints.length} mesh points for ${_imageLabels[i]}');
        } else {
          print('DeveloperTestScreen: Skipping mesh detection for image $i, data is null or empty.');
        }
      }
      
      final totalPoints = _meshPoints.fold<int>(0, (sum, points) => sum + (points?.length ?? 0));
      setState(() {
        _isDetecting = false;
        _status = 'Face mesh detection completed! Total points: $totalPoints';
      });

      // Calculate metrics for front face automatically if detected
      print('DeveloperTestScreen: Checking if front face has mesh points for metrics calculation');
      print('DeveloperTestScreen: _meshPoints[0] is null: ${_meshPoints[0] == null}');
      print('DeveloperTestScreen: _meshPoints[0] length: ${_meshPoints[0]?.length ?? 0}');
      
      if (_meshPoints[0] != null && _meshPoints[0]!.isNotEmpty) {
        print('DeveloperTestScreen: Front face mesh detected, calling _calculateFacialMetrics()');
        _calculateFacialMetrics();
      } else {
        print('DeveloperTestScreen: No front face mesh detected, skipping metrics calculation');
      }
    } catch (e) {
      setState(() {
        _isDetecting = false;
        _status = 'Error detecting face mesh: $e';
      });
    }
  }

  Future<void> _calculateFacialMetrics() async {
    // Only calculate metrics for front profile
    if (_meshPoints[0] == null || _meshPoints[0]!.isEmpty) {
      print('DeveloperTestScreen: No front profile mesh points for metrics calculation');
      setState(() {
        _status = 'No front profile face mesh detected. Cannot calculate metrics.';
      });
      return;
    }

    print('DeveloperTestScreen: Starting facial metrics calculation with ${_meshPoints[0]!.length} mesh points');
    setState(() {
      _isCalculatingMetrics = true;
      _status = 'Calculating facial metrics...';
    });

    try {
      final metricsService = FacialMetricsService();
      print('DeveloperTestScreen: FacialMetricsService created, calling calculateFrontProfileMetrics...');
      final metrics = await metricsService.calculateFrontProfileMetrics(_meshPoints[0]!);
      
      print('DeveloperTestScreen: Metrics calculation completed successfully');
      print('DeveloperTestScreen: Calculated metrics: ${metrics.keys.toList()}');
      
      setState(() {
        _facialMetrics = metrics;
        _isCalculatingMetrics = false;
        _status = 'Facial metrics calculated successfully!';
      });
      
      print('Calculated ${metrics.length} facial metrics for front profile');
    } catch (e, stackTrace) {
      print('DeveloperTestScreen: Error calculating facial metrics: $e');
      print('DeveloperTestScreen: Stack trace: $stackTrace');
      setState(() {
        _isCalculatingMetrics = false;
        _status = 'Error calculating facial metrics: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Developer Test - Face Mesh'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _status,
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            if (!_isLoading)
              ElevatedButton.icon(
                onPressed: _isDetecting ? null : _detectFullMesh,
                icon: _isDetecting 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.face_retouching_natural),
                label: Text(_isDetecting ? 'Detecting...' : 'Detect Face Mesh'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _imageData.length,
                      itemBuilder: (context, index) {
                        return _buildImageCard(index);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCard(int index) {
    final currentImageData = _imageData[index];
    final decodedImage = _decodedImages[index];
    final meshPoints = _meshPoints[index];
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _imageLabels[index],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            (currentImageData?.isNotEmpty == true && decodedImage != null)
              ? Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomPaint(
                    painter: ImageWithLandmarksPainter(
                      decodedImage: decodedImage,
                      landmarks: meshPoints,
                      isMesh: true,
                    ),
                  ),
                )
              : SizedBox(
                  height: 300,
                  child: Center(
                    child: decodedImage == null && currentImageData?.isNotEmpty == true
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 8),
                              Text('Decoding image...', style: TextStyle(color: Colors.grey)),
                            ],
                          )
                        : Text('Failed to load image: ${_imagePaths[index]}', style: const TextStyle(color: Colors.red)),
                  ),
                ),
            const SizedBox(height: 8),
            Text(
              meshPoints != null
                  ? '${meshPoints.length} face mesh points detected'
                  : 'No mesh detected yet - click "Detect Face Mesh" button',
              style: TextStyle(
                color: (meshPoints != null && meshPoints.isNotEmpty) 
                    ? Colors.green 
                    : Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (meshPoints != null && meshPoints.isEmpty && index > 0)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  'Side profiles are challenging for face mesh detection',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            // Show facial metrics for front profile only
            if (index == 0 && _facialMetrics != null)
              _buildMetricsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                'Facial Metrics',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              width: 120, // Fixed width to prevent infinite constraints
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FacialMetricsVisualizationScreen(
                        frontImage: _decodedImages[0]!,
                        meshPoints: _meshPoints[0]!,
                        metrics: _facialMetrics!,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.visibility, size: 16),
                label: const Text('View', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  minimumSize: const Size(0, 32),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _isCalculatingMetrics
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              )
            : Column(
                children: [
                  _buildMetricRow('F-02', 'Symmetry RMS', _formatValue(_facialMetrics!['F-02'], 4)),
                  _buildMetricRow('F-03', 'Canthal Tilt', '${_formatValue(_facialMetrics!['F-03'], 2)}°'),
                  _buildMetricRow('F-04', 'Eye Shape (H:W)', 'L: ${_formatValue(_facialMetrics!['F-04']['left'], 2)}, R: ${_formatValue(_facialMetrics!['F-04']['right'], 2)}, Mean: ${_formatValue(_facialMetrics!['F-04']['mean'], 2)}'),
                  _buildMetricRow('F-05', 'Inter-canthal / Bizygomatic', _formatValue(_facialMetrics!['F-05'], 3)),
                  _buildMetricRow('F-09', 'FWHR', _formatValue(_facialMetrics!['F-09'], 3)),
                  _buildMetricRow('F-10', 'ICD', '${_formatValue(_facialMetrics!['F-10'], 1)} px'),
                  _buildMetricRow('F-11', 'Nose-/Mouth Width', _formatValue(_facialMetrics!['F-11'], 3)),
                  _buildMetricRow('F-12', 'Alar / Inter-canthal', _formatValue(_facialMetrics!['F-12'], 3)),
                  _buildMetricRow('F-15', 'Jaw (Bigonial) Angle', '${_formatValue(_facialMetrics!['F-15'], 1)}°'),
                  _buildMetricRow('F-17', 'Brow Tilt', '${_formatValue(_facialMetrics!['F-17'], 2)}°'),
                  _buildMetricRow('F-19', 'Golden-Ratio Deviation', '${_formatValue(_facialMetrics!['F-19'], 2)}%'),
                  _buildMetricRow('F-20', 'Philtrum Length Ratio', _formatValue(_facialMetrics!['F-20'], 3)),
                ],
              ),
      ],
    );
  }

  Widget _buildMetricRow(String id, String name, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(
              id,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(name),
          ),
          Expanded(
            flex: 1,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  String _formatValue(dynamic value, int decimals) {
    if (value == null) return 'N/A';
    if (value is num) {
      return value.toStringAsFixed(decimals);
    }
    return value.toString();
  }
}

class ImageWithLandmarksPainter extends CustomPainter {
  final ui.Image decodedImage;
  final List<Offset>? landmarks;
  final bool isMesh;

  ImageWithLandmarksPainter({
    required this.decodedImage,
    this.landmarks,
    this.isMesh = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final imageSize = Size(decodedImage.width.toDouble(), decodedImage.height.toDouble());
    final fitSize = _calculateFitSize(imageSize, size);
    final rect = Rect.fromLTWH(
      (size.width - fitSize.width) / 2,
      (size.height - fitSize.height) / 2,
      fitSize.width,
      fitSize.height,
    );
    
    canvas.drawImageRect(
      decodedImage,
      Rect.fromLTWH(0, 0, decodedImage.width.toDouble(), decodedImage.height.toDouble()),
      rect,
      Paint(),
    );
    
    final scaleX = fitSize.width / decodedImage.width;
    final scaleY = fitSize.height / decodedImage.height;
    final offsetX = (size.width - fitSize.width) / 2;
    final offsetY = (size.height - fitSize.height) / 2;
    
    if (landmarks != null) {
      final landmarkPaint = Paint()
        ..color = Colors.green
        ..style = PaintingStyle.fill;
      const double pointSize = 1.5;
      for (final landmark in landmarks!) {
        final scaledX = landmark.dx * scaleX + offsetX;
        final scaledY = landmark.dy * scaleY + offsetY;
        canvas.drawCircle(
          Offset(scaledX, scaledY),
          pointSize,
          landmarkPaint,
        );
      }
    }
  }

  Size _calculateFitSize(Size imageSize, Size containerSize) {
    final imageRatio = imageSize.width / imageSize.height;
    final containerRatio = containerSize.width / containerSize.height;
    if (containerRatio > imageRatio) {
      return Size(containerSize.height * imageRatio, containerSize.height);
    } else {
      return Size(containerSize.width, containerSize.width / imageRatio);
    }
  }

  @override
  bool shouldRepaint(covariant ImageWithLandmarksPainter oldDelegate) {
    return oldDelegate.decodedImage != decodedImage ||
           oldDelegate.landmarks != landmarks ||
           oldDelegate.isMesh != isMesh;
  }
} 