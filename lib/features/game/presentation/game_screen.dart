import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/game_board.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../room/domain/room_model.dart';
import '../../room/presentation/room_provider.dart';
import '../domain/game_logic.dart';
import 'game_provider.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key, required this.roomCode});

  final String roomCode;

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  bool _isMakingMove = false;

  @override
  Widget build(BuildContext context) {
    final roomAsync = ref.watch(roomStreamProvider(widget.roomCode));
    final gameService = ref.watch(gameServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Room ${widget.roomCode}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'How to Play',
            onPressed: () => context.push('/how-to-play'),
          ),
        ],
      ),
      body: roomAsync.when(
        data: (room) {
          if (room == null) {
            return const Center(child: Text('Room not found'));
          }

          if (room.status == RoomStatus.finished) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) context.go('/result/${widget.roomCode}');
            });
          }

          final playerSlot = gameService.getPlayerSlot(room);
          final isMyTurn = gameService.isMyTurn(room);
          final board = room.board ?? GameLogic.createEmptyBoard();

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _ScoreHeader(
                    room: room,
                    playerSlot: playerSlot,
                    isMyTurn: isMyTurn,
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Center(
                      child: GameBoard(
                        board: board,
                        isMyTurn: isMyTurn && !_isMakingMove,
                        onCellTap: (row, col) => _handleMove(room, row, col),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () => _leaveMatch(),
                    icon: const Icon(Icons.exit_to_app, color: AppColors.error),
                    label: const Text(
                      'Leave Match',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const LoadingIndicator(message: 'Loading game...'),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Future<void> _handleMove(RoomModel room, int row, int col) async {
    if (_isMakingMove) return;

    setState(() => _isMakingMove = true);
    try {
      await ref.read(gameServiceProvider).makeMove(room, row, col);
    } finally {
      if (mounted) setState(() => _isMakingMove = false);
    }
  }

  Future<void> _leaveMatch() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Match?'),
        content: const Text('Are you sure you want to leave this match?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(gameServiceProvider).leaveRoom(widget.roomCode);
      if (mounted) context.go('/home');
    }
  }
}

class _ScoreHeader extends ConsumerWidget {
  const _ScoreHeader({
    required this.room,
    required this.playerSlot,
    required this.isMyTurn,
  });

  final RoomModel room;
  final int? playerSlot;
  final bool isMyTurn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ScoreChip(
                  label: 'Blue',
                  score: room.score1,
                  color: AppColors.player1Blue,
                  isYou: playerSlot == CellState.player1.value,
                ),
                _ScoreChip(
                  label: 'Red',
                  score: room.score2,
                  color: AppColors.player2Red,
                  isYou: playerSlot == CellState.player2.value,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isMyTurn
                    ? AppColors.success.withValues(alpha: 0.15)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isMyTurn
                    ? 'Your Turn'
                    : '${room.currentTurn == CellState.player1.value ? 'Blue' : 'Red'}\'s Turn',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: isMyTurn ? AppColors.success : AppColors.textSecondary,
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                isMyTurn
                    ? 'Tap empty cell — flip adjacent enemy dots!'
                    : 'Waiting for opponent...',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
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
    required this.isYou,
  });

  final String label;
  final int score;
  final Color color;
  final bool isYou;

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
            if (isYou) ...[
              const SizedBox(width: 4),
              Text(
                '(You)',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '$score',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: color),
        ),
      ],
    );
  }
}

