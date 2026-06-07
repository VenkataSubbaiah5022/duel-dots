import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../auth/presentation/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: profile.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Profile not found'));
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      user.username.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 36,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.username,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 32),
                  _StatCard(
                    stats: [
                      _StatItem(
                        label: 'Games Played',
                        value: '${user.totalGames}',
                        icon: Icons.sports_esports,
                        color: AppColors.primary,
                      ),
                      _StatItem(
                        label: 'Wins',
                        value: '${user.wins}',
                        icon: Icons.emoji_events,
                        color: AppColors.success,
                      ),
                      _StatItem(
                        label: 'Losses',
                        value: '${user.losses}',
                        icon: Icons.trending_down,
                        color: AppColors.error,
                      ),
                      _StatItem(
                        label: 'Win Rate',
                        value: '${(user.winRate * 100).toStringAsFixed(1)}%',
                        icon: Icons.percent,
                        color: AppColors.player1Blue,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const LoadingIndicator(message: 'Loading profile...'),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.stats});

  final List<_StatItem> stats;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: stats
              .map(
                (stat) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: stat.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(stat.icon, color: stat.color),
                    ),
                    title: Text(stat.label),
                    trailing: Text(
                      stat.value,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _StatItem {
  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
}
