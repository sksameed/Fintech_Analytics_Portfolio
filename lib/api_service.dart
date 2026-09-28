// lib/api_service.dart
// Centralized REST client using Dio.
// Encapsulates network operations, query parameter encoding, and error handling
// into clean asynchronous methods for credit cards, transactions, and rewards.

import 'package:dio/dio.dart';
import 'models.dart';

class ApiService {
  // 10.0.2.2 maps to host localhost in the Android emulator.
  // Can be changed to http://localhost:3000 for Desktop, Web, or iOS simulator.
  static const String defaultBaseUrl = 'http://localhost:3000';

  final Dio _dio;

  ApiService({String baseUrl = defaultBaseUrl, Dio? customDio})
      : _dio = customDio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl,
                connectTimeout: const Duration(seconds: 5),
                receiveTimeout: const Duration(seconds: 5),
                headers: {'Content-Type': 'application/json'},
              ),
            );

  // Fetches list of user credit cards
  Future<List<CreditCard>> fetchCards() async {
    try {
      final response = await _dio.get('/cards');
      final list = response.data as List<dynamic>;
      return list
          .map((item) => CreditCard.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception('Failed to load cards: ${e.message}');
    }
  }

  // Fetches transactions with optional category and search filters
  Future<List<Transaction>> fetchTransactions({
    String? category,
    String? query,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (category != null && category.isNotEmpty && category != 'All') {
        queryParams['category'] = category;
      }
      if (query != null && query.trim().isNotEmpty) {
        queryParams['q'] = query.trim();
      }

      final response = await _dio.get(
        '/transactions',
        queryParameters: queryParams,
      );
      final list = response.data as List<dynamic>;
      return list
          .map((item) => Transaction.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception('Failed to load transactions: ${e.message}');
    }
  }

  // Fetches rewards catalogue
  Future<List<Reward>> fetchRewards() async {
    try {
      final response = await _dio.get('/rewards');
      final list = response.data as List<dynamic>;
      return list
          .map((item) => Reward.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception('Failed to load rewards: ${e.message}');
    }
  }

  // Notifies backend that a scratch card has been revealed
  Future<Reward> scratchReward(String id) async {
    try {
      final response = await _dio.post('/rewards/$id/scratch');
      return Reward.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Failed to scratch reward: ${e.message}');
    }
  }
}
