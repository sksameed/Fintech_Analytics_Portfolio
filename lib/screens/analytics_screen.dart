// lib/screens/analytics_screen.dart
// Analytics dashboard: monthly spend bar chart, category spend pie chart,
// and background isolate vs main thread execution time benchmark.

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../analytics.dart';
import '../app_state.dart';
import '../theme.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  AnalyticsResult? _result;
  BenchmarkResult? _benchmark;
  bool _isBenchmarking = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _computeAnalytics();
  }

  Future<void> _computeAnalytics() async {
    final transactions = context.read<AppState>().transactions;
    if (transactions.isEmpty) return;
    final res = await runAnalyticsInIsolate(transactions);
    if (mounted) setState(() => _result = res);
  }

  Future<void> _runBenchmark() async {
    final transactions = context.read<AppState>().transactions;
    if (transactions.isEmpty) return;
    setState(() => _isBenchmarking = true);
    final bench = await runBenchmark(transactions);
    if (mounted) setState(() { _benchmark = bench; _isBenchmarking = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (_result == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppTheme.primary)));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Spend Analytics', style: AppTheme.headingMedium)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.space16),
        child: Column(
          children: [
            _BarChartCard(monthlySpend: _result!.monthlySpend),
            const SizedBox(height: AppTheme.space16),
            _PieChartCard(categorySpend: _result!.categorySpend, total: _result!.totalSpend),
            const SizedBox(height: AppTheme.space16),
            _BenchmarkCard(benchmark: _benchmark, isLoading: _isBenchmarking, onRun: _runBenchmark),
          ],
        ),
      ),
    );
  }
}

class _BarChartCard extends StatelessWidget {
  final Map<int, double> monthlySpend;
  const _BarChartCard({required this.monthlySpend});

  @override
  Widget build(BuildContext context) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final groups = List.generate(9, (i) {
      final m = i + 1;
      final val = (monthlySpend[m] ?? 0.0) / 1000;
      return BarChartGroupData(
        x: m,
        barRods: [BarChartRodData(toY: val, color: AppTheme.primary, width: 14, borderRadius: BorderRadius.circular(4))],
      );
    });

    return Container(
      height: 240,
      padding: const EdgeInsets.all(AppTheme.space16),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(AppTheme.radius16), boxShadow: AppTheme.softShadows, border: Border.all(color: AppTheme.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('MONTHLY SPEND (₹ in thousands)', style: AppTheme.bodySmall),
          const SizedBox(height: AppTheme.space16),
          Expanded(
            child: BarChart(
              BarChartData(
                barGroups: groups,
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, _) => Text(months[(val.toInt() - 1).clamp(0, 11)], style: AppTheme.bodySmall),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PieChartCard extends StatelessWidget {
  final Map<String, double> categorySpend;
  final double total;
  const _PieChartCard({required this.categorySpend, required this.total});

  static const _colors = [Color(0xFF00E5FF), Color(0xFFFF3366), Color(0xFF00E676), Color(0xFFFFD600), Color(0xFFAB47BC), Color(0xFFFF7043)];

  @override
  Widget build(BuildContext context) {
    int i = 0;
    final sections = categorySpend.entries.map((entry) {
      final color = _colors[i % _colors.length];
      i++;
      final pct = total > 0 ? (entry.value / total * 100).toStringAsFixed(0) : '0';
      return PieChartSectionData(
        value: entry.value,
        title: '$pct%',
        color: color,
        radius: 40,
        titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black),
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.all(AppTheme.space16),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(AppTheme.radius16), boxShadow: AppTheme.softShadows, border: Border.all(color: AppTheme.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SPEND BY CATEGORY', style: AppTheme.bodySmall),
          const SizedBox(height: AppTheme.space12),
          SizedBox(height: 160, child: PieChart(PieChartData(sections: sections, centerSpaceRadius: 36, sectionsSpace: 2))),
        ],
      ),
    );
  }
}

class _BenchmarkCard extends StatelessWidget {
  final BenchmarkResult? benchmark;
  final bool isLoading;
  final VoidCallback onRun;
  const _BenchmarkCard({required this.benchmark, required this.isLoading, required this.onRun});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.space16),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(AppTheme.radius16), boxShadow: AppTheme.softShadows, border: Border.all(color: AppTheme.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('PERFORMANCE BENCHMARK (5,000 TXNS)', style: AppTheme.bodySmall),
          const SizedBox(height: AppTheme.space12),
          if (benchmark != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _TimeBox(label: 'Main Thread', ms: benchmark!.mainThreadMs, color: AppTheme.warning),
                _TimeBox(label: 'Isolate.run', ms: benchmark!.isolateMs, color: AppTheme.primary),
              ],
            ),
            const SizedBox(height: AppTheme.space8),
            const Text('Real timings measured via Stopwatch. Isolates prevent UI thread jank even with heavy datasets.', style: AppTheme.bodySmall, textAlign: TextAlign.center),
            const SizedBox(height: AppTheme.space12),
          ],
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.surfaceElevated, foregroundColor: AppTheme.primary),
              onPressed: isLoading ? null : onRun,
              icon: isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.speed),
              label: Text(isLoading ? 'Running...' : 'Run Benchmark'),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeBox extends StatelessWidget {
  final String label;
  final int ms;
  final Color color;
  const _TimeBox({required this.label, required this.ms, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: AppTheme.bodySmall),
        const SizedBox(height: AppTheme.space4),
        Text('$ms ms', style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
