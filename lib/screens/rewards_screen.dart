// lib/screens/rewards_screen.dart
// Rewards screen displaying a 2-column grid of interactive scratch cards.
// Scratched state is persistently saved in Hive so revealed vouchers remain
// unlocked across application restarts.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/scratch_card.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final rewards = state.rewards;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rewards & Perks', style: AppTheme.headingMedium),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.primary),
            onPressed: () => context.read<AppState>().refresh(),
          ),
        ],
      ),
      body: rewards.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : Column(
              children: [
                _HeaderBanner(rewards: rewards),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(AppTheme.space16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: AppTheme.space12,
                      mainAxisSpacing: AppTheme.space12,
                      childAspectRatio: 0.86,
                    ),
                    itemCount: rewards.length,
                    itemBuilder: (context, index) {
                      final reward = rewards[index];
                      return ScratchCardWidget(
                        key: ValueKey(reward.id),
                        reward: reward,
                        onRevealed: () => context.read<AppState>().scratchReward(reward.id),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class _HeaderBanner extends StatelessWidget {
  final List<Reward> rewards;
  const _HeaderBanner({required this.rewards});

  @override
  Widget build(BuildContext context) {
    final revealedCount = rewards.where((r) => r.isScratched).length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.space16, vertical: AppTheme.space8),
      padding: const EdgeInsets.all(AppTheme.space16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius12),
        boxShadow: AppTheme.softShadows,
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.surfaceElevated,
            child: const Icon(Icons.card_giftcard, color: AppTheme.primary),
          ),
          const SizedBox(width: AppTheme.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('CRED Vouchers & Perks', style: AppTheme.headingSmall),
                const SizedBox(height: AppTheme.space4),
                Text('Scratch to unlock discounts. Saved offline.', style: AppTheme.bodySmall),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.space12, vertical: AppTheme.space4),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppTheme.radius16),
            ),
            child: Text('$revealedCount/${rewards.length} UNLOCKED', style: const TextStyle(color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
