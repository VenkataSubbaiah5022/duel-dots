import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../room/domain/room_model.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../room/presentation/room_provider.dart';
import 'game_provider.dart';

class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({super.key, required this.roomCode});

  final String roomCode;

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  @override
  Widget build(BuildContext context) {
    final roomAsync = ref.watch(roomStreamProvider(widget.roomCode));
    final gameService = ref.watch(gameServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Match Result')),
      body: roomAsync.when(
        data: (room) {
          if (room == null) {
            return const Center(child: Text('Room not found'));
          }

          if (room.status == RoomStatus.playing) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) context.go('/game/${widget.roomCode}');
            });
          }

          if (room.status == RoomStatus.finished) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.read(gameServiceProvider).recordMyResult(room);
            });
          }

          final playerSlot = gameService.getPlayerSlot(room);
          final isPlayer1 = playerSlot == CellState.player1.value;
          final myScore = isPlayer1 ? room.score1 : room.score2;
          final opponentScore = isPlayer1 ? room.score2 : room.score1;

          String resultText;
          Color resultColor;
          IconData resultIcon;

          if (room.winner == 'draw') {
            resultText = 'Draw!';
            resultColor = AppColors.textSecondary;
            resultIcon = Icons.handshake;
          } else if ((room.winner == 'player1' && isPlayer1) ||
              (room.winner == 'player2' && !isPlayer1)) {
            resultText = 'You Win!';
            resultColor = AppColors.success;
            resultIcon = Icons.emoji_events;
          } else {
            resultText = 'You Lose';
            resultColor = AppColors.error;
            resultIcon = Icons.sentiment_dissatisfied;
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Spacer(),
                  Icon(resultIcon, size: 80, color: resultColor),
                  const SizedBox(height: 24),
                  Text(
                    resultText,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: resultColor,
                        ),
                  ),
                  const SizedBox(height: 48),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _ResultScore(
                            label: 'Your Score',
                            score: myScore,
                            color: isPlayer1
                                ? AppColors.player1Blue
                                : AppColors.player2Red,
                          ),
                          Container(
                            width: 1,
                            height: 60,
                            color: Colors.grey.shade300,
                          ),
                          _ResultScore(
                            label: 'Opponent',
                            score: opponentScore,
                            color: isPlayer1
                                ? AppColors.player2Red
                                : AppColors.player1Blue,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  AppButton(
                    label: 'Play Again',
                    onPressed: () async {
                      await ref
                          .read(gameServiceProvider)
                          .playAgain(widget.roomCode);
                      if (context.mounted) {
                        context.go('/game/${widget.roomCode}');
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    label: 'Back Home',
                    isOutlined: true,
                    onPressed: () => context.go('/home'),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _ResultScore extends StatelessWidget {
  const _ResultScore({
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
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        Text(
          '$score',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
