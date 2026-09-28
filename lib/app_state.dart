// lib/app_state.dart
// Central application state using ChangeNotifier.
// Implements the offline-first "Cache-First then Refresh" strategy:
// 1. Immediately populates UI from local Hive cache.
// 2. Triggers asynchronous network fetch via ApiService.
// 3. Updates UI and persistent cache upon success.
// 4. Retains cached data and surfaces an error message upon failure.

import 'package:flutter/foundation.dart';
import 'api_service.dart';
import 'local_store.dart';
import 'models.dart';

class AppState extends ChangeNotifier {
  final ApiService _apiService;
  final LocalStore _localStore;

  List<CreditCard> _cards = [];
  List<Transaction> _transactions = [];
  List<Reward> _rewards = [];

  bool _isLoading = false;
  String? _errorMessage;

  // Getters for UI consumption
  List<CreditCard> get cards => _cards;
  List<Transaction> get transactions => _transactions;
  List<Reward> get rewards => _rewards;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AppState({
    required ApiService apiService,
    required LocalStore localStore,
  })  : _apiService = apiService,
        _localStore = localStore;

  // Primary entrypoint: loads cached data first, then triggers network refresh
  Future<void> load() async {
    _readFromCache();
    await refresh();
  }

  // Reads available data from local Hive storage to render UI with 0 latency
  void _readFromCache() {
    _cards = _localStore.getCachedCards();
    _transactions = _localStore.getCachedTransactions();

    final cachedRewards = _localStore.getCachedRewards();
    final scratchedIds = _localStore.getScratchedRewardIds();

    _rewards = cachedRewards.map((reward) {
      if (scratchedIds.contains(reward.id)) {
        return reward.copyWith(isScratched: true);
      }
      return reward;
    }).toList();

    notifyListeners();
  }

  // Refreshes data from the mock REST API and saves to cache
  Future<void> refresh() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetchedCards = await _apiService.fetchCards();
      final fetchedTransactions = await _apiService.fetchTransactions();
      final fetchedRewards = await _apiService.fetchRewards();

      final scratchedIds = _localStore.getScratchedRewardIds();
      final mergedRewards = fetchedRewards.map((r) {
        if (scratchedIds.contains(r.id)) {
          return r.copyWith(isScratched: true);
        }
        return r;
      }).toList();

      _cards = fetchedCards;
      _transactions = fetchedTransactions;
      _rewards = mergedRewards;
      _isLoading = false;
      _errorMessage = null;

      // Update persistent storage
      await _localStore.saveCards(_cards);
      await _localStore.saveTransactions(_transactions);
      await _localStore.saveRewards(_rewards);

      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Could not refresh data. Showing offline data.';
      notifyListeners();
    }
  }

  // Handles scratch card completion and persists state locally + remotely
  Future<void> scratchReward(String rewardId) async {
    await _localStore.markRewardScratched(rewardId);

    _rewards = _rewards.map((r) {
      if (r.id == rewardId) {
        return r.copyWith(isScratched: true);
      }
      return r;
    }).toList();
    notifyListeners();

    try {
      await _apiService.scratchReward(rewardId);
    } catch (_) {
      // Offline fallback: keep local state marked as scratched even if network fails
    }
  }
}
