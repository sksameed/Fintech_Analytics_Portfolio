// test/app_test.dart
// Three focused tests validating:
// 1. Pure spend aggregation function correctness.
// 2. Transaction.fromJson parsing and type casting.
// 3. TransactionsScreen widget flow: loading spinner -> loaded list.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:cred_lite/analytics.dart';
import 'package:cred_lite/api_service.dart';
import 'package:cred_lite/app_state.dart';
import 'package:cred_lite/local_store.dart';
import 'package:cred_lite/models.dart';
import 'package:cred_lite/screens/transactions_screen.dart';

// Test doubles implemented manually without mocking frameworks or code generation
class FakeLocalStore implements LocalStore {
  @override
  List<CreditCard> getCachedCards() => [];
  @override
  List<Transaction> getCachedTransactions() => [];
  @override
  List<Reward> getCachedRewards() => [];
  @override
  Set<String> getScratchedRewardIds() => {};
  @override
  Future<void> saveCards(List<CreditCard> cards) async {}
  @override
  Future<void> saveTransactions(List<Transaction> transactions) async {}
  @override
  Future<void> saveRewards(List<Reward> rewards) async {}
  @override
  Future<void> markRewardScratched(String rewardId) async {}
}

class FakeApiService extends ApiService {
  final Completer<List<Transaction>> completer = Completer<List<Transaction>>();

  @override
  Future<List<CreditCard>> fetchCards() async => [];
  @override
  Future<List<Reward>> fetchRewards() async => [];
  @override
  Future<List<Transaction>> fetchTransactions({String? category, String? query}) {
    return completer.future;
  }
}

void main() {
  group('CredLite Tests', () {
    // Test 1: Verify calculation of monthly and categorical spend totals
    test('1. calculateAnalytics returns correct totals for sample transactions', () {
      final sample = [
        Transaction(id: '1', merchant: 'Swiggy', category: 'Dining', amount: 150.0, date: DateTime(2026, 1, 10), cardId: 'c1'),
        Transaction(id: '2', merchant: 'Zomato', category: 'Dining', amount: 250.0, date: DateTime(2026, 1, 15), cardId: 'c1'),
        Transaction(id: '3', merchant: 'Uber', category: 'Travel', amount: 400.0, date: DateTime(2026, 2, 5), cardId: 'c1'),
      ];

      final result = calculateAnalytics(sample);

      expect(result.totalSpend, 800.0);
      expect(result.monthlySpend[1], 400.0);
      expect(result.monthlySpend[2], 400.0);
      expect(result.categorySpend['Dining'], 400.0);
      expect(result.categorySpend['Travel'], 400.0);
    });

    // Test 2: Verify hand-crafted fromJson deserialization
    test('2. Transaction.fromJson correctly parses JSON fields', () {
      final json = {
        'id': 'tx_101',
        'merchant': 'Apple Store',
        'category': 'Shopping',
        'amount': 8900.50,
        'date': '2026-09-28T12:00:00.000Z',
        'cardId': 'card_2',
      };

      final tx = Transaction.fromJson(json);

      expect(tx.id, 'tx_101');
      expect(tx.merchant, 'Apple Store');
      expect(tx.category, 'Shopping');
      expect(tx.amount, 8900.50);
      expect(tx.cardId, 'card_2');
      expect(tx.date, DateTime.parse('2026-09-28T12:00:00.000Z'));
    });

    // Test 3: Widget test verifying loading indicator followed by transaction list
    testWidgets('3. TransactionsScreen displays loading spinner, then transaction list', (tester) async {
      final fakeApi = FakeApiService();
      final fakeStore = FakeLocalStore();
      final appState = AppState(apiService: fakeApi, localStore: fakeStore);

      // Trigger initial refresh where network call is awaiting completer
      appState.refresh();

      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: const MaterialApp(home: TransactionsScreen()),
        ),
      );

      // Expect spinner during active loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Supply response data
      fakeApi.completer.complete([
        Transaction(id: 'tx_1', merchant: 'Blue Tokai', category: 'Dining', amount: 320.0, date: DateTime(2026, 9, 28), cardId: 'c1'),
      ]);

      await tester.pumpAndSettle();

      // Expect loading spinner dismissed and transaction card rendered
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Blue Tokai'), findsOneWidget);
    });
  });
}
