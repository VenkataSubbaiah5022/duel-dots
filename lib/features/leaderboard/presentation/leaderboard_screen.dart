import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../auth/domain/user_model.dart';
import '../../auth/presentation/auth_provider.dart';

final leaderboardProvider = FutureProvider<List<UserModel>>((ref) {
  return ref.watch(userRepositoryProvider).getLeaderboard();
});

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboard = ref.watch(leaderboardProvider);
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      body: leaderboard.when(
        data: (users) {
          if (users.isEmpty) {
            return const Center(
              child: Text('No players yet. Be the first to win!'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final user = users[index];
              final rank = index + 1;
              final isCurrentUser = user.id == currentUser?.uid;

              return Card(
                color: isCurrentUser
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : null,
                child: ListTile(
                  leading: _RankBadge(rank: rank),
                  title: Text(
                    user.username,
                    style: TextStyle(
                      fontWeight:
                          isCurrentUser ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    '${user.losses} losses · ${user.totalGames} games',
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${user.wins}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        'wins',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const LoadingIndicator(message: 'Loading rankings...'),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.rank});

  final int rank;

  @override
  Widget build(BuildContext context) {
    Color? badgeColor;
    if (rank == 1) badgeColor = const Color(0xFFFFD700);
    if (rank == 2) badgeColor = const Color(0xFFC0C0C0);
    if (rank == 3) badgeColor = const Color(0xFFCD7F32);

    return CircleAvatar(
      backgroundColor: badgeColor ?? AppColors.primary.withValues(alpha: 0.1),
      child: Text(
        '$rank',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: badgeColor != null ? Colors.white : AppColors.primary,
        ),
      ),
    );
  }
}
