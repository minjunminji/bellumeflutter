enum MeasurementCategory {
  excellent,
  good, 
  average,
  needsImprovement
}

class MeasurementResult {
  final String id;
  final String name;
  final double value;
  final double idealValue;
  final String unit;
  final int percentile;
  final MeasurementCategory category;
  final String description;
  final List<String> tips;
  
  const MeasurementResult({
    required this.id,
    required this.name,
    required this.value,
    required this.idealValue,
    required this.unit,
    required this.percentile,
    required this.category,
    required this.description,
    required this.tips,
  });

  factory MeasurementResult.fromJson(Map<String, dynamic> json) {
    return MeasurementResult(
      id: json['id'] as String,
      name: json['name'] as String,
      value: (json['value'] as num).toDouble(),
      idealValue: (json['idealValue'] as num).toDouble(),
      unit: json['unit'] as String,
      percentile: json['percentile'] as int,
      category: MeasurementCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => MeasurementCategory.average,
      ),
      description: json['description'] as String,
      tips: List<String>.from(json['tips'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'value': value,
      'idealValue': idealValue,
      'unit': unit,
      'percentile': percentile,
      'category': category.name,
      'description': description,
      'tips': tips,
    };
  }
} 