import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/models/scan_result.dart';
import '../../providers/scan_history_provider.dart';

class MetricProgressScreen extends ConsumerWidget {
  final String metricId;
  final String metricName;

  const MetricProgressScreen({
    super.key,
    required this.metricId,
    required this.metricName,
  });

  (List<FlSpot>, List<DateTime>, double, double, double, double) _prepareChartData(List<ScanResult> allScans) {
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
      } else if (minX == maxX) { // All points on same X, make a small range
        minX -= 0.5;
        maxX += 0.5;
      }
       if (minY == maxY) { // All points on same Y, make a small range
        minY -= 0.5;
        maxY += 0.5;
      }

    }
    return (spots, dates, minX, maxX, minY, maxY);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scanHistoryAsync = ref.watch(scanHistoryNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(metricName),
        backgroundColor: AppColors.background,
        elevation: 1,
      ),
      body: Padding(
        padding: AppSpacing.screenPadding.copyWith(top: AppSpacing.lg, bottom: AppSpacing.lg),
        child: scanHistoryAsync.when(
          data: (allScans) {
            final (spots, dates, minX, maxX, minY, maxY) = _prepareChartData(allScans);

            if (spots.length < 2 && !(spots.length == 1 && minX != maxX) ) { // Show chart for 1 point if range is made
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.show_chart_rounded, color: AppColors.textLight, size: 48),
                    const SizedBox(height: AppSpacing.md),
                    Text('Not Enough Data', style: AppTextStyles.heading2),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'You need at least two scans with data for "$metricName" to see a progress graph.',
                      style: AppTextStyles.bodySecondary,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }
            if (spots.isEmpty) {
                 return Center(
                    child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        const Icon(Icons.sentiment_dissatisfied, color: AppColors.textLight, size: 48),
                        const SizedBox(height: AppSpacing.md),
                        Text('No Data Available', style: AppTextStyles.heading2),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                        'No scans found with data for "$metricName".',
                        style: AppTextStyles.bodySecondary,
                        textAlign: TextAlign.center,
                        ),
                    ],
                    ),
                );
            }

            return Center( // Center the chart vertically
              child: SizedBox( // Constrain the chart's height
                height: 300, // Set a fixed height for the chart
                child: LineChart(
                  LineChartData(
                    minX: minX,
                    maxX: maxX,
                    minY: minY,
                    maxY: maxY,
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                          return touchedBarSpots.map((barSpot) {
                            final flSpot = barSpot;
                            if (flSpot.x.toInt() < 0 || flSpot.x.toInt() >= dates.length) return null;
                            final date = dates[flSpot.x.toInt()];
                            return LineTooltipItem(
                              '${DateFormat('MMM d, yyyy').format(date)}\n',
                              AppTextStyles.caption.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                              children: [
                                TextSpan(
                                  text: flSpot.y.toStringAsFixed(2),
                                  style: AppTextStyles.body.copyWith(color: Colors.white),
                                ),
                              ],
                            );
                          }).toList();
                        },
                      ),
                    ),
                    gridData: const FlGridData(show: false), // Remove grid
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
                          interval: (maxY - minY) > 0 ? ((maxY - minY) / 4).clamp(0.1, (maxY-minY)) : 1.0, // Dynamic interval
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
                        dotData: FlDotData(show: spots.length == 1 ? true : false), // Show dot if only one point
                        belowBarData: BarAreaData(
                          show: false, // Remove shading under the line
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: AppSpacing.md),
                Text('Error Loading Chart Data', style: AppTextStyles.heading2.copyWith(color: Colors.red)),
                const SizedBox(height: AppSpacing.sm),
                Text(error.toString(), style: AppTextStyles.bodySecondary, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 