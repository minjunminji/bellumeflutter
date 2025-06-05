import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:math';
import 'package:go_router/go_router.dart';

class FacialMetricsVisualizationScreen extends StatefulWidget {
  final ui.Image frontImage;
  final List<Offset> meshPoints;
  final Map<String, dynamic> metrics;

  const FacialMetricsVisualizationScreen({
    super.key,
    required this.frontImage,
    required this.meshPoints,
    required this.metrics,
  });

  @override
  State<FacialMetricsVisualizationScreen> createState() => _FacialMetricsVisualizationScreenState();
}

class _FacialMetricsVisualizationScreenState extends State<FacialMetricsVisualizationScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  late List<MetricVisualization> _metricVisualizations;

  @override
  void initState() {
    super.initState();
    _initializeMetricVisualizations();
  }

  void _initializeMetricVisualizations() {
    _metricVisualizations = [
      MetricVisualization(
        id: 'F-02',
        name: 'Symmetry RMS',
        description: 'Facial symmetry measurement using left/right landmark pairs',
        value: widget.metrics['F-02'],
        unit: '',
        landmarks: [
          [263, 33],  // Outer canthi - FIXED
          [362, 133], // Inner canthi - FIXED
          [447, 227], // Zygions
          [278, 102], // Alare
          [291, 61],  // Cheilion
        ],
        visualizationType: VisualizationType.symmetryPairs,
      ),
      MetricVisualization(
        id: 'F-03',
        name: 'Canthal Tilt',
        description: 'Eye angles relative to cheekbone line',
        value: widget.metrics['F-03'],
        unit: '°',
        landmarks: [
          [263, 362], // Left eye: outer to inner
          [133, 33],  // Right eye: inner to outer - FIXED
          [447, 227], // Cheekbone reference line
        ],
        visualizationType: VisualizationType.canthalTilt,
      ),
      MetricVisualization(
        id: 'F-04',
        name: 'Eye Shape (H:W)',
        description: 'Eye height to width ratio (vertical projection only)',
        value: widget.metrics['F-04']['mean'],
        unit: '',
        landmarks: [
          [386, 374], // Left eye height option 1
          [385, 380], // Left eye height option 2
          [263, 362], // Left eye width
          [159, 145], // Right eye height option 1
          [158, 153], // Right eye height option 2
          [133, 33],  // Right eye width - FIXED
        ],
        visualizationType: VisualizationType.eyeShape,
      ),
      MetricVisualization(
        id: 'F-05',
        name: 'Inter-canthal / Bizygomatic',
        description: 'Ratio of inner canthal distance to face width',
        value: widget.metrics['F-05'],
        unit: '',
        landmarks: [
          [362, 133], // Inner canthi - FIXED
          [447, 227], // Bizygomatic width
        ],
        visualizationType: VisualizationType.lines,
      ),
      MetricVisualization(
        id: 'F-09',
        name: 'FWHR',
        description: 'Facial Width-to-Height Ratio',
        value: widget.metrics['F-09'],
        unit: '',
        landmarks: [
          [447, 227], // Bizygomatic width
          [168, 0],   // Nasion to labiale superius
        ],
        visualizationType: VisualizationType.lines,
      ),
      MetricVisualization(
        id: 'F-10',
        name: 'ICD / Inter-Alar Ratio',
        description: 'Inter-Canthal Distance to Inter-Alar Distance Ratio',
        value: widget.metrics['F-10'],
        unit: '',
        landmarks: [
          [362, 133], // Inner canthi - FIXED
          [278, 102], // Inter-alar distance
        ],
        visualizationType: VisualizationType.lines,
      ),
      MetricVisualization(
        id: 'F-11',
        name: 'Nose/Mouth Width',
        description: 'Ratio of nose width to mouth width',
        value: widget.metrics['F-11'],
        unit: '',
        landmarks: [
          [278, 102], // Alare (nose width)
          [291, 61],  // Cheilion (mouth width)
        ],
        visualizationType: VisualizationType.lines,
      ),
      MetricVisualization(
        id: 'F-15',
        name: 'Jaw (Bigonial) Angle',
        description: 'Angle between jaw tangent lines at arc landmarks',
        value: widget.metrics['F-15'],
        unit: '°',
        landmarks: [
          [397, 365, 379], // Left jaw arc: neighbor, tangent point, neighbor
          [172, 136, 150], // Right jaw arc: neighbor, tangent point, neighbor
        ],
        visualizationType: VisualizationType.jawAngle,
      ),
      MetricVisualization(
        id: 'F-17',
        name: 'Brow Tilt',
        description: 'Individual left and right eyebrow tilts relative to cheekbone baseline',
        value: widget.metrics['F-17'],
        unit: '°',
        landmarks: [
          [336, 285], // Left inner landmarks (top, bottom)
          [334, 282], // Left outer landmarks (top, bottom)
          [107, 55],  // Right inner landmarks (top, bottom)
          [105, 52],  // Right outer landmarks (top, bottom)
          [447, 227], // Cheekbone baseline
        ],
        visualizationType: VisualizationType.browTilt,
      ),
      MetricVisualization(
        id: 'F-19',
        name: 'Golden-Ratio Deviation',
        description: 'Deviation from golden ratio in facial proportions',
        value: widget.metrics['F-19'],
        unit: '%',
        landmarks: [
          [168, 2, 152], // Triplet 1: nasion - subnasale - menton
          [1, 152],      // Triplet 2: nose middle to menton (+ inner canthi midpoint)
          [1, 0, 17],    // Triplet 3: nose middle - labiale superius - chin middle
        ],
        visualizationType: VisualizationType.goldenRatio,
      ),
      MetricVisualization(
        id: 'F-20',
        name: 'Philtrum Length Ratio',
        description: 'Philtrum length relative to facial height',
        value: widget.metrics['F-20'],
        unit: '',
        landmarks: [
          [2, 0],     // Philtrum: subnasale to labiale superius
          [2, 152],   // Vertical dimension: subnasale to menton
        ],
        visualizationType: VisualizationType.lines,
      ),
      MetricVisualization(
        id: 'F-21',
        name: 'Facial Fifths',
        description: 'Classical facial fifths proportions - how well the face divides into five equal sections',
        value: widget.metrics['F-21'],
        unit: '/100',
        landmarks: [
          [454, 263, 362, 173, 33, 234], // The six points defining the five fifths
        ],
        visualizationType: VisualizationType.facialFifths,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Facial Metrics Visualization'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  '${_currentIndex + 1} / ${_metricVisualizations.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: LinearProgressIndicator(
                    value: (_currentIndex + 1) / _metricVisualizations.length,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemCount: _metricVisualizations.length,
        itemBuilder: (context, index) {
          return _buildMetricPage(_metricVisualizations[index]);
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (_currentIndex > 0)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Previous'),
                ),
              ),
            if (_currentIndex > 0 && _currentIndex < _metricVisualizations.length - 1)
              const SizedBox(width: 16),
            if (_currentIndex < _metricVisualizations.length - 1)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Next'),
                ),
              ),
            if (_currentIndex == _metricVisualizations.length - 1)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Done'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricPage(MetricVisualization metric) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          metric.id,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          metric.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    metric.description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Value: ',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          '${_formatValue(metric.value)}${metric.unit}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Container(
              height: 400,
              padding: const EdgeInsets.all(8),
              child: CustomPaint(
                painter: MetricVisualizationPainter(
                  image: widget.frontImage,
                  meshPoints: widget.meshPoints,
                  metricId: metric.id,
                  metricValue: metric.value,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Landmarks Used:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getLandmarkDescription(metric),
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatValue(dynamic value) {
    if (value == null) return 'N/A';
    if (value is Map && value.containsKey('left') && value.containsKey('right')) {
      // Canthal tilt or brow tilt with separate left/right values
      final left = value['left']?.toStringAsFixed(2) ?? 'N/A';
      final right = value['right']?.toStringAsFixed(2) ?? 'N/A';
      final avg = value['average']?.toStringAsFixed(2) ?? 'N/A';
      
      // Show right first for canthal tilt to align with right eye
      return 'R:$right° L:$left° Avg:$avg°';
    }
    if (value is num) {
      return value.toStringAsFixed(3);
    }
    return value.toString();
  }

  String _getLandmarkDescription(MetricVisualization metric) {
    switch (metric.id) {
      case 'F-02':
        return 'Central line points: 152,164,195,168,9,151. Symmetry pairs: Outer canthi (263↔33), Inner canthi (362↔133), Zygions (447↔227), Alare (278↔102), Cheilion (291↔61)';
      case 'F-03':
        return 'Cheekbone reference line: 447-227. Left eye: 362(inner)→263(outer), Right eye: 133(inner)→33(outer). Angles calculated relative to cheekbone line.';
      case 'F-04':
        return 'Finds longest eye height distance from multiple candidates, projects vertically. Left candidates: 386-374, 385-380, 387-373, 388-466. Right: 159-145, 158-153, 160-144, 161-163. Shows only vertical projections.';
      case 'F-05':
        return 'Inner canthi distance (362-133) / Bizygomatic width (447-227)';
      case 'F-09':
        return 'Bizygomatic width (447-227) / Facial height (9-0)';
      case 'F-10':
        return 'Inter-canthal distance (362-133) / Inter-alar distance (278-102)';
      case 'F-11':
        return 'Nose width (278-102) / Mouth width (291-61)';
      case 'F-15':
        return 'Left jaw arc: 397→365→379 with tangent at 365. Right jaw arc: 172→136→150 with tangent at 136. Angle calculated between tangent direction vectors.';
      case 'F-17':
        return 'Left inner midpoint (336+285)/2, outer midpoint (334+282)/2. Right inner midpoint (107+55)/2, outer midpoint (105+52)/2. Brow lines compared to cheekbone baseline (447-227).';
      case 'F-19':
        return 'Three vertical sections: 168-2-152, Inner canthi midpoint(362,133)-1-152, 1-0-17';
      case 'F-20':
        return 'Vertical philtrum length (2-0) / Vertical chin length (17-152). Both projected to pure Y distances.';
      case 'F-21':
        return 'The six points defining the five fifths: 454, 263, 362, 173, 33, 234';
      default:
        return 'Landmark points as displayed in visualization';
    }
  }
}

class MetricVisualization {
  final String id;
  final String name;
  final String description;
  final dynamic value;
  final String unit;
  final List<dynamic> landmarks;
  final VisualizationType visualizationType;

  MetricVisualization({
    required this.id,
    required this.name,
    required this.description,
    required this.value,
    required this.unit,
    required this.landmarks,
    required this.visualizationType,
  });
}

enum VisualizationType {
  lines,
  symmetryPairs,
  eyeShape,
  jawAngle,
  browTilt,
  goldenRatio,
  canthalTilt,
  facialFifths,
}

class MetricVisualizationPainter extends CustomPainter {
  final ui.Image image;
  final List<Offset> meshPoints;
  final String metricId;
  final dynamic metricValue;

  MetricVisualizationPainter({
    required this.image,
    required this.meshPoints,
    required this.metricId,
    required this.metricValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw the image
    final imageSize = Size(image.width.toDouble(), image.height.toDouble());
    final fitSize = _calculateFitSize(imageSize, size);
    final rect = Rect.fromLTWH(
      (size.width - fitSize.width) / 2,
      (size.height - fitSize.height) / 2,
      fitSize.width,
      fitSize.height,
    );
    
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      rect,
      Paint(),
    );
    
    // Calculate scale factors
    final scaleX = fitSize.width / image.width;
    final scaleY = fitSize.height / image.height;
    final offsetX = (size.width - fitSize.width) / 2;
    final offsetY = (size.height - fitSize.height) / 2;
    
    // Draw metric-specific visualization
    _drawMetricVisualization(canvas, scaleX, scaleY, offsetX, offsetY);
  }

  void _drawMetricVisualization(Canvas canvas, double scaleX, double scaleY, double offsetX, double offsetY) {
    // Skip drawing overlays if no mesh points are available
    if (meshPoints.isEmpty) {
      // Just show the image without overlays
      return;
    }
    
    // Made lines thinner and changed to dark teal
    final linePaint = Paint()
      ..color = const Color(0xFF004D4D) // Dark teal color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    
    // Made dots smaller and changed to dark teal  
    final pointPaint = Paint()
      ..color = const Color(0xFF004D4D) // Dark teal color
      ..style = PaintingStyle.fill;
    const double pointRadius = 1.4; // Made smaller (was 1.75)

    Offset scalePoint(int index) {
      if (index >= meshPoints.length) {
        return Offset.zero; // Return safe default if index is out of bounds
      }
      final point = meshPoints[index];
      return Offset(
        point.dx * scaleX + offsetX,
        point.dy * scaleY + offsetY,
      );
    }

    switch (metricId) {
      case 'F-02': // Symmetry RMS
        _drawSymmetryVisualization(canvas, linePaint, pointPaint, pointRadius, scalePoint);
        break;
      case 'F-03': // Canthal Tilt
        _drawCanthalTiltVisualization(canvas, linePaint, pointPaint, pointRadius, scalePoint);
        break;
      case 'F-04': // Eye Shape
        _drawEyeShapeVisualization(canvas, linePaint, pointPaint, pointRadius, scalePoint);
        break;
      case 'F-05': // Inter-canthal / Bizygomatic
        _drawInterCanthalBizygomaticVisualization(canvas, linePaint, pointPaint, pointRadius, scalePoint);
        break;
      case 'F-09': // FWHR
        _drawFWHRVisualization(canvas, linePaint, pointPaint, pointRadius, scalePoint);
        break;
      case 'F-10': // ICD
        _drawICDVisualization(canvas, linePaint, pointPaint, pointRadius, scalePoint);
        break;
      case 'F-11': // Nose/Mouth Width
        _drawNoseMouthVisualization(canvas, linePaint, pointPaint, pointRadius, scalePoint);
        break;
      case 'F-15': // Jaw Angle
        _drawJawAngleVisualization(canvas, linePaint, pointPaint, pointRadius, scalePoint);
        break;
      case 'F-17': // Brow Tilt
        _drawBrowTiltVisualization(canvas, linePaint, pointPaint, pointRadius, scalePoint);
        break;
      case 'F-19': // Golden Ratio
        _drawGoldenRatioVisualization(canvas, linePaint, pointPaint, pointRadius, scalePoint);
        break;
      case 'F-20': // Philtrum Length Ratio
        _drawPhiltrumRatioVisualization(canvas, linePaint, pointPaint, pointRadius, scalePoint);
        break;
      case 'F-21': // Facial Fifths
        _drawFacialFifthsVisualization(canvas, linePaint, pointPaint, pointRadius, scalePoint);
        break;
    }
  }

  void _drawSymmetryVisualization(Canvas canvas, Paint linePaint, Paint pointPaint, double pointRadius, Offset Function(int) scalePoint) {
    // Draw central points used for line of best fit
    final centralPoints = [152, 164, 195, 168, 9, 151];
    
    // Calculate midline from central points
    double sumX = 0;
    for (final pointIndex in centralPoints) {
      final scaledPoint = scalePoint(pointIndex);
      canvas.drawCircle(scaledPoint, pointRadius, pointPaint);
      sumX += scaledPoint.dx;
    }
    final midlineX = sumX / centralPoints.length;
    
    // Draw midline - use image bounds
    final imageSize = Size(image.width.toDouble(), image.height.toDouble());
    final containerSize = const Size(400, 400); // Approximate container size
    final fitSize = _calculateFitSize(imageSize, containerSize);
    final offsetY = (containerSize.height - fitSize.height) / 2;
    
    canvas.drawLine(
      Offset(midlineX, offsetY),
      Offset(midlineX, offsetY + fitSize.height),
      linePaint,
    );
    
    // Draw symmetry pairs and their connections - CORRECTED
    final symmetryPairs = [
      [263, 33],  // Outer canthi - FIXED
      [362, 133], // Inner canthi - FIXED
      [447, 227], // Zygions
      [278, 102], // Alare
      [291, 61],  // Cheilion
    ];
    
    final pairPaint = Paint()
      ..color = const Color(0xFF004D4D) // Dark teal
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    
    for (final pair in symmetryPairs) {
      final leftPoint = scalePoint(pair[0]);
      final rightPoint = scalePoint(pair[1]);
      
      // Draw points
      canvas.drawCircle(leftPoint, pointRadius, pointPaint);
      canvas.drawCircle(rightPoint, pointRadius, pointPaint);
      
      // Draw connection line
      canvas.drawLine(leftPoint, rightPoint, pairPaint);
      
      // Mirror left point and show mirrored position
      final mirroredLeftX = 2 * midlineX - leftPoint.dx;
      final mirroredLeft = Offset(mirroredLeftX, leftPoint.dy);
      
      final mirroredPaint = Paint()
        ..color = const Color(0xFF006666) // Lighter teal for mirrored points
        ..style = PaintingStyle.fill;
      canvas.drawCircle(mirroredLeft, pointRadius, mirroredPaint);
      
      // Draw line from mirrored to actual right
      final mirrorLinePaint = Paint()
        ..color = const Color(0xFF006666) // Lighter teal
        ..strokeWidth = 1.0;
      canvas.drawLine(mirroredLeft, rightPoint, mirrorLinePaint);
    }
  }

  void _drawCanthalTiltVisualization(Canvas canvas, Paint linePaint, Paint pointPaint, double pointRadius, Offset Function(int) scalePoint) {
    // Left eye: 362 (inner) to 263 (outer)
    final leftInner = scalePoint(362);
    final leftOuter = scalePoint(263);
    
    // Right eye: 133 (inner) to 33 (outer) - FIXED
    final rightInner = scalePoint(133);
    final rightOuter = scalePoint(33);
    
    // Draw eye points
    canvas.drawCircle(leftInner, pointRadius, pointPaint);
    canvas.drawCircle(leftOuter, pointRadius, pointPaint);
    canvas.drawCircle(rightInner, pointRadius, pointPaint);
    canvas.drawCircle(rightOuter, pointRadius, pointPaint);
    
    // Draw eye lines
    canvas.drawLine(leftInner, leftOuter, linePaint);
    canvas.drawLine(rightInner, rightOuter, linePaint);
  }

  void _drawNoseMouthVisualization(Canvas canvas, Paint linePaint, Paint pointPaint, double pointRadius, Offset Function(int) scalePoint) {
    // Nose width: 278 (left alare) to 102 (right alare)
    final leftAlare = scalePoint(278);
    final rightAlare = scalePoint(102);
    
    // Mouth width: 291 (left cheilion) to 61 (right cheilion)
    final leftCheilion = scalePoint(291);
    final rightCheilion = scalePoint(61);
    
    // Draw points
    canvas.drawCircle(leftAlare, pointRadius, pointPaint);
    canvas.drawCircle(rightAlare, pointRadius, pointPaint);
    canvas.drawCircle(leftCheilion, pointRadius, pointPaint);
    canvas.drawCircle(rightCheilion, pointRadius, pointPaint);
    
    // Draw nose width line
    canvas.drawLine(leftAlare, rightAlare, linePaint);
    
    // Draw mouth width line using dark teal
    final mouthPaint = Paint()
      ..color = const Color(0xFF004D4D) // Dark teal
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(leftCheilion, rightCheilion, mouthPaint);
  }

  void _drawGoldenRatioVisualization(Canvas canvas, Paint linePaint, Paint pointPaint, double pointRadius, Offset Function(int) scalePoint) {
    // Three vertical divisions
    final triplet1 = [168, 2, 152]; // Nasion to subnasale to menton
    
    // Inner canthi midpoint calculation - FIXED
    final leftInner = meshPoints[362];
    final rightInner = meshPoints[133]; // Changed from 173 to 133
    final icMidpoint = Offset((leftInner.dx + rightInner.dx) / 2, (leftInner.dy + rightInner.dy) / 2);
    
    // Scale the midpoint
    final scaleX = (scalePoint(0).dx - scalePoint(1).dx) != 0 ? 
      (scalePoint(0).dx - scalePoint(1).dx) / (meshPoints[0].dx - meshPoints[1].dx) : 1.0;
    final scaleY = (scalePoint(0).dy - scalePoint(1).dy) != 0 ? 
      (scalePoint(0).dy - scalePoint(1).dy) / (meshPoints[0].dy - meshPoints[1].dy) : 1.0;
    final offsetX = scalePoint(0).dx - meshPoints[0].dx * scaleX;
    final offsetY = scalePoint(0).dy - meshPoints[0].dy * scaleY;
    
    final scaledICMidpoint = Offset(
      icMidpoint.dx * scaleX + offsetX,
      icMidpoint.dy * scaleY + offsetY,
    );
    
    // Draw main vertical line (nasion to menton)
    _drawLandmarkLine(canvas, triplet1, linePaint, scalePoint);
    
    // Mark the three key points
    for (final pointIndex in triplet1) {
      canvas.drawCircle(scalePoint(pointIndex), pointRadius, pointPaint);
    }
    
    // Draw IC midpoint
    final midpointPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;
    canvas.drawCircle(scaledICMidpoint, pointRadius * 1.5, midpointPaint);
    
    // Draw lines from IC midpoint
    canvas.drawLine(scaledICMidpoint, scalePoint(1), linePaint);
    canvas.drawLine(scalePoint(1), scalePoint(0), linePaint);
    canvas.drawLine(scalePoint(0), scalePoint(17), linePaint);
  }

  void _drawInterCanthalBizygomaticVisualization(Canvas canvas, Paint linePaint, Paint pointPaint, double pointRadius, Offset Function(int) scalePoint) {
    // Inner canthi: 362 (left) and 133 (right) - FIXED
    final leftInner = scalePoint(362);
    final rightInner = scalePoint(133);
    
    // Bizygomatic points: 447 (left) and 227 (right)
    final leftZygion = scalePoint(447);
    final rightZygion = scalePoint(227);
    
    // Draw points
    canvas.drawCircle(leftInner, pointRadius, pointPaint);
    canvas.drawCircle(rightInner, pointRadius, pointPaint);
    canvas.drawCircle(leftZygion, pointRadius, pointPaint);
    canvas.drawCircle(rightZygion, pointRadius, pointPaint);
    
    // Draw inter-canthal line
    canvas.drawLine(leftInner, rightInner, linePaint);
    
    // Draw bizygomatic line
    canvas.drawLine(leftZygion, rightZygion, linePaint);
  }

  void _drawFWHRVisualization(Canvas canvas, Paint linePaint, Paint pointPaint, double pointRadius, Offset Function(int) scalePoint) {
    // Width: Bizygomatic points 447 (left) and 227 (right)
    final leftZygion = scalePoint(447);
    final rightZygion = scalePoint(227);
    
    // Height: 9 to 0 - CORRECTED
    final topPoint = scalePoint(9);
    final bottomPoint = scalePoint(0);
    
    // Draw points
    canvas.drawCircle(leftZygion, pointRadius, pointPaint);
    canvas.drawCircle(rightZygion, pointRadius, pointPaint);
    canvas.drawCircle(topPoint, pointRadius, pointPaint);
    canvas.drawCircle(bottomPoint, pointRadius, pointPaint);
    
    // Draw width line
    canvas.drawLine(leftZygion, rightZygion, linePaint);
    
    // Draw height line
    canvas.drawLine(topPoint, bottomPoint, linePaint);
  }

  void _drawICDVisualization(Canvas canvas, Paint linePaint, Paint pointPaint, double pointRadius, Offset Function(int) scalePoint) {
    // Inner canthi: 362 (left) and 133 (right) - FIXED
    final leftInner = scalePoint(362);
    final rightInner = scalePoint(133);
    
    // Inter-alar points: 278 (left) and 102 (right)
    final leftAlar = scalePoint(278);
    final rightAlar = scalePoint(102);
    
    // Draw points
    canvas.drawCircle(leftInner, pointRadius, pointPaint);
    canvas.drawCircle(rightInner, pointRadius, pointPaint);
    canvas.drawCircle(leftAlar, pointRadius, pointPaint);
    canvas.drawCircle(rightAlar, pointRadius, pointPaint);
    
    // Draw inter-canthal line
    canvas.drawLine(leftInner, rightInner, linePaint);
    
    // Draw inter-alar line using dark teal
    final alarPaint = Paint()
      ..color = const Color(0xFF004D4D) // Dark teal
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(leftAlar, rightAlar, alarPaint);
  }

  void _drawJawAngleVisualization(Canvas canvas, Paint linePaint, Paint pointPaint, double pointRadius, Offset Function(int) scalePoint) {
    // Left jaw arc landmarks: 397 (neighbor), 365 (tangent point), 379 (neighbor)
    final left397 = scalePoint(397);
    final left365 = scalePoint(365);  // Left tangent point
    final left379 = scalePoint(379);
    
    // Right jaw arc landmarks: 172 (neighbor), 136 (tangent point), 150 (neighbor)
    final right172 = scalePoint(172);
    final right136 = scalePoint(136);  // Right tangent point
    final right150 = scalePoint(150);
    
    // Calculate and draw tangent lines only
    // Left tangent direction vector: v_L = (x379 - x397, y379 - y397)
    final leftTangentDir = Offset(left379.dx - left397.dx, left379.dy - left397.dy);
    final leftTangentLen = sqrt(leftTangentDir.dx * leftTangentDir.dx + leftTangentDir.dy * leftTangentDir.dy);
    
    // Right tangent direction vector: v_R = (x150 - x172, y150 - y172)
    final rightTangentDir = Offset(right150.dx - right172.dx, right150.dy - right172.dy);
    final rightTangentLen = sqrt(rightTangentDir.dx * rightTangentDir.dx + rightTangentDir.dy * rightTangentDir.dy);
    
    // Draw tangent lines extending from tangent points using dark teal
    final tangentPaint = Paint()
      ..color = const Color(0xFF004D4D) // Dark teal
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    
    if (leftTangentLen > 0) {
      final leftTangentUnit = Offset(leftTangentDir.dx / leftTangentLen, leftTangentDir.dy / leftTangentLen);
      const extendLength = 60.0;
      
      // Extend tangent line in both directions from tangent point
      final leftTangentStart = Offset(
        left365.dx - leftTangentUnit.dx * extendLength,
        left365.dy - leftTangentUnit.dy * extendLength
      );
      final leftTangentEnd = Offset(
        left365.dx + leftTangentUnit.dx * extendLength,
        left365.dy + leftTangentUnit.dy * extendLength
      );
      canvas.drawLine(leftTangentStart, leftTangentEnd, tangentPaint);
    }
    
    if (rightTangentLen > 0) {
      final rightTangentUnit = Offset(rightTangentDir.dx / rightTangentLen, rightTangentDir.dy / rightTangentLen);
      const extendLength = 60.0;
      
      // Extend tangent line in both directions from tangent point
      final rightTangentStart = Offset(
        right136.dx - rightTangentUnit.dx * extendLength,
        right136.dy - rightTangentUnit.dy * extendLength
      );
      final rightTangentEnd = Offset(
        right136.dx + rightTangentUnit.dx * extendLength,
        right136.dy + rightTangentUnit.dy * extendLength
      );
      canvas.drawLine(rightTangentStart, rightTangentEnd, tangentPaint);
    }
  }

  void _drawBrowTiltVisualization(Canvas canvas, Paint linePaint, Paint pointPaint, double pointRadius, Offset Function(int) scalePoint) {
    // LEFT EYEBROW CALCULATION
    // Inner landmarks: 336 (top), 285 (bottom)
    final leftInnerTop = scalePoint(336);
    final leftInnerBottom = scalePoint(285);
    final leftInnerMidpoint = Offset(
      (leftInnerTop.dx + leftInnerBottom.dx) / 2,
      (leftInnerTop.dy + leftInnerBottom.dy) / 2
    );
    
    // Outer landmarks: 334 (top), 282 (bottom)
    final leftOuterTop = scalePoint(334);
    final leftOuterBottom = scalePoint(282);
    final leftOuterMidpoint = Offset(
      (leftOuterTop.dx + leftOuterBottom.dx) / 2,
      (leftOuterTop.dy + leftOuterBottom.dy) / 2
    );
    
    // RIGHT EYEBROW CALCULATION
    // Inner landmarks: 107 (top), 55 (bottom)
    final rightInnerTop = scalePoint(107);
    final rightInnerBottom = scalePoint(55);
    final rightInnerMidpoint = Offset(
      (rightInnerTop.dx + rightInnerBottom.dx) / 2,
      (rightInnerTop.dy + rightInnerBottom.dy) / 2
    );
    
    // Outer landmarks: 105 (top), 52 (bottom)
    final rightOuterTop = scalePoint(105);
    final rightOuterBottom = scalePoint(52);
    final rightOuterMidpoint = Offset(
      (rightOuterTop.dx + rightOuterBottom.dx) / 2,
      (rightOuterTop.dy + rightOuterBottom.dy) / 2
    );
    
    // Draw midpoints (using dark teal color)
    final midpointPaint = Paint()
      ..color = const Color(0xFF004D4D) // Dark teal
      ..style = PaintingStyle.fill;
    canvas.drawCircle(leftInnerMidpoint, pointRadius * 1.3, midpointPaint);
    canvas.drawCircle(leftOuterMidpoint, pointRadius * 1.3, midpointPaint);
    canvas.drawCircle(rightInnerMidpoint, pointRadius * 1.3, midpointPaint);
    canvas.drawCircle(rightOuterMidpoint, pointRadius * 1.3, midpointPaint);
    
    // Draw brow lines (midpoint to midpoint) using dark teal
    final browLinePaint = Paint()
      ..color = const Color(0xFF004D4D) // Dark teal
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    
    // Left brow line: inner midpoint to outer midpoint
    canvas.drawLine(leftInnerMidpoint, leftOuterMidpoint, browLinePaint);
    
    // Right brow line: inner midpoint to outer midpoint
    canvas.drawLine(rightInnerMidpoint, rightOuterMidpoint, browLinePaint);
  }

  void _drawPhiltrumRatioVisualization(Canvas canvas, Paint linePaint, Paint pointPaint, double pointRadius, Offset Function(int) scalePoint) {
    // Philtrum: 2 (subnasale) to 0 (labiale superius)
    final subnasale = scalePoint(2);
    final labialeSuperius = scalePoint(0);
    
    // Chin length: 17 (middle of chin) to 152 (menton)
    final chinMiddle = scalePoint(17);
    final menton = scalePoint(152);
    
    // Draw points
    canvas.drawCircle(subnasale, pointRadius, pointPaint);
    canvas.drawCircle(labialeSuperius, pointRadius, pointPaint);
    canvas.drawCircle(chinMiddle, pointRadius, pointPaint);
    canvas.drawCircle(menton, pointRadius, pointPaint);
    
    // Draw philtrum vertical projection (same X coordinate)
    final philtrumX = (subnasale.dx + labialeSuperius.dx) / 2; // Use average X
    canvas.drawLine(
      Offset(philtrumX, subnasale.dy), 
      Offset(philtrumX, labialeSuperius.dy), 
      linePaint
    );
    
    // Draw chin vertical projection (same X coordinate) using dark teal
    final chinPaint = Paint()
      ..color = const Color(0xFF004D4D) // Dark teal
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    
    final chinX = (chinMiddle.dx + menton.dx) / 2; // Use average X
    canvas.drawLine(
      Offset(chinX, chinMiddle.dy), 
      Offset(chinX, menton.dy), 
      chinPaint
    );
  }

  void _drawEyeShapeVisualization(Canvas canvas, Paint linePaint, Paint pointPaint, double pointRadius, Offset Function(int) scalePoint) {
    // Left eye height candidates - find the longest and draw its vertical projection
    final leftHeightCandidates = [
      [386, 374], [385, 380], [387, 373], [388, 466]
    ];
    
    // Right eye height candidates
    final rightHeightCandidates = [
      [159, 145], [158, 153], [160, 144], [161, 163]
    ];
    
    // Find the longest distance for left eye and project it vertically
    double maxLeftDistance = 0;
    Offset leftTopPoint = Offset.zero;
    Offset leftBottomPoint = Offset.zero;
    
    for (final pair in leftHeightCandidates) {
      final p1 = scalePoint(pair[0]);
      final p2 = scalePoint(pair[1]);
      final distance = (p1 - p2).distance;
      if (distance > maxLeftDistance) {
        maxLeftDistance = distance;
        leftTopPoint = p1.dy < p2.dy ? p1 : p2;
        leftBottomPoint = p1.dy > p2.dy ? p1 : p2;
      }
    }
    
    // Find the longest distance for right eye and project it vertically
    double maxRightDistance = 0;
    Offset rightTopPoint = Offset.zero;
    Offset rightBottomPoint = Offset.zero;
    
    for (final pair in rightHeightCandidates) {
      final p1 = scalePoint(pair[0]);
      final p2 = scalePoint(pair[1]);
      final distance = (p1 - p2).distance;
      if (distance > maxRightDistance) {
        maxRightDistance = distance;
        rightTopPoint = p1.dy < p2.dy ? p1 : p2;
        rightBottomPoint = p1.dy > p2.dy ? p1 : p2;
      }
    }
    
    // Draw vertical projections only using dark teal
    final verticalPaint = Paint()
      ..color = const Color(0xFF004D4D) // Dark teal
      ..strokeWidth = 1.0  // Same thickness as horizontal lines
      ..style = PaintingStyle.stroke;
    
    // Left eye vertical projection (same X coordinate)
    final leftVerticalTop = Offset(leftTopPoint.dx, leftTopPoint.dy);
    final leftVerticalBottom = Offset(leftTopPoint.dx, leftBottomPoint.dy);
    canvas.drawLine(leftVerticalTop, leftVerticalBottom, verticalPaint);
    
    // Right eye vertical projection (same X coordinate)
    final rightVerticalTop = Offset(rightTopPoint.dx, rightTopPoint.dy);
    final rightVerticalBottom = Offset(rightTopPoint.dx, rightBottomPoint.dy);
    canvas.drawLine(rightVerticalTop, rightVerticalBottom, verticalPaint);
    
    // Draw the actual height measurement points for reference
    canvas.drawCircle(leftTopPoint, pointRadius, pointPaint);
    canvas.drawCircle(leftBottomPoint, pointRadius, pointPaint);
    canvas.drawCircle(rightTopPoint, pointRadius, pointPaint);
    canvas.drawCircle(rightBottomPoint, pointRadius, pointPaint);
    
    // Draw horizontal width lines for reference
    final leftInner = scalePoint(362);
    final leftOuter = scalePoint(263);
    final rightInner = scalePoint(133); // FIXED
    final rightOuter = scalePoint(33);
    
    // Draw horizontal projections for width using dark teal
    final horizontalPaint = Paint()
      ..color = const Color(0xFF004D4D) // Dark teal
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    
    // Left eye horizontal width (same Y coordinate as middle of eye)
    final leftMidY = (leftInner.dy + leftOuter.dy) / 2;
    canvas.drawLine(
      Offset(leftInner.dx, leftMidY), 
      Offset(leftOuter.dx, leftMidY), 
      horizontalPaint
    );
    
    // Right eye horizontal width (same Y coordinate as middle of eye)
    final rightMidY = (rightInner.dy + rightOuter.dy) / 2;
    canvas.drawLine(
      Offset(rightInner.dx, rightMidY), 
      Offset(rightOuter.dx, rightMidY), 
      horizontalPaint
    );
    
    canvas.drawCircle(leftInner, pointRadius, pointPaint);
    canvas.drawCircle(leftOuter, pointRadius, pointPaint);
    canvas.drawCircle(rightInner, pointRadius, pointPaint);
    canvas.drawCircle(rightOuter, pointRadius, pointPaint);
  }

  void _drawFacialFifthsVisualization(Canvas canvas, Paint linePaint, Paint pointPaint, double pointRadius, Offset Function(int) scalePoint) {
    // Define the six landmark points for facial fifths
    final leftmostPoint = scalePoint(454);   // leftmost point on face
    final outerLeftEye = scalePoint(263);    // outer left eye
    final innerLeftEye = scalePoint(362);    // inner left eye
    final innerRightEye = scalePoint(173);   // inner right eye
    final outerRightEye = scalePoint(33);    // outer right eye
    final rightmostPoint = scalePoint(234);  // rightmost point on face
    
    // Create horizontal baseline from leftmost to rightmost points
    final baselineY = (leftmostPoint.dy + rightmostPoint.dy) / 2;
    
    // Project all points onto this horizontal line
    final projectedPoints = [
      Offset(leftmostPoint.dx, baselineY),
      Offset(outerLeftEye.dx, baselineY),
      Offset(innerLeftEye.dx, baselineY),
      Offset(innerRightEye.dx, baselineY),
      Offset(outerRightEye.dx, baselineY),
      Offset(rightmostPoint.dx, baselineY),
    ];
    
    // Draw the original points
    canvas.drawCircle(leftmostPoint, pointRadius, pointPaint);
    canvas.drawCircle(outerLeftEye, pointRadius, pointPaint);
    canvas.drawCircle(innerLeftEye, pointRadius, pointPaint);
    canvas.drawCircle(innerRightEye, pointRadius, pointPaint);
    canvas.drawCircle(outerRightEye, pointRadius, pointPaint);
    canvas.drawCircle(rightmostPoint, pointRadius, pointPaint);
    
    // Draw the horizontal baseline
    final baselinePaint = Paint()
      ..color = const Color(0xFF004D4D) // Dark teal
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    
    canvas.drawLine(
      Offset(leftmostPoint.dx, baselineY),
      Offset(rightmostPoint.dx, baselineY),
      baselinePaint
    );
    
    // Draw vertical lines from original points to baseline
    final projectionPaint = Paint()
      ..color = const Color(0xFF006666) // Lighter teal
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    
    canvas.drawLine(leftmostPoint, projectedPoints[0], projectionPaint);
    canvas.drawLine(outerLeftEye, projectedPoints[1], projectionPaint);
    canvas.drawLine(innerLeftEye, projectedPoints[2], projectionPaint);
    canvas.drawLine(innerRightEye, projectedPoints[3], projectionPaint);
    canvas.drawLine(outerRightEye, projectedPoints[4], projectionPaint);
    canvas.drawLine(rightmostPoint, projectedPoints[5], projectionPaint);
    
    // Draw the projected points on the baseline
    final projectedPointPaint = Paint()
      ..color = const Color(0xFF006666) // Lighter teal
      ..style = PaintingStyle.fill;
    
    for (final point in projectedPoints) {
      canvas.drawCircle(point, pointRadius, projectedPointPaint);
    }
    
    // Draw the five fifths divisions on the baseline
    final fifthsPaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;
    
    for (int i = 0; i < projectedPoints.length - 1; i++) {
      canvas.drawLine(projectedPoints[i], projectedPoints[i + 1], fifthsPaint);
    }
  }

  void _drawLandmarkLine(Canvas canvas, List<int> landmarks, Paint paint, Offset Function(int) scalePoint) {
    if (landmarks.length == 2) {
      final point1 = scalePoint(landmarks[0]);
      final point2 = scalePoint(landmarks[1]);
      
      // Draw points
      final pointPaint = Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.fill;
      canvas.drawCircle(point1, 1.75, pointPaint); // 30% smaller
      canvas.drawCircle(point2, 1.75, pointPaint);
      
      // Draw line
      canvas.drawLine(point1, point2, paint);
    }
  }

  Offset _averageScaledPoints(List<Offset> points) {
    double sumX = 0, sumY = 0;
    for (final point in points) {
      sumX += point.dx;
      sumY += point.dy;
    }
    return Offset(sumX / points.length, sumY / points.length);
  }

  Size get fitSize {
    final imageSize = Size(image.width.toDouble(), image.height.toDouble());
    return _calculateFitSize(imageSize, const Size(400, 400)); // Assuming a container size
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
  bool shouldRepaint(covariant MetricVisualizationPainter oldDelegate) {
    return oldDelegate.image != image ||
           oldDelegate.meshPoints != meshPoints ||
           oldDelegate.metricId != metricId ||
           oldDelegate.metricValue != metricValue;
  }
} 