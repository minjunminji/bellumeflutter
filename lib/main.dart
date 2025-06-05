import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/theme/app_theme.dart';
import 'data/models/facial_metrics_hive.dart';
import 'data/models/scan_result.dart';
import 'data/services/scan_storage_service.dart';
import 'presentation/routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(FacialMetricsHiveAdapter());
  Hive.registerAdapter(ScanResultHiveAdapter());
  
  // Initialize storage service
  await ScanStorageService.instance.initialize();
  
  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://qurxiucbjbaybrdfkgmg.supabase.co', // Replace with actual URL
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF1cnhpdWNiamJheWJyZGZrZ21nIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDg5OTg4ODQsImV4cCI6MjA2NDU3NDg4NH0.RQuD3OdQHiOyDrCW5wrIUJczD8eFu6LTK4cKLoFRdM0', // Replace with actual key
  );
  
  runApp(const ProviderScope(child: BellumeApp()));
}

class BellumeApp extends ConsumerWidget {
  const BellumeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    
    return MaterialApp.router(
      title: 'Bellume',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
} 