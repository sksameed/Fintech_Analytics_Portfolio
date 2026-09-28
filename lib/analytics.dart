// lib/analytics.dart
// Spend aggregation engine and isolate runner.
// Computes monthly spending totals and category breakdowns.
// Uses Isolate.run to execute heavy computations on a background isolate,
// ensuring zero UI frame drops across thousands of transactions.

import 'dart:isolate';
import 'models.dart';

class AnalyticsResult {
  final Map<int, double> monthlySpend;
  final Map<String, double> categorySpend;
  final double totalSpend;

  const AnalyticsResult({
    required this.monthlySpend,
    required this.categorySpend,
    required this.totalSpend,
  });
}

class BenchmarkResult {
  final int mainThreadMs;
  final int isolateMs;

  const BenchmarkResult({
    required this.mainThreadMs,
    required this.isolateMs,
  });
}

// Pure function: aggregates monthly and categorical spending
AnalyticsResult calculateAnalytics(List<Transaction> transactions) {
  final monthly = <int, double>{};
  final category = <String, double>{};
  double total = 0.0;

  for (final tx in transactions) {
    total += tx.amount;
    final m = tx.date.month;
    monthly[m] = (monthly[m] ?? 0.0) + tx.amount;

    final cat = tx.category;
    category[cat] = (category[cat] ?? 0.0) + tx.amount;
  }

  return AnalyticsResult(
    monthlySpend: monthly,
    categorySpend: category,
    totalSpend: total,
  );
}

// Runs aggregation on a dedicated background isolate using Dart's Isolate.run
Future<AnalyticsResult> runAnalyticsInIsolate(List<Transaction> transactions) async {
  return await Isolate.run(() => calculateAnalytics(transactions));
}

// Benchmarks main thread vs background isolate execution times using Stopwatch
Future<BenchmarkResult> runBenchmark(List<Transaction> transactions) async {
  // 1. Measure synchronous main thread execution
  final swMain = Stopwatch()..start();
  calculateAnalytics(transactions);
  swMain.stop();

  // 2. Measure asynchronous background isolate execution
  final swIsolate = Stopwatch()..start();
  await runAnalyticsInIsolate(transactions);
  swIsolate.stop();

  return BenchmarkResult(
    mainThreadMs: swMain.elapsedMilliseconds,
    isolateMs: swIsolate.elapsedMilliseconds,
  );
}
