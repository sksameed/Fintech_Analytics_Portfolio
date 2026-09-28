// lib/main.dart
// Entry point for CredLite.
// Initializes Hive local storage, injects AppState via Provider,
// applies the dark neumorphic theme, and sets up 4-tab bottom navigation.

import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'api_service.dart';
import 'app_state.dart';
import 'local_store.dart';
import 'screens/analytics_screen.dart';
import 'screens/home_screen.dart';
import 'screens/rewards_screen.dart';
import 'screens/transactions_screen.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive CE for lightweight key-value caching
  await Hive.initFlutter();
  final localStore = await LocalStore.open();
  final apiService = ApiService();

  final appState = AppState(
    apiService: apiService,
    localStore: localStore,
  );

  // Trigger offline-first data load (cache immediately, then API)
  appState.load();

  runApp(
    ChangeNotifierProvider.value(
      value: appState,
      child: const CredLiteApp(),
    ),
  );
}

class CredLiteApp extends StatelessWidget {
  const CredLiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CredLite',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  // Preserves state across tab switches
  final List<Widget> _screens = const [
    HomeScreen(),
    TransactionsScreen(),
    AnalyticsScreen(),
    RewardsScreen(),
  ];

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          top: BorderSide(color: AppTheme.border, width: 0.8),
        ),
      ),
      child: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onTap,
        backgroundColor: Colors.transparent,
        indicatorColor: AppTheme.primary.withValues(alpha: 0.15),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.credit_card_outlined, color: AppTheme.textSecondary),
            selectedIcon: Icon(Icons.credit_card, color: AppTheme.primary),
            label: 'Cards',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined, color: AppTheme.textSecondary),
            selectedIcon: Icon(Icons.receipt_long, color: AppTheme.primary),
            label: 'Transactions',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined, color: AppTheme.textSecondary),
            selectedIcon: Icon(Icons.bar_chart, color: AppTheme.primary),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Icon(Icons.card_giftcard_outlined, color: AppTheme.textSecondary),
            selectedIcon: Icon(Icons.card_giftcard, color: AppTheme.primary),
            label: 'Rewards',
          ),
        ],
      ),
    );
  }
}
