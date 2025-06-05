import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../data/models/scan_result.dart';
import '../../providers/auth_provider.dart';
import '../../providers/scan_history_provider.dart';
import '../scan/scan_screen.dart';
import '../scan/scan_history_screen.dart';
import '../scan/scan_detail_screen.dart';
import '../../../presentation/routes/app_router.dart'; // Import for MetricProgressScreenParams
// MetricProgressScreen is imported via app_router.dart indirectly or directly if needed by type system

// Define the list of metrics available for progress tracking
final List<Map<String, String>> _progressMetrics = [
  {'id': 'F-02', 'name': 'Symmetry RMS', 'description': 'Facial symmetry measurement'},
  {'id': 'F-03', 'name': 'Canthal Tilt', 'description': 'Eye angles relative to cheekbone line'},
  {'id': 'F-04', 'name': 'Eye Shape (H:W)', 'description': 'Eye height to width ratio'},
  {'id': 'F-05', 'name': 'Inter-canthal / Bizygomatic', 'description': 'Ratio of inner canthal distance to face width'},
  {'id': 'F-09', 'name': 'FWHR', 'description': 'Facial Width-to-Height Ratio'},
  {'id': 'F-10', 'name': 'ICD / Inter-Alar Ratio', 'description': 'Inter-Canthal Distance to Inter-Alar Distance Ratio'},
  {'id': 'F-11', 'name': 'Nose/Mouth Width', 'description': 'Ratio of nose width to mouth width'},
  {'id': 'F-15', 'name': 'Jaw (Bigonial) Angle', 'description': 'Angle between jaw tangent lines'},
  {'id': 'F-17', 'name': 'Brow Tilt', 'description': 'Individual left and right eyebrow tilts'},
  {'id': 'F-19', 'name': 'Golden-Ratio Deviation', 'description': 'Deviation from golden ratio in facial proportions'},
  {'id': 'F-20', 'name': 'Philtrum Length Ratio', 'description': 'Philtrum length relative to facial height'},
  {'id': 'F-21', 'name': 'Facial Fifths', 'description': 'Classical facial fifths proportions'},
];

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> 
    with TickerProviderStateMixin {
  bool _isOverallScoreExpanded = false;
  bool _isMetricsExpanded = false;
  bool _isRecentScansExpanded = false;
  String? _expandedMetricId;
  
  late AnimationController _overallScoreController;
  late AnimationController _metricsController;
  late AnimationController _recentScansController;
  late Animation<double> _overallScoreAnimation;
  late Animation<double> _metricsAnimation;
  late Animation<double> _recentScansAnimation;

  @override
  void initState() {
    super.initState();
    _overallScoreController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _metricsController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _recentScansController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _overallScoreAnimation = CurvedAnimation(
      parent: _overallScoreController,
      curve: Curves.easeInOut,
    );
    _metricsAnimation = CurvedAnimation(
      parent: _metricsController,
      curve: Curves.easeInOut,
    );
    _recentScansAnimation = CurvedAnimation(
      parent: _recentScansController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _overallScoreController.dispose();
    _metricsController.dispose();
    _recentScansController.dispose();
    super.dispose();
  }

  void _toggleOverallScore() {
    setState(() {
      _isOverallScoreExpanded = !_isOverallScoreExpanded;
      if (_isOverallScoreExpanded) {
        _overallScoreController.forward();
      } else {
        _overallScoreController.reverse();
      }
    });
  }

  void _toggleRecentScans() {
    setState(() {
      _isRecentScansExpanded = !_isRecentScansExpanded;
      if (_isRecentScansExpanded) {
        _recentScansController.forward();
      } else {
        _recentScansController.reverse();
      }
    });
  }

  void _toggleMetric(String metricId) {
    setState(() {
      if (_expandedMetricId == metricId) {
        _expandedMetricId = null;
        _metricsController.reverse();
      } else {
        _expandedMetricId = metricId;
        _metricsController.forward();
      }
    });
  }

  // Helper method to calculate dynamic height for Recent Scans
  double _calculateRecentScansHeight(int scanCount) {
    if (scanCount == 0) {
      return 200; // Height for "No scans yet" widget
    }
    
    const double scanItemHeight = 92.0; // Estimated height per scan item (60px thumbnail + 32px padding)
    const double separatorHeight = 1.0; // Height of separator between items
    const double maxScansBeforeScroll = 3; // Show max 3 scans before scrolling
    
    // Calculate height needed for the scans
    final double scansHeight = (scanCount * scanItemHeight) + ((scanCount - 1) * separatorHeight);
    final double maxHeight = (maxScansBeforeScroll * scanItemHeight) + ((maxScansBeforeScroll - 1) * separatorHeight);
    
    // Return the smaller of actual height needed or max height (for scrolling)
    return scansHeight < maxHeight ? scansHeight : maxHeight;
  }

  (List<FlSpot>, List<DateTime>, double, double, double, double) _prepareChartData(List<ScanResult> allScans, String metricId) {
    List<FlSpot> spots = [];
    List<DateTime> dates = [];
    double minX = 0, maxX = 0, minY = 0, maxY = 0;

    if (allScans.isEmpty) {
      return (spots, dates, minX, maxX, minY, maxY);
    }

    // Sort scans by date to ensure chronological order for the chart
    List<ScanResult> sortedScans = List.from(allScans);
    sortedScans.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    for (int i = 0; i < sortedScans.length; i++) {
      final scan = sortedScans[i];
      final metricValue = scan.metrics[metricId];

      if (metricValue != null && metricValue is num) {
        spots.add(FlSpot(i.toDouble(), metricValue.toDouble()));
        dates.add(scan.timestamp);
      } else if (metricValue != null && metricValue is Map && metricValue.containsKey('mean')) {
        final meanValue = metricValue['mean'];
        if (meanValue != null && meanValue is num) {
          spots.add(FlSpot(i.toDouble(), meanValue.toDouble()));
          dates.add(scan.timestamp);
        }
      }
    }

    if (spots.isNotEmpty) {
      minX = spots.first.x;
      maxX = spots.last.x;
      minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
      maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);

      final yRange = maxY - minY;
      if (yRange > 0) {
        minY -= yRange * 0.1;
        maxY += yRange * 0.1;
      } else {
        minY = minY > 0 ? minY - (minY * 0.1).abs() -1 : minY -1; 
        maxY = maxY > 0 ? maxY + (maxY * 0.1).abs() +1: maxY + 1;
        if (minY == maxY && spots.isNotEmpty) { 
             minY -= 1;
             maxY += 1;
        }
      }
      if (spots.every((s) => s.y >= 0) && minY < 0) {
        minY = 0;
      }
      if (minX == maxX && spots.length == 1) {
        maxX += 1;
      } else if (minX == maxX) {
        minX -= 0.5;
        maxX += 0.5;
      }
       if (minY == maxY) {
        minY -= 0.5;
        maxY += 0.5;
      }
    }
    return (spots, dates, minX, maxX, minY, maxY);
  }

  Widget _buildChart(String metricId) {
    final scanHistoryAsync = ref.watch(scanHistoryNotifierProvider);
    
    return scanHistoryAsync.when(
      data: (allScans) {
        final (spots, dates, minX, maxX, minY, maxY) = _prepareChartData(allScans, metricId);

        if (spots.isEmpty) {
          return Container(
            height: 200,
            child: Center(
              child: Text(
                'No data available',
                style: AppTextStyles.bodySecondary,
              ),
            ),
          );
        }

        return Container(
          height: 200,
          child: LineChart(
            LineChartData(
              minX: minX,
              maxX: maxX,
              minY: minY,
              maxY: maxY,
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: spots.length > 1 ? (spots.length / (spots.length > 5 ? 4 : spots.length -1) ).ceilToDouble().clamp(1, spots.length.toDouble()) : 1,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= dates.length) {
                        return Container();
                      }
                      if (dates.isNotEmpty && index < dates.length) {
                         return SideTitleWidget(
                            axisSide: meta.axisSide,
                            space: 8.0,
                            child: Text(
                              DateFormat('MMM d').format(dates[index]),
                              style: AppTextStyles.caption,
                            ),
                         );
                      }
                      return Container();
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: (maxY - minY) > 0 ? ((maxY - minY) / 4).clamp(0.1, (maxY-minY)) : 1.0,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 4.0, 
                          child: Text(value.toStringAsFixed(minY.abs() < 1 && maxY.abs() < 1 && (maxY-minY) !=0 ? 2:1 ), style: AppTextStyles.caption, textAlign: TextAlign.left)
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: AppColors.border, width: 1),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: AppColors.primary,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: spots.length == 1 ? true : false),
                  belowBarData: BarAreaData(show: false),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => Container(
        height: 200,
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Container(
        height: 200,
        child: Center(
          child: Text(
            'Error loading chart data',
            style: AppTextStyles.bodySecondary,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final recentScans = ref.watch(recentScansProvider);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Main content
          SingleChildScrollView(
            padding: AppSpacing.screenPadding.copyWith(bottom: 140), // Add bottom padding for button
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Add top padding for status bar
                SizedBox(height: MediaQuery.of(context).padding.top + 4),
                
                // Dashboard title
                Text(
                  'Dashboard',
                  style: AppTextStyles.heading1,
                ),
                const SizedBox(height: AppSpacing.xl),
                
                // Recent Scans section
                _buildRecentScansSection(context, recentScans),
                const SizedBox(height: AppSpacing.xl),

                // Track Your Progress section
                _buildProgressSection(context),
              ],
            ),
          ),
          
          // Wide New Scan button positioned above nav bar
          Positioned(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).padding.bottom + 24, // Adjusted from 80 to 24
            child: Container(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => const ScanScreen(),
                      transitionDuration: const Duration(milliseconds: 300),
                      reverseTransitionDuration: const Duration(milliseconds: 300),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 1),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeInOut,
                          )),
                          child: child,
                        );
                      },
                    ),
                  );
                },
                icon: const Icon(Icons.camera_alt, size: 24),
                label: const Text(
                  'New Scan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 8,
                  shadowColor: AppColors.primary.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentScansSection(BuildContext context, AsyncValue<List<ScanResult>> recentScans) {
    final allScans = ref.watch(scanHistoryNotifierProvider);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Scans',
                  style: AppTextStyles.heading2,
                ),
                recentScans.when(
                  data: (scans) => scans.isNotEmpty ? TextButton(
                    onPressed: _toggleRecentScans,
                    child: Text(_isRecentScansExpanded ? 'Show Less' : 'View All'),
                  ) : const SizedBox.shrink(),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          
          // Animated container for scans
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: recentScans.when(
              data: (scans) {
                final scansToShow = _isRecentScansExpanded 
                    ? allScans.when(
                        data: (allScansList) => allScansList,
                        loading: () => scans,
                        error: (_, __) => scans,
                      )
                    : scans;
                
                return _isRecentScansExpanded 
                    ? MediaQuery.of(context).size.height * 0.6 // Use full height when expanded
                    : _calculateRecentScansHeight(scansToShow.length); // Use dynamic height when collapsed
              },
              loading: () => 100.0, // Small height for loading indicator
              error: (_, __) => 200.0, // Default height for error
            ),
            child: recentScans.when(
              data: (scans) {
                if (scans.isEmpty) {
                  return _buildNoScansWidget(context);
                }
                
                // Show all scans when expanded, recent scans when collapsed
                final scansToShow = _isRecentScansExpanded 
                    ? allScans.when(
                        data: (allScansList) => allScansList,
                        loading: () => scans,
                        error: (_, __) => scans,
                      )
                    : scans;
                
                return ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: scansToShow.length,
                  separatorBuilder: (context, index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    height: 1,
                    color: Colors.grey.shade200,
                  ),
                  itemBuilder: (context, index) {
                    final scan = scansToShow[index];
                    return _buildScanResultCard(context, scan);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Container(
                padding: AppSpacing.cardPadding,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Error loading scans',
                      style: AppTextStyles.heading2.copyWith(color: Colors.red),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      error.toString(),
                      style: AppTextStyles.bodySecondary,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Overall Score Section
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Bellume Score',
                      style: AppTextStyles.heading2,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '8.2',
                          style: AppTextStyles.heading1.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Dec 5, 2024',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Full-width divider
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  height: 200,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.bar_chart,
                          size: 48,
                          color: AppColors.textLight,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Overall Score Chart',
                          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'Coming Soon',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Individual Metrics Section
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Text(
                      'Individual Metrics',
                      style: AppTextStyles.heading2,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Container(
                height: 300, // Fixed height for scrollable area
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: _progressMetrics.length,
                  separatorBuilder: (context, index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    height: 1,
                    color: Colors.grey.shade200,
                  ),
                  itemBuilder: (context, index) {
                    final metric = _progressMetrics[index];
                    final isExpanded = _expandedMetricId == metric['id'];
                    
                    return Column(
                      children: [
                        InkWell(
                          onTap: () => _toggleMetric(metric['id']!),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        metric['name']!,
                                        style: AppTextStyles.body,
                                      ),
                                    ],
                                  ),
                                ),
                                AnimatedRotation(
                                  turns: isExpanded ? 0.5 : 0,
                                  duration: const Duration(milliseconds: 300),
                                  child: const Icon(
                                    Icons.keyboard_arrow_down,
                                    color: AppColors.textLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (isExpanded)
                          SizeTransition(
                            sizeFactor: _metricsAnimation,
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: Column(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    height: 1,
                                    color: Colors.grey.shade200,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildChart(metric['id']!),
                                ],
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNoScansWidget(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.analytics_outlined,
            size: 48,
            color: AppColors.textLight,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No scans yet',
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const ScanScreen(),
                  transitionDuration: const Duration(milliseconds: 300),
                  reverseTransitionDuration: const Duration(milliseconds: 300),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 1),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeInOut,
                      )),
                      child: child,
                    );
                  },
                ),
              );
            },
            child: const Text('Start Your First Scan'),
          ),
        ],
      ),
    );
  }

  Widget _buildScanResultCard(BuildContext context, ScanResult scan) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScanDetailScreen(scanResult: scan),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: File(scan.frontImagePath).existsSync()
                    ? Image.file(
                        File(scan.frontImagePath),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.image_not_supported,
                            color: AppColors.textLight,
                          );
                        },
                      )
                    : const Icon(
                        Icons.face,
                        color: AppColors.primary,
                        size: 24,
                      ),
              ),
            ),
            
            const SizedBox(width: AppSpacing.md),
            
            // Scan info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${scan.getFormattedDate()} at ${scan.getFormattedTime()}',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            
            // Arrow
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textLight,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
} 