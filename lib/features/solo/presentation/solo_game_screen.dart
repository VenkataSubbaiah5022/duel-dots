import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/game_board.dart';
import 'solo_game_provider.dart';

class SoloGameScreen extends ConsumerWidget {
  const SoloGameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(soloGameProvider);
    final notifier = ref.read(soloGameProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Play vs Bot'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => context.push('/how-to-play'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _SoloScoreHeader(game: game),
              const SizedBox(height: 24),
              Expanded(
                child: Center(
                  child: GameBoard(
                    board: game.board,
                    isMyTurn: game.isPlayerTurn &&
                        !game.isBotThinking &&
                        game.status == SoloGameStatus.playing,
                    onCellTap: notifier.playerMove,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (game.status == SoloGameStatus.finished)
                _ResultPanel(
                  game: game,
                  onPlayAgain: notifier.reset,
                  onHome: () => context.go('/home'),
                )
              else
                TextButton.icon(
                  onPressed: () => context.go('/home'),
                  icon: const Icon(Icons.exit_to_app, color: AppColors.error),
                  label: const Text(
                    'Quit Game',
                    style: TextStyle(color: AppColors.error),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SoloScoreHeader extends StatelessWidget {
  const _SoloScoreHeader({required this.game});

  final SoloGameState game;

  @override
  Widget build(BuildContext context) {
    String turnText;
    if (game.status == SoloGameStatus.finished) {
      turnText = 'Game Over';
    } else if (game.isBotThinking) {
      turnText = 'Bot is thinking...';
    } else if (game.isPlayerTurn) {
      turnText = 'Your Turn';
    } else {
      turnText = 'Bot\'s Turn';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ScoreChip(
                  label: 'You (Blue)',
                  score: game.score1,
                  color: AppColors.player1Blue,
                ),
                _ScoreChip(
                  label: 'Bot (Red)',
                  score: game.score2,
                  color: AppColors.player2Red,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: game.isPlayerTurn && !game.isBotThinking
                    ? AppColors.success.withValues(alpha: 0.15)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (game.isBotThinking) ...[
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    turnText,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: game.isPlayerTurn && !game.isBotThinking
                              ? AppColors.success
                              : AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              game.isPlayerTurn && game.status == SoloGameStatus.playing
                  ? 'Tap empty cell — flip adjacent enemy dots!'
                  : 'Capture dots to beat the bot',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreChip extends StatelessWidget {
  const _ScoreChip({
    required this.label,
    required this.score,
    required this.color,
  });

  final String label;
  final int score;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '$score',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
              ),
        ),
      ],
    );
  }
}

class _ResultPanel extends StatelessWidget {
  const _ResultPanel({
    required this.game,
    required this.onPlayAgain,
    required this.onHome,
  });

  final SoloGameState game;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    String title;
    Color color;
    IconData icon;

    if (game.winner == 'draw') {
      title = 'Draw!';
      color = AppColors.textSecondary;
      icon = Icons.handshake;
    } else if (game.winner == 'player1') {
      title = 'You Win!';
      color = AppColors.success;
      icon = Icons.emoji_events;
    } else {
      title = 'Bot Wins';
      color = AppColors.error;
      icon = Icons.smart_toy;
    }

    return Column(
      children: [
        Icon(icon, size: 48, color: color),
        const SizedBox(height: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          'You ${game.score1} – Bot ${game.score2}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        AppButton(label: 'Play Again', onPressed: onPlayAgain),
        const SizedBox(height: 8),
        AppButton(label: 'Back Home', isOutlined: true, onPressed: onHome),
      ],
    );
  }
}
