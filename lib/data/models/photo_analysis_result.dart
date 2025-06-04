enum PhotoQuality { 
  excellent, 
  good, 
  average, 
  poor 
}

class PhotoAnalysisResult {
  final double bizygomaticWidth;
  final double intercanthalDistance;
  final double facialThirdsRatio;
  final PhotoQuality photoQuality;
  final double confidence;
  
  const PhotoAnalysisResult({
    required this.bizygomaticWidth,
    required this.intercanthalDistance,
    required this.facialThirdsRatio,
    required this.photoQuality,
    required this.confidence,
  });

  factory PhotoAnalysisResult.fromJson(Map<String, dynamic> json) {
    return PhotoAnalysisResult(
      bizygomaticWidth: (json['bizygomaticWidth'] as num).toDouble(),
      intercanthalDistance: (json['intercanthalDistance'] as num).toDouble(),
      facialThirdsRatio: (json['facialThirdsRatio'] as num).toDouble(),
      photoQuality: PhotoQuality.values.firstWhere(
        (e) => e.name == json['photoQuality'],
        orElse: () => PhotoQuality.average,
      ),
      confidence: (json['confidence'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bizygomaticWidth': bizygomaticWidth,
      'intercanthalDistance': intercanthalDistance,
      'facialThirdsRatio': facialThirdsRatio,
      'photoQuality': photoQuality.name,
      'confidence': confidence,
    };
  }
} 