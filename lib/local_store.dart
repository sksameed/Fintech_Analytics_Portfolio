// lib/local_store.dart
// Local persistence helper using Hive Community Edition (hive_ce).
// Stores data strictly as raw JSON strings to eliminate the need for
// type adapters, code generation, and complex database migrations.

import 'dart:convert';
import 'package:hive_ce/hive.dart';
import 'models.dart';

class LocalStore {
  static const String boxName = 'cred_lite_cache';
  static const String keyCards = 'cached_cards';
  static const String keyTransactions = 'cached_transactions';
  static const String keyRewards = 'cached_rewards';
  static const String keyScratchedIds = 'scratched_reward_ids';

  final Box _box;

  LocalStore(this._box);

  // Factory initializer to open the Hive box asynchronously
  static Future<LocalStore> open() async {
    final box = await Hive.openBox(boxName);
    return LocalStore(box);
  }

  // --- Credit Cards Cache ---

  Future<void> saveCards(List<CreditCard> cards) async {
    final jsonList = cards.map((c) => c.toJson()).toList();
    await _box.put(keyCards, jsonEncode(jsonList));
  }

  List<CreditCard> getCachedCards() {
    final raw = _box.get(keyCards) as String?;
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => CreditCard.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // --- Transactions Cache ---

  Future<void> saveTransactions(List<Transaction> transactions) async {
    final jsonList = transactions.map((t) => t.toJson()).toList();
    await _box.put(keyTransactions, jsonEncode(jsonList));
  }

  List<Transaction> getCachedTransactions() {
    final raw = _box.get(keyTransactions) as String?;
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => Transaction.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // --- Rewards Cache ---

  Future<void> saveRewards(List<Reward> rewards) async {
    final jsonList = rewards.map((r) => r.toJson()).toList();
    await _box.put(keyRewards, jsonEncode(jsonList));
  }

  List<Reward> getCachedRewards() {
    final raw = _box.get(keyRewards) as String?;
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => Reward.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // --- Scratched Reward IDs Persistence ---

  Future<void> markRewardScratched(String rewardId) async {
    final current = getScratchedRewardIds();
    current.add(rewardId);
    await _box.put(keyScratchedIds, jsonEncode(current.toList()));
  }

  Set<String> getScratchedRewardIds() {
    final raw = _box.get(keyScratchedIds) as String?;
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.map((e) => e.toString()).toSet();
    } catch (_) {
      return {};
    }
  }
}
