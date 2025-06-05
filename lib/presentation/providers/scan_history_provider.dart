import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/scan_result.dart';
import '../../data/services/scan_storage_service.dart';

// Provider for scan storage service
final scanStorageServiceProvider = Provider<ScanStorageService>((ref) {
  return ScanStorageService.instance;
});

// Provider for all scan results
final scanHistoryProvider = FutureProvider<List<ScanResult>>((ref) async {
  final storageService = ref.watch(scanStorageServiceProvider);
  return await storageService.getAllScanResults();
});

// Provider for scan count
final scanCountProvider = FutureProvider<int>((ref) async {
  final storageService = ref.watch(scanStorageServiceProvider);
  return await storageService.getScanCount();
});

// Provider for latest scan
final latestScanProvider = FutureProvider<ScanResult?>((ref) async {
  final storageService = ref.watch(scanStorageServiceProvider);
  return await storageService.getLatestScan();
});

// Provider for recent scans (limited)
final recentScansProvider = FutureProvider<List<ScanResult>>((ref) async {
  final storageService = ref.watch(scanStorageServiceProvider);
  return await storageService.getRecentScans(limit: 3);
});

// Notifier for managing scan history state
class ScanHistoryNotifier extends StateNotifier<AsyncValue<List<ScanResult>>> {
  final ScanStorageService _storageService;

  ScanHistoryNotifier(this._storageService) : super(const AsyncValue.loading()) {
    _loadScanHistory();
  }

  Future<void> _loadScanHistory() async {
    try {
      state = const AsyncValue.loading();
      final results = await _storageService.getAllScanResults();
      state = AsyncValue.data(results);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> refresh() async {
    await _loadScanHistory();
  }

  Future<void> deleteScan(String id) async {
    try {
      await _storageService.deleteScanResult(id);
      await _loadScanHistory(); // Refresh after deletion
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> clearAllScans() async {
    try {
      await _storageService.clearAllData();
      await _loadScanHistory(); // Refresh after clearing
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

// StateNotifier provider for managing scan history
final scanHistoryNotifierProvider = StateNotifierProvider<ScanHistoryNotifier, AsyncValue<List<ScanResult>>>((ref) {
  final storageService = ref.watch(scanStorageServiceProvider);
  return ScanHistoryNotifier(storageService);
});

// Provider for metric history
final metricHistoryProvider = FutureProvider.family<List<double>, String>((ref, metricId) async {
  final storageService = ref.watch(scanStorageServiceProvider);
  return await storageService.getMetricHistory(metricId);
}); 