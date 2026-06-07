import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('How to Play')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _Section(
            icon: Icons.people,
            title: '1. Choose a Mode',
            body:
                'Play with a friend: Create Room or Join Room.\n\n'
                'Play alone: tap Play Alone to face the bot — no room code needed!',
          ),
          _Section(
            icon: Icons.grid_on,
            title: '2. The Board',
            body:
                'You play on a 5×5 grid (25 empty cells). '
                'Player 1 is Blue. Player 2 is Red.',
          ),
          _Section(
            icon: Icons.touch_app,
            title: '3. Take Turns',
            body:
                'On your turn, tap any empty cell. It becomes your color dot. '
                'Turns alternate: Blue → Red → Blue → Red...',
          ),
          _Section(
            icon: Icons.swap_horiz,
            title: '4. Capture Dots!',
            body:
                'This is the key rule: when you place a dot, any opponent dots '
                'directly next to it (up, down, left, right) flip to YOUR color. '
                'Use this to steal dots and swing the score!',
          ),
          _Section(
            icon: Icons.emoji_events,
            title: '5. How to Win',
            body:
                'When all 25 cells are filled, dots are counted. '
                'Whoever has more dots wins!\n\n'
                'Because of captures, scores can change quickly — '
                'plan your moves to flip opponent dots, not just claim empty cells.',
          ),
          _Section(
            icon: Icons.lightbulb_outline,
            title: 'Tips',
            body:
                '• Place dots next to enemy dots to capture them\n'
                '• Protect your clusters — don\'t leave dots exposed\n'
                '• Corners are safer (fewer sides to attack)\n'
                '• Think 2 moves ahead before tapping',
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _MiniDot(color: AppColors.player1Blue),
                  const SizedBox(width: 8),
                  const Text('Blue = Player 1 (creates room)'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _MiniDot(color: AppColors.player2Red),
                  const SizedBox(width: 8),
                  const Text('Red = Player 2 (joins room)'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 6),
                Text(body, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniDot extends StatelessWidget {
  const _MiniDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
