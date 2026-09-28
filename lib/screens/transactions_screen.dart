// lib/screens/transactions_screen.dart
// Searchable and filterable transaction list.
// Demonstrates offline-first cache reading, live search, category filtering,
// pull-to-refresh (RefreshIndicator), and resilient empty/error states.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../models.dart';
import '../theme.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _query = '';
  String _selectedCat = 'All';
  static const _cats = ['All', 'Dining', 'Shopping', 'Travel', 'Bills', 'Groceries', 'Entertainment'];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions', style: AppTheme.headingMedium),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.primary),
            onPressed: () => context.read<AppState>().refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          _SearchBar(onChanged: (v) => setState(() => _query = v)),
          _CategoryChips(categories: _cats, selected: _selectedCat, onSelect: (c) => setState(() => _selectedCat = c)),
          const SizedBox(height: AppTheme.space8),
          Expanded(child: _buildList(state)),
        ],
      ),
    );
  }

  Widget _buildList(AppState state) {
    if (state.isLoading && state.transactions.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
    }
    if (state.errorMessage != null && state.transactions.isEmpty) {
      return _StatusView(icon: Icons.cloud_off, color: AppTheme.secondary, text: state.errorMessage!, retry: () => context.read<AppState>().refresh());
    }
    final filtered = state.transactions.where((t) {
      final matchesCat = _selectedCat == 'All' || t.category.toLowerCase() == _selectedCat.toLowerCase();
      final q = _query.toLowerCase();
      return matchesCat && (q.isEmpty || t.merchant.toLowerCase().contains(q) || t.category.toLowerCase().contains(q));
    }).toList();

    if (filtered.isEmpty) {
      return const _StatusView(icon: Icons.search_off, color: AppTheme.textMuted, text: 'No transactions found');
    }

    return RefreshIndicator(
      color: AppTheme.primary,
      backgroundColor: AppTheme.surface,
      onRefresh: () => context.read<AppState>().refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.space16, vertical: AppTheme.space8),
        itemCount: filtered.length,
        itemBuilder: (_, i) => _TransactionCard(transaction: filtered[i]),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.space16, vertical: AppTheme.space8),
      child: TextField(
        onChanged: onChanged,
        style: AppTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: 'Search merchant or category...',
          hintStyle: AppTheme.bodyMedium,
          prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
          filled: true,
          fillColor: AppTheme.surface,
          contentPadding: const EdgeInsets.all(AppTheme.space12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radius12), borderSide: const BorderSide(color: AppTheme.border)),
        ),
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelect;
  const _CategoryChips({required this.categories, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.space16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppTheme.space8),
        itemBuilder: (_, i) {
          final isSel = categories[i] == selected;
          return GestureDetector(
            onTap: () => onSelect(categories[i]),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.space16, vertical: AppTheme.space8),
              decoration: BoxDecoration(
                color: isSel ? AppTheme.primary : AppTheme.surface,
                borderRadius: BorderRadius.circular(AppTheme.radius24),
                border: Border.all(color: isSel ? AppTheme.primary : AppTheme.border),
              ),
              child: Text(categories[i], style: TextStyle(fontSize: 12, fontWeight: isSel ? FontWeight.w700 : FontWeight.w500, color: isSel ? Colors.black : AppTheme.textSecondary)),
            ),
          );
        },
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final Transaction transaction;
  const _TransactionCard({required this.transaction});

  static const _icons = {'dining': Icons.restaurant, 'shopping': Icons.shopping_bag_outlined, 'travel': Icons.flight_takeoff, 'bills': Icons.flash_on, 'groceries': Icons.local_grocery_store_outlined};
  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  @override
  Widget build(BuildContext context) {
    final d = transaction.date;
    final dateStr = '${d.day} ${_months[d.month - 1]}';
    final icon = _icons[transaction.category.toLowerCase()] ?? Icons.movie_outlined;

    return Semantics(
      label: '${transaction.merchant}, ₹${transaction.amount}',
      child: Container(
        margin: const EdgeInsets.only(bottom: AppTheme.space8),
        padding: const EdgeInsets.all(AppTheme.space12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radius12),
          boxShadow: AppTheme.softShadows,
          border: Border.all(color: AppTheme.border, width: 0.5),
        ),
        child: Row(
          children: [
            CircleAvatar(backgroundColor: AppTheme.surfaceElevated, child: Icon(icon, color: AppTheme.primary, size: 20)),
            const SizedBox(width: AppTheme.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(transaction.merchant, style: AppTheme.headingSmall),
                  const SizedBox(height: AppTheme.space4),
                  Text('$dateStr • ${transaction.category}', style: AppTheme.bodySmall),
                ],
              ),
            ),
            Text('₹${transaction.amount.toStringAsFixed(2)}', style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _StatusView extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  final VoidCallback? retry;
  const _StatusView({required this.icon, required this.color, required this.text, this.retry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: color),
          const SizedBox(height: AppTheme.space12),
          Text(text, style: AppTheme.bodyMedium),
          if (retry != null) ...[
            const SizedBox(height: AppTheme.space16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.black),
              onPressed: retry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }
}
