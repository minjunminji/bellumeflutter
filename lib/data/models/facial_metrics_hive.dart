import 'package:hive/hive.dart';

part 'facial_metrics_hive.g.dart';

@HiveType(typeId: 0)
class FacialMetricsHive extends HiveObject {
  @HiveField(0)
  final double bizygomaticWidth;
  
  @HiveField(1) 
  final double intercanthalDistance;
  
  @HiveField(2)
  final DateTime timestamp;
  
  @HiveField(3)
  final String id;

  FacialMetricsHive({
    required this.bizygomaticWidth,
    required this.intercanthalDistance,
    required this.timestamp,
    required this.id,
  });
}

class FacialMetrics {
  final double bizygomaticWidth;
  final double intercanthalDistance;
  final DateTime timestamp;
  final String id;
  
  const FacialMetrics({
    required this.bizygomaticWidth,
    required this.intercanthalDistance,
    required this.timestamp,
    required this.id,
  });

  factory FacialMetrics.fromHive(FacialMetricsHive hive) {
    return FacialMetrics(
      bizygomaticWidth: hive.bizygomaticWidth,
      intercanthalDistance: hive.intercanthalDistance,
      timestamp: hive.timestamp,
      id: hive.id,
    );
  }

  FacialMetricsHive toHive() {
    return FacialMetricsHive(
      bizygomaticWidth: bizygomaticWidth,
      intercanthalDistance: intercanthalDistance,
      timestamp: timestamp,
      id: id,
    );
  }

  factory FacialMetrics.fromJson(Map<String, dynamic> json) {
    return FacialMetrics(
      bizygomaticWidth: (json['bizygomaticWidth'] as num).toDouble(),
      intercanthalDistance: (json['intercanthalDistance'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      id: json['id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bizygomaticWidth': bizygomaticWidth,
      'intercanthalDistance': intercanthalDistance,
      'timestamp': timestamp.toIso8601String(),
      'id': id,
    };
  }
} 