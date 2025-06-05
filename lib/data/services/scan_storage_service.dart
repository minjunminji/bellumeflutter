import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/scan_result.dart';

class ScanStorageService {
  static const String _boxName = 'scan_results';
  static const String _imagesDir = 'scan_images';
  
  static ScanStorageService? _instance;
  Box<ScanResultHive>? _box;
  
  static ScanStorageService get instance {
    _instance ??= ScanStorageService._();
    return _instance!;
  }
  
  ScanStorageService._();

  Future<void> initialize() async {
    if (_box?.isOpen == true) return;
    
    _box = await Hive.openBox<ScanResultHive>(_boxName);
  }

  Future<String> _saveImageToStorage(File imageFile, String filename) async {
    final appDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${appDir.path}/$_imagesDir');
    
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }
    
    final savedImagePath = '${imagesDir.path}/$filename';
    await imageFile.copy(savedImagePath);
    
    return savedImagePath;
  }

  Future<ScanResult> saveScanResult({
    required File frontImage,
    File? sideImage,
    required Map<String, dynamic> metrics,
    required int meshPointsCount,
  }) async {
    await initialize();
    
    final timestamp = DateTime.now();
    final id = timestamp.millisecondsSinceEpoch.toString();
    
    // Save images to persistent storage
    final frontImagePath = await _saveImageToStorage(
      frontImage, 
      'front_$id.jpg'
    );
    
    String? sideImagePath;
    if (sideImage != null) {
      sideImagePath = await _saveImageToStorage(
        sideImage, 
        'side_$id.jpg'
      );
    }
    
    final scanResult = ScanResult.create(
      frontImagePath: frontImagePath,
      sideImagePath: sideImagePath,
      metrics: metrics,
      meshPointsCount: meshPointsCount,
    );
    
    // Save to Hive
    await _box!.put(scanResult.id, scanResult.toHive());
    
    return scanResult;
  }

  Future<List<ScanResult>> getAllScanResults() async {
    await initialize();
    
    final results = _box!.values
        .map((hive) => ScanResult.fromHive(hive))
        .toList();
    
    // Sort by timestamp, newest first
    results.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    return results;
  }

  Future<ScanResult?> getScanResult(String id) async {
    await initialize();
    
    final hiveResult = _box!.get(id);
    if (hiveResult == null) return null;
    
    return ScanResult.fromHive(hiveResult);
  }

  Future<void> deleteScanResult(String id) async {
    await initialize();
    
    final scanResult = await getScanResult(id);
    if (scanResult != null) {
      // Delete image files
      try {
        await File(scanResult.frontImagePath).delete();
        if (scanResult.sideImagePath != null) {
          await File(scanResult.sideImagePath!).delete();
        }
      } catch (e) {
        print('Error deleting image files: $e');
      }
      
      // Delete from Hive
      await _box!.delete(id);
    }
  }

  Future<int> getScanCount() async {
    await initialize();
    return _box!.length;
  }

  Future<ScanResult?> getLatestScan() async {
    final results = await getAllScanResults();
    return results.isNotEmpty ? results.first : null;
  }

  Future<List<ScanResult>> getRecentScans({int limit = 5}) async {
    final results = await getAllScanResults();
    return results.take(limit).toList();
  }

  // Get metrics history for a specific metric
  Future<List<double>> getMetricHistory(String metricId) async {
    final results = await getAllScanResults();
    return results
        .map((result) => result.getMetric(metricId))
        .where((value) => value != null)
        .cast<double>()
        .toList();
  }

  Future<void> clearAllData() async {
    await initialize();
    
    // Delete all image files
    final appDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${appDir.path}/$_imagesDir');
    
    if (await imagesDir.exists()) {
      await imagesDir.delete(recursive: true);
    }
    
    // Clear Hive box
    await _box!.clear();
  }
} 