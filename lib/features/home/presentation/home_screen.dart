import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/presentation/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'How to Play',
            onPressed: () => context.push('/how-to-play'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              profile.when(
                data: (user) => Text(
                  'Welcome, ${user?.username ?? 'Player'}!',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 8),
              Text(
                'Challenge a friend to a dot duel',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              _MenuButton(
                icon: Icons.add_circle_outline,
                label: 'Create Room',
                color: AppColors.player1Blue,
                onTap: () => context.push('/create-room'),
              ),
              const SizedBox(height: 16),
              _MenuButton(
                icon: Icons.login,
                label: 'Join Room',
                color: AppColors.player2Red,
                onTap: () => context.push('/join-room'),
              ),
              const SizedBox(height: 16),
              _MenuButton(
                icon: Icons.smart_toy_outlined,
                label: 'Play Alone',
                color: AppColors.success,
                onTap: () => context.push('/play-alone'),
              ),
              const SizedBox(height: 16),
              _MenuButton(
                icon: Icons.help_outline,
                label: 'How to Play',
                color: AppColors.primaryLight,
                onTap: () => context.push('/how-to-play'),
              ),
              const SizedBox(height: 16),
              _MenuButton(
                icon: Icons.leaderboard,
                label: 'Leaderboard',
                color: AppColors.textSecondary,
                onTap: () => context.push('/leaderboard'),
              ),
              const SizedBox(height: 16),
              _MenuButton(
                icon: Icons.person_outline,
                label: 'Profile',
                color: AppColors.player2Red,
                onTap: () => context.push('/profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
