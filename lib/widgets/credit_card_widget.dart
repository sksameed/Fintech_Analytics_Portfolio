// lib/widgets/credit_card_widget.dart
// Flip-animated credit card with 3D perspective rotation.
// Tapping the card smoothly rotates it 180 degrees using Matrix4 perspective,
// revealing card limits, outstanding dues, and expiry details on the reverse.

import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../models.dart';
import '../theme.dart';

class CreditCardWidget extends StatefulWidget {
  final CreditCard card;
  const CreditCardWidget({super.key, required this.card});

  @override
  State<CreditCardWidget> createState() => _CreditCardWidgetState();
}

class _CreditCardWidgetState extends State<CreditCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_controller.isCompleted) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flipCard,
      child: Semantics(
        label: 'Credit card ending in ${widget.card.cardNumber}, tap to flip',
        button: true,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            final angle = _animation.value * math.pi;
            final isBack = _animation.value >= 0.5;

            return Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001) // 3D Perspective entry
                ..rotateY(angle),
              alignment: Alignment.center,
              child: isBack
                  ? Transform(
                      transform: Matrix4.rotationY(math.pi),
                      alignment: Alignment.center,
                      child: _CardBack(card: widget.card),
                    )
                  : _CardFront(card: widget.card),
            );
          },
        ),
      ),
    );
  }
}

class _CardFront extends StatelessWidget {
  final CreditCard card;
  const _CardFront({required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 210,
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.space8, vertical: AppTheme.space12),
      padding: const EdgeInsets.all(AppTheme.space20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radius16),
        gradient: const LinearGradient(
          colors: [Color(0xFF232733), Color(0xFF14161F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: AppTheme.cardShadows,
        border: Border.all(color: AppTheme.border, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.contactless, color: AppTheme.primary, size: 28),
              Text(card.network.toUpperCase(), style: AppTheme.headingSmall.copyWith(color: AppTheme.primary, letterSpacing: 1.5)),
            ],
          ),
          const Icon(Icons.memory, color: Color(0xFFFFD700), size: 36),
          Text(card.cardNumber, style: AppTheme.headingMedium.copyWith(letterSpacing: 4.0)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('CARDHOLDER', style: AppTheme.bodySmall),
                  Text(card.cardholderName, style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
              const Text('TAP TO FLIP ↻', style: TextStyle(color: AppTheme.primary, fontSize: 10, fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardBack extends StatelessWidget {
  final CreditCard card;
  const _CardBack({required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 210,
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.space8, vertical: AppTheme.space12),
      padding: const EdgeInsets.all(AppTheme.space20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radius16),
        gradient: const LinearGradient(
          colors: [Color(0xFF1C1F28), Color(0xFF0F1116)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: AppTheme.cardShadows,
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.4), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(height: 32, color: Colors.black54),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _InfoItem(label: 'TOTAL LIMIT', value: '₹${card.totalLimit.toStringAsFixed(0)}'),
              _InfoItem(label: 'OUTSTANDING', value: '₹${card.outstandingBalance.toStringAsFixed(2)}'),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _InfoItem(label: 'DUE DATE', value: card.dueDate),
              _InfoItem(label: 'BILL MONTH', value: card.billMonth),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  const _InfoItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.bodySmall),
        const SizedBox(height: AppTheme.space4),
        Text(value, style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
