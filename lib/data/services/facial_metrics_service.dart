import 'dart:math';
import 'dart:ui';

/// Service for calculating facial metrics from face mesh landmarks
class FacialMetricsService {
  static final FacialMetricsService _instance = FacialMetricsService._internal();
  factory FacialMetricsService() => _instance;
  FacialMetricsService._internal();

  /// Calculates all facial metrics for a front profile image
  /// Returns a Map with measurement IDs as keys and the calculated values
  Future<Map<String, dynamic>> calculateFrontProfileMetrics(List<Offset> meshPoints) async {
    print('FacialMetricsService: Starting calculation with ${meshPoints.length} mesh points');
    
    if (meshPoints.isEmpty) {
      throw Exception('No mesh points provided for facial metrics calculation');
    }

    // Check if we have enough points (standard face mesh has 468 points)
    if (meshPoints.length < 468) {
      throw Exception('Insufficient mesh points for facial metrics calculation. Expected 468, found ${meshPoints.length}');
    }

    print('FacialMetricsService: Mesh points validation passed');
    final metrics = <String, dynamic>{};

    try {
      // F-02: Symmetry RMS
      print('FacialMetricsService: Calculating F-02 Symmetry RMS');
      metrics['F-02'] = calculateSymmetryRMS(meshPoints);

      // F-03: Canthal Tilt
      print('FacialMetricsService: Calculating F-03 Canthal Tilt');
      metrics['F-03'] = calculateCanthalTilt(meshPoints);

      // F-04: Eye Shape (H:W)
      print('FacialMetricsService: Calculating F-04 Eye Shape');
      final eyeShape = calculateEyeShape(meshPoints);
      metrics['F-04'] = eyeShape;

      // F-05: Inter-canthal / Bizygomatic
      print('FacialMetricsService: Calculating F-05 Inter-canthal / Bizygomatic');
      metrics['F-05'] = calculateInterCanthalBizygomaticRatio(meshPoints);

      // F-09: FWHR (Facial Width-to-Height Ratio)
      print('FacialMetricsService: Calculating F-09 FWHR');
      metrics['F-09'] = calculateFWHR(meshPoints);

      // F-10: ICD / Inter-Alar Distance
      print('FacialMetricsService: Calculating F-10 ICD');
      metrics['F-10'] = calculateICD(meshPoints);

      // F-11: Nose-/Mouth Width
      print('FacialMetricsService: Calculating F-11 Nose/Mouth Width');
      metrics['F-11'] = calculateNoseMouthWidthRatio(meshPoints);

      // F-15: Jaw (Bigonial) Angle
      print('FacialMetricsService: Calculating F-15 Jaw Angle');
      metrics['F-15'] = calculateJawAngle(meshPoints);

      // F-17: Brow Tilt
      print('FacialMetricsService: Calculating F-17 Brow Tilt');
      metrics['F-17'] = calculateBrowTilt(meshPoints);

      // F-19: Golden-Ratio Highlights
      print('FacialMetricsService: Calculating F-19 Golden-Ratio Deviation');
      metrics['F-19'] = calculateGoldenRatioDeviation(meshPoints);

      // F-20: Philtrum Length
      print('FacialMetricsService: Calculating F-20 Philtrum Length Ratio');
      metrics['F-20'] = calculatePhiltrumLengthRatio(meshPoints);

      // F-21: Facial Fifths
      print('FacialMetricsService: Calculating F-21 Facial Fifths');
      metrics['F-21'] = calculateFacialFifths(meshPoints);

      print('FacialMetricsService: All metrics calculated successfully');
      return metrics;
    } catch (e, stackTrace) {
      print('FacialMetricsService: Error during metrics calculation: $e');
      print('FacialMetricsService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// F-02: Symmetry RMS
  /// - Find midline based on line of best fit through central points
  /// - Mirror left landmarks across midline
  /// - Calculate RMS difference and normalize by bizygomatic width
  double calculateSymmetryRMS(List<Offset> meshPoints) {
    // Central points for line of best fit: 152, 164, 195, 168, 9, 151
    final centralPoints = [152, 164, 195, 168, 9, 151];
    
    // Calculate line of best fit for midline
    double sumX = 0, sumY = 0, sumXY = 0, sumXX = 0;
    for (final pointIndex in centralPoints) {
      final point = meshPoints[pointIndex];
      sumX += point.dx;
      sumY += point.dy;
      sumXY += point.dx * point.dy;
      sumXX += point.dx * point.dx;
    }
    
    final n = centralPoints.length;
    final slope = (n * sumXY - sumX * sumY) / (n * sumXX - sumX * sumX);
    final intercept = (sumY - slope * sumX) / n;
    
    // Use the average X coordinate of central points as midline
    final midlineX = sumX / n;
    
    // Landmark pairs to compare for symmetry - CORRECTED
    final symmetryPairs = [
      [263, 33],  // Outer canthi - FIXED: right outer is 33, not 133
      [362, 133], // Inner canthi - FIXED: right inner is 133, not 33
      [447, 227], // Zygions
      [278, 102], // Alare
      [291, 61],  // Cheilion
    ];
    
    double sumSquaredDifferences = 0;
    int pairCount = 0;
    
    // Calculate squared differences for each pair
    for (final pair in symmetryPairs) {
      final leftPoint = meshPoints[pair[0]];
      final rightPoint = meshPoints[pair[1]];
      
      // Mirror the left point across the midline
      final mirroredLeftX = 2 * midlineX - leftPoint.dx;
      final mirroredLeft = Offset(mirroredLeftX, leftPoint.dy);
      
      // Calculate squared difference
      final xDiff = mirroredLeft.dx - rightPoint.dx;
      final yDiff = mirroredLeft.dy - rightPoint.dy;
      final squaredDiff = xDiff * xDiff + yDiff * yDiff;
      
      sumSquaredDifferences += squaredDiff;
      pairCount++;
    }
    
    // Calculate RMS
    final rms = sqrt(sumSquaredDifferences / pairCount);
    
    // Normalize by bizygomatic width (distance between points 447 and 227)
    final bizygomaticWidth = (meshPoints[447] - meshPoints[227]).distance;
    
    return rms / bizygomaticWidth;
  }

  /// F-03: Canthal Tilt
  /// Calculate angles relative to cheekbone line (horizontal reference)
  /// Returns both left and right angles separately with sign indication
  Map<String, dynamic> calculateCanthalTilt(List<Offset> meshPoints) {
    // Use cheekbone line as horizontal reference: 447 (left) to 227 (right)
    final leftCheekbone = meshPoints[447];
    final rightCheekbone = meshPoints[227];
    
    // Calculate cheekbone line angle (our horizontal reference)
    final cheekboneVector = Offset(
      rightCheekbone.dx - leftCheekbone.dx,
      rightCheekbone.dy - leftCheekbone.dy
    );
    final cheekboneAngle = atan2(cheekboneVector.dy, cheekboneVector.dx);
    
    // LEFT EYE: 362 (inner canthus) to 263 (outer canthus)
    final leftInnerCanthus = meshPoints[362];
    final leftOuterCanthus = meshPoints[263];
    
    // RIGHT EYE: 133 (inner canthus) to 33 (outer canthus) - FIXED  
    final rightInnerCanthus = meshPoints[133];
    final rightOuterCanthus = meshPoints[33];
    
    // Calculate eye line vectors
    final leftEyeVector = Offset(
      leftOuterCanthus.dx - leftInnerCanthus.dx,
      leftOuterCanthus.dy - leftInnerCanthus.dy
    );
    
    final rightEyeVector = Offset(
      rightOuterCanthus.dx - rightInnerCanthus.dx,
      rightOuterCanthus.dy - rightInnerCanthus.dy
    );
    
    // Calculate angles of eye lines
    final leftEyeAngle = atan2(leftEyeVector.dy, leftEyeVector.dx);
    final rightEyeAngle = atan2(rightEyeVector.dy, rightEyeVector.dx);
    
    // Calculate tilts relative to cheekbone baseline
    double leftTilt = (leftEyeAngle - cheekboneAngle) * 180 / pi;
    double rightTilt = (rightEyeAngle - cheekboneAngle) * 180 / pi;
    
    // Normalize to [-180, 180] range
    while (leftTilt > 180) {
      leftTilt -= 360;
    }
    while (leftTilt < -180) {
      leftTilt += 360;
    }
    while (rightTilt > 180) {
      rightTilt -= 360;
    }
    while (rightTilt < -180) {
      rightTilt += 360;
    }
    
    // Convert obtuse angles to acute angles (take complement if > 90° or < -90°)
    if (leftTilt.abs() > 90) {
      leftTilt = leftTilt > 0 ? 180 - leftTilt : -180 - leftTilt;
    }
    
    if (rightTilt.abs() > 90) {
      rightTilt = rightTilt > 0 ? 180 - rightTilt : -180 - rightTilt;
    }
    
    // Calculate average
    final averageTilt = (leftTilt + rightTilt) / 2;
    
    return {
      'left': leftTilt,
      'right': rightTilt,
      'average': averageTilt,
    };
  }

  /// F-04: Eye Shape (H:W)
  /// Height: Find longest distance between eye points and project vertically
  /// Width: Outer ↔ inner canthus
  Map<String, dynamic> calculateEyeShape(List<Offset> meshPoints) {
    // Left eye height candidates - find all possible vertical distances
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
      final p1 = meshPoints[pair[0]];
      final p2 = meshPoints[pair[1]];
      final distance = (p1 - p2).distance;
      if (distance > maxLeftDistance) {
        maxLeftDistance = distance;
        leftTopPoint = p1.dy < p2.dy ? p1 : p2;
        leftBottomPoint = p1.dy > p2.dy ? p1 : p2;
      }
    }
    
    // Project left eye height vertically (pure Y distance)
    final leftHeight = (leftBottomPoint.dy - leftTopPoint.dy).abs();
    
    // Find the longest distance for right eye and project it vertically
    double maxRightDistance = 0;
    Offset rightTopPoint = Offset.zero;
    Offset rightBottomPoint = Offset.zero;
    
    for (final pair in rightHeightCandidates) {
      final p1 = meshPoints[pair[0]];
      final p2 = meshPoints[pair[1]];
      final distance = (p1 - p2).distance;
      if (distance > maxRightDistance) {
        maxRightDistance = distance;
        rightTopPoint = p1.dy < p2.dy ? p1 : p2;
        rightBottomPoint = p1.dy > p2.dy ? p1 : p2;
      }
    }
    
    // Project right eye height vertically (pure Y distance)
    final rightHeight = (rightBottomPoint.dy - rightTopPoint.dy).abs();
    
    // Eye widths (horizontal distances - project onto X axis)
    final leftWidth = (meshPoints[263].dx - meshPoints[362].dx).abs();
    final rightWidth = (meshPoints[133].dx - meshPoints[33].dx).abs();
    
    // Calculate ratios
    final leftRatio = leftHeight / leftWidth;
    final rightRatio = rightHeight / rightWidth;
    final meanRatio = (leftRatio + rightRatio) / 2;
    
    return {
      'left': leftRatio,
      'right': rightRatio,
      'mean': meanRatio
    };
  }

  /// F-05: Inter-canthal / Bizygomatic
  /// Ratio of inner canthal distance to bizygomatic width
  double calculateInterCanthalBizygomaticRatio(List<Offset> meshPoints) {
    // Inner canthi: 362 (left) and 133 (right) - CORRECTED
    final icDistance = (meshPoints[362] - meshPoints[133]).distance;
    
    // Bizygomatic width: 447 (left zygion) to 227 (right zygion)
    final bizygomaticWidth = (meshPoints[447] - meshPoints[227]).distance;
    
    return icDistance / bizygomaticWidth;
  }

  /// F-09: FWHR (Facial Width-to-Height Ratio)
  /// Bizygomatic width divided by height from point 9 to labiale superius
  double calculateFWHR(List<Offset> meshPoints) {
    // Bizygomatic width: 447 (left zygion) to 227 (right zygion)
    final bizygomaticWidth = (meshPoints[447] - meshPoints[227]).distance;
    
    // Vertical height: 9 to 0 (labiale superius) - CORRECTED
    final height = (meshPoints[9] - meshPoints[0]).distance;
    
    return bizygomaticWidth / height;
  }

  /// F-10: ICD / Inter-Alar Distance
  /// Ratio of inter-canthal distance to inter-alar distance (nose width)
  double calculateICD(List<Offset> meshPoints) {
    // Inner canthi: 362 (left) and 133 (right)
    final icDistance = (meshPoints[362] - meshPoints[133]).distance;
    
    // Inter-alar distance (nose width): 278 (left) and 102 (right)
    final interAlarDistance = (meshPoints[278] - meshPoints[102]).distance;
    
    return icDistance / interAlarDistance;
  }

  /// F-11: Nose-/Mouth Width
  /// Ratio of alar width to mouth width
  double calculateNoseMouthWidthRatio(List<Offset> meshPoints) {
    // Alare: 278 (left) and 102 (right)
    final alarWidth = (meshPoints[278] - meshPoints[102]).distance;
    
    // Cheilion: 291 (left) and 61 (right)
    final mouthWidth = (meshPoints[291] - meshPoints[61]).distance;
    
    return alarWidth / mouthWidth;
  }

  /// F-15: Jaw (Bigonial) Angle
  /// Calculate angle between jaw tangent lines using specific arc landmarks
  double calculateJawAngle(List<Offset> meshPoints) {
    // Left jaw arc tangent calculation
    // Tangent point: landmark 365, neighbors: 397 and 379
    final x397 = meshPoints[397].dx, y397 = meshPoints[397].dy;
    final x365 = meshPoints[365].dx, y365 = meshPoints[365].dy;
    final x379 = meshPoints[379].dx, y379 = meshPoints[379].dy;
    
    // Right jaw arc tangent calculation  
    // Tangent point: landmark 136, neighbors: 172 and 150
    final x172 = meshPoints[172].dx, y172 = meshPoints[172].dy;
    final x136 = meshPoints[136].dx, y136 = meshPoints[136].dy;
    final x150 = meshPoints[150].dx, y150 = meshPoints[150].dy;
    
    // Compute direction vectors for tangent lines
    // Left tangent vector: v_L = L₂ - L₁ = (x379 - x397, y379 - y397)
    final vlX = x379 - x397;
    final vlY = y379 - y397;
    
    // Right tangent vector: v_R = R₂ - R₁ = (x150 - x172, y150 - y172)  
    final vrX = x150 - x172;
    final vrY = y150 - y172;
    
    // Calculate dot product and magnitudes
    final dot = (vlX * vrX) + (vlY * vrY);
    final lenL = sqrt(vlX * vlX + vlY * vlY);
    final lenR = sqrt(vrX * vrX + vrY * vrY);
    
    // Avoid division by zero
    if (lenL == 0 || lenR == 0) {
      return 180.0; // Default angle if vectors have zero length
    }
    
    // Calculate angle between the tangent lines
    final cosAngle = (dot / (lenL * lenR)).clamp(-1.0, 1.0);
    final thetaRad = acos(cosAngle);
    final bigonialAngleDeg = thetaRad * 180.0 / pi;
    
    return bigonialAngleDeg;
  }

  /// F-17: Brow Tilt
  /// Calculate individual left and right brow tilts relative to cheekbone baseline
  Map<String, dynamic> calculateBrowTilt(List<Offset> meshPoints) {
    // Cheekbone baseline: 447 (left) to 227 (right)
    final leftCheekbone = meshPoints[447];
    final rightCheekbone = meshPoints[227];
    
    // Calculate cheekbone line angle (horizontal reference)
    final cheekboneVector = Offset(
      rightCheekbone.dx - leftCheekbone.dx,
      rightCheekbone.dy - leftCheekbone.dy
    );
    final cheekboneAngle = atan2(cheekboneVector.dy, cheekboneVector.dx);
    
    // LEFT EYEBROW
    // Inner landmarks: 285 (bottom), 336 (top)
    final leftInnerTop = meshPoints[336];
    final leftInnerBottom = meshPoints[285];
    final leftInnerMidpoint = Offset(
      (leftInnerTop.dx + leftInnerBottom.dx) / 2,
      (leftInnerTop.dy + leftInnerBottom.dy) / 2
    );
    
    // Outer landmarks: 282 (bottom), 334 (top) 
    final leftOuterTop = meshPoints[334];
    final leftOuterBottom = meshPoints[282];
    final leftOuterMidpoint = Offset(
      (leftOuterTop.dx + leftOuterBottom.dx) / 2,
      (leftOuterTop.dy + leftOuterBottom.dy) / 2
    );
    
    // LEFT BROW LINE: inner midpoint to outer midpoint
    final leftBrowVector = Offset(
      leftOuterMidpoint.dx - leftInnerMidpoint.dx,
      leftOuterMidpoint.dy - leftInnerMidpoint.dy
    );
    final leftBrowAngle = atan2(leftBrowVector.dy, leftBrowVector.dx);
    
    // RIGHT EYEBROW  
    // Inner landmarks: 55 (bottom), 107 (top)
    final rightInnerTop = meshPoints[107];
    final rightInnerBottom = meshPoints[55];
    final rightInnerMidpoint = Offset(
      (rightInnerTop.dx + rightInnerBottom.dx) / 2,
      (rightInnerTop.dy + rightInnerBottom.dy) / 2
    );
    
    // Outer landmarks: 52 (bottom), 105 (top)
    final rightOuterTop = meshPoints[105];
    final rightOuterBottom = meshPoints[52];
    final rightOuterMidpoint = Offset(
      (rightOuterTop.dx + rightOuterBottom.dx) / 2,
      (rightOuterTop.dy + rightOuterBottom.dy) / 2
    );
    
    // RIGHT BROW LINE: inner midpoint to outer midpoint  
    final rightBrowVector = Offset(
      rightOuterMidpoint.dx - rightInnerMidpoint.dx,
      rightOuterMidpoint.dy - rightInnerMidpoint.dy
    );
    final rightBrowAngle = atan2(rightBrowVector.dy, rightBrowVector.dx);
    
    // Calculate tilts relative to cheekbone baseline
    double leftTilt = (leftBrowAngle - cheekboneAngle) * 180 / pi;
    double rightTilt = (rightBrowAngle - cheekboneAngle) * 180 / pi;
    
    // Normalize to [-180, 180] range
    while (leftTilt > 180) {
      leftTilt -= 360;
    }
    while (leftTilt < -180) {
      leftTilt += 360;
    }
    while (rightTilt > 180) {
      rightTilt -= 360;
    }
    while (rightTilt < -180) {
      rightTilt += 360;
    }
    
    // Convert obtuse angles to acute angles (take complement if > 90° or < -90°)
    if (leftTilt.abs() > 90) {
      leftTilt = leftTilt > 0 ? 180 - leftTilt : -180 - leftTilt;
    }
    
    if (rightTilt.abs() > 90) {
      rightTilt = rightTilt > 0 ? 180 - rightTilt : -180 - rightTilt;
    }
    
    // Calculate average
    final averageTilt = (leftTilt + rightTilt) / 2;
    
    return {
      'left': leftTilt,
      'right': rightTilt,
      'average': averageTilt,
    };
  }

  /// F-19: Golden-Ratio Highlights
  /// Average % deviation from golden ratio (φ = 1.618) for facial triplets
  double calculateGoldenRatioDeviation(List<Offset> meshPoints) {
    const goldenRatio = 1.618;
    
    // Triplet 1: 168 (nasion) - 2 (subnasale) - 152 (menton)
    final t1a = (meshPoints[168] - meshPoints[2]).distance;
    final t1b = (meshPoints[2] - meshPoints[152]).distance;
    final ratio1 = t1a / t1b;
    
    // Triplet 2: midpoint of inner canthi - point 1 (middle of nose) - 152 (menton)
    final innerCanthiMidpoint = Offset(
      (meshPoints[362].dx + meshPoints[133].dx) / 2,
      (meshPoints[362].dy + meshPoints[133].dy) / 2
    );
    final t2a = (innerCanthiMidpoint - meshPoints[1]).distance;
    final t2b = (meshPoints[1] - meshPoints[152]).distance;
    final ratio2 = t2a / t2b;
    
    // Triplet 3: 1 (middle of nose) - 0 (labiale superius) - 17 (middle of chin)
    final t3a = (meshPoints[1] - meshPoints[0]).distance;
    final t3b = (meshPoints[0] - meshPoints[17]).distance;
    final ratio3 = t3a / t3b;
    
    // Calculate % deviations from golden ratio
    final deviation1 = (ratio1 - goldenRatio).abs() / goldenRatio * 100;
    final deviation2 = (ratio2 - goldenRatio).abs() / goldenRatio * 100;
    final deviation3 = (ratio3 - goldenRatio).abs() / goldenRatio * 100;
    
    // Return average deviation
    return (deviation1 + deviation2 + deviation3) / 3;
  }

  /// F-20: Philtrum Length Ratio
  /// Ratio of vertical philtrum length to vertical chin length
  double calculatePhiltrumLengthRatio(List<Offset> meshPoints) {
    // Philtrum points: 2 (subnasale) to 0 (labiale superius)
    final subnasale = meshPoints[2];
    final labialeSuperius = meshPoints[0];
    
    // Chin points: 17 (middle of chin) to 152 (menton)
    final chinMiddle = meshPoints[17];
    final menton = meshPoints[152];
    
    // Project philtrum length vertically (pure Y distance)
    final philtrumLength = (labialeSuperius.dy - subnasale.dy).abs();
    
    // Project chin length vertically (pure Y distance)
    final chinLength = (menton.dy - chinMiddle.dy).abs();
    
    return philtrumLength / chinLength;
  }

  /// F-21: Facial Fifths
  /// Calculate the classical facial fifths proportions and return a score 0-100
  /// Based on how close each fifth is to the ideal 20% of face width
  double calculateFacialFifths(List<Offset> meshPoints) {
    // Define the six landmark points
    final leftmostPoint = meshPoints[454];    // leftmost point on face
    final outerLeftEye = meshPoints[263];     // outer left eye
    final innerLeftEye = meshPoints[362];     // inner left eye  
    final innerRightEye = meshPoints[173];    // inner right eye
    final outerRightEye = meshPoints[33];     // outer right eye
    final rightmostPoint = meshPoints[234];   // rightmost point on face
    
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
    
    // Calculate the five fifths distances
    final fifth1 = (projectedPoints[1] - projectedPoints[0]).distance; // leftmost to outer left eye
    final fifth2 = (projectedPoints[2] - projectedPoints[1]).distance; // outer left eye to inner left eye
    final fifth3 = (projectedPoints[3] - projectedPoints[2]).distance; // inner left eye to inner right eye
    final fifth4 = (projectedPoints[4] - projectedPoints[3]).distance; // inner right eye to outer right eye
    final fifth5 = (projectedPoints[5] - projectedPoints[4]).distance; // outer right eye to rightmost
    
    // Calculate total face width
    final totalWidth = fifth1 + fifth2 + fifth3 + fifth4 + fifth5;
    
    // Calculate percentage for each fifth
    final p1 = (fifth1 / totalWidth) * 100;
    final p2 = (fifth2 / totalWidth) * 100;
    final p3 = (fifth3 / totalWidth) * 100;
    final p4 = (fifth4 / totalWidth) * 100;
    final p5 = (fifth5 / totalWidth) * 100;
    
    // Calculate deviations from ideal 20%
    final delta1 = (p1 - 20.0).abs();
    final delta2 = (p2 - 20.0).abs();
    final delta3 = (p3 - 20.0).abs();
    final delta4 = (p4 - 20.0).abs();
    final delta5 = (p5 - 20.0).abs();
    
    // Sum total deviation
    final totalDeviation = delta1 + delta2 + delta3 + delta4 + delta5;
    
    // Convert to score (0-100) using the provided formula
    // Maximum possible deviation is 160 (one fifth at 100%, others at 0%)
    final score = 100 * (1 - (totalDeviation / 160));
    
    // Ensure score is within bounds
    return score.clamp(0.0, 100.0);
  }

  // Helper method to average a list of points
  Offset _averagePoints(List<Offset> points) {
    double sumX = 0, sumY = 0;
    for (final point in points) {
      sumX += point.dx;
      sumY += point.dy;
    }
    return Offset(sumX / points.length, sumY / points.length);
  }
} 