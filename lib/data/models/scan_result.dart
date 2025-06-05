import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'scan_result.g.dart';

@HiveType(typeId: 1)
class ScanResultHive extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final DateTime timestamp;
  
  @HiveField(2)
  final String frontImagePath;
  
  @HiveField(3)
  final String? sideImagePath;
  
  @HiveField(4)
  final Map<String, dynamic> metrics;
  
  @HiveField(5)
  final int meshPointsCount;

  ScanResultHive({
    required this.id,
    required this.timestamp,
    required this.frontImagePath,
    this.sideImagePath,
    required this.metrics,
    required this.meshPointsCount,
  });
}

class ScanResult {
  final String id;
  final DateTime timestamp;
  final String frontImagePath;
  final String? sideImagePath;
  final Map<String, dynamic> metrics;
  final int meshPointsCount;
  
  const ScanResult({
    required this.id,
    required this.timestamp,
    required this.frontImagePath,
    this.sideImagePath,
    required this.metrics,
    required this.meshPointsCount,
  });

  factory ScanResult.create({
    required String frontImagePath,
    String? sideImagePath,
    required Map<String, dynamic> metrics,
    required int meshPointsCount,
  }) {
    return ScanResult(
      id: const Uuid().v4(),
      timestamp: DateTime.now(),
      frontImagePath: frontImagePath,
      sideImagePath: sideImagePath,
      metrics: metrics,
      meshPointsCount: meshPointsCount,
    );
  }

  factory ScanResult.fromHive(ScanResultHive hive) {
    return ScanResult(
      id: hive.id,
      timestamp: hive.timestamp,
      frontImagePath: hive.frontImagePath,
      sideImagePath: hive.sideImagePath,
      metrics: hive.metrics,
      meshPointsCount: hive.meshPointsCount,
    );
  }

  ScanResultHive toHive() {
    return ScanResultHive(
      id: id,
      timestamp: timestamp,
      frontImagePath: frontImagePath,
      sideImagePath: sideImagePath,
      metrics: metrics,
      meshPointsCount: meshPointsCount,
    );
  }

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    return ScanResult(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      frontImagePath: json['frontImagePath'] as String,
      sideImagePath: json['sideImagePath'] as String?,
      metrics: Map<String, dynamic>.from(json['metrics'] as Map),
      meshPointsCount: json['meshPointsCount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'frontImagePath': frontImagePath,
      'sideImagePath': sideImagePath,
      'metrics': metrics,
      'meshPointsCount': meshPointsCount,
    };
  }

  // Helper methods for accessing specific metrics
  double? getMetric(String metricId) {
    return metrics[metricId] as double?;
  }

  String getFormattedDate() {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${timestamp.month}/${timestamp.day}/${timestamp.year}';
    }
  }

  String getFormattedTime() {
    final hour = timestamp.hour % 12;
    final displayHour = hour == 0 ? 12 : hour;
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final period = timestamp.hour >= 12 ? 'PM' : 'AM';
    return '$displayHour:$minute $period';
  }
} 