// lib/screens/home_screen.dart
// Home screen: displays swipeable credit cards and live bill countdown.
// Employs RepaintBoundary for optimal 60fps carousel rendering,
// Timer.periodic for real-time bill countdown, and haptic feedback on payments.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/credit_card_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _cardIndex = 0;
  Timer? _countdownTimer;
  Duration _timeLeft = const Duration(days: 17, hours: 8, minutes: 42, seconds: 15);

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _timeLeft = _timeLeft.inSeconds > 0 ? _timeLeft - const Duration(seconds: 1) : Duration.zero);
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final cards = state.cards;

    return Scaffold(
      appBar: AppBar(
        title: const Text('CRED Lite', style: AppTheme.headingMedium),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.primary),
            onPressed: () => context.read<AppState>().refresh(),
          ),
        ],
      ),
      body: cards.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CardCarousel(
                    cards: cards,
                    currentIndex: _cardIndex,
                    onPageChanged: (idx) => setState(() => _cardIndex = idx),
                  ),
                  _BillSection(
                    card: cards[_cardIndex.clamp(0, cards.length - 1)],
                    timeLeft: _timeLeft,
                  ),
                ],
              ),
            ),
    );
  }
}

class _CardCarousel extends StatelessWidget {
  final List<CreditCard> cards;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;

  const _CardCarousel({
    required this.cards,
    required this.currentIndex,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RepaintBoundary(
          child: SizedBox(
            height: 240,
            child: PageView.builder(
              itemCount: cards.length,
              controller: PageController(viewportFraction: 0.9),
              onPageChanged: onPageChanged,
              itemBuilder: (_, i) => CreditCardWidget(card: cards[i]),
            ),
          ),
        ),
        const SizedBox(height: AppTheme.space8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            cards.length,
            (i) => Container(
              width: i == currentIndex ? 18 : 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: AppTheme.space4),
              decoration: BoxDecoration(
                color: i == currentIndex ? AppTheme.primary : AppTheme.textMuted,
                borderRadius: BorderRadius.circular(AppTheme.radius8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BillSection extends StatelessWidget {
  final CreditCard card;
  final Duration timeLeft;

  const _BillSection({required this.card, required this.timeLeft});

  void _onPay(BuildContext context) {
    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: AppTheme.surfaceElevated, content: Text('Payment of ₹${card.outstandingBalance.toStringAsFixed(2)} initiated via CRED Pay', style: AppTheme.bodyLarge)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final h = timeLeft.inHours % 24;
    final m = timeLeft.inMinutes % 60;
    final s = timeLeft.inSeconds % 60;
    final timeStr = '${timeLeft.inDays}d ${h.toString().padLeft(2, '0')}h ${m.toString().padLeft(2, '0')}m ${s.toString().padLeft(2, '0')}s';

    return Container(
      margin: const EdgeInsets.all(AppTheme.space16),
      padding: const EdgeInsets.all(AppTheme.space20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius16),
        boxShadow: AppTheme.softShadows,
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('TOTAL BILL DUE', style: AppTheme.bodySmall),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.space8, vertical: AppTheme.space4),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppTheme.radius8),
                ),
                child: Text('Due in ${card.dueDate}', style: const TextStyle(color: AppTheme.warning, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.space8),
          Text('₹${card.outstandingBalance.toStringAsFixed(2)}', style: AppTheme.amountLarge),
          const SizedBox(height: AppTheme.space12),
          Row(
            children: [
              const Icon(Icons.timer_outlined, color: AppTheme.primary, size: 16),
              const SizedBox(width: AppTheme.space8),
              Text('Live Countdown: $timeStr', style: AppTheme.bodyMedium.copyWith(color: AppTheme.primary)),
            ],
          ),
          const SizedBox(height: AppTheme.space20),
          Semantics(
            button: true,
            label: 'Pay bill of ₹${card.outstandingBalance} now',
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radius12)),
                ),
                onPressed: () => _onPay(context),
                child: const Text('Pay now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
