import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../domain/room_model.dart';
import 'room_provider.dart';

class WaitingRoomScreen extends ConsumerStatefulWidget {
  const WaitingRoomScreen({super.key, required this.roomCode});

  final String roomCode;

  @override
  ConsumerState<WaitingRoomScreen> createState() =>
      _WaitingRoomScreenState();
}

class _WaitingRoomScreenState extends ConsumerState<WaitingRoomScreen> {
  bool _startRequested = false;

  @override
  Widget build(BuildContext context) {
    final roomAsync = ref.watch(roomStreamProvider(widget.roomCode));

    return Scaffold(
      appBar: AppBar(title: const Text('Waiting Room')),
      body: roomAsync.when(
        data: (room) {
          if (room == null) {
            return const Center(child: Text('Room not found'));
          }

          _handleRoomUpdate(room);

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),
                  Text(
                    'Room Code',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _copyRoomCode(room.roomId),
                    child: Text(
                      room.roomId,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            letterSpacing: 6,
                            color: AppColors.primary,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (!room.isFull) ...[
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: () => _shareRoomCode(room.roomId),
                      icon: const Icon(Icons.share),
                      label: const Text('Share Room Code'),
                    ),
                  ],
                  const SizedBox(height: 48),
                  _PlayerStatus(
                    label: 'Player 1',
                    joined: room.player1 != null,
                    color: AppColors.player1Blue,
                  ),
                  const SizedBox(height: 16),
                  _PlayerStatus(
                    label: 'Player 2',
                    joined: room.player2 != null,
                    color: AppColors.player2Red,
                  ),
                  const SizedBox(height: 48),
                  if (!room.isFull)
                    const LoadingIndicator(
                      message: 'Waiting for Player 2...',
                    )
                  else
                    Column(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: AppColors.success,
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Both players connected!',
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Starting game...',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
        loading: () => const LoadingIndicator(message: 'Connecting...'),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  void _handleRoomUpdate(RoomModel room) {
    if (room.status == RoomStatus.playing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/game/${widget.roomCode}');
      });
      return;
    }

    if (room.status == RoomStatus.finished) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/result/${widget.roomCode}');
      });
      return;
    }

    if (room.isFull &&
        room.status == RoomStatus.waiting &&
        !_startRequested) {
      _startRequested = true;
      ref.read(roomServiceProvider).startGameIfReady(room).catchError((e) {
        _startRequested = false;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to start game: $e')),
          );
        }
      });
    }
  }

  void _copyRoomCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Room code copied!')),
    );
  }

  void _shareRoomCode(String code) {
    Share.share(
      'Join my DuelDots game! Room Code: $code',
      subject: 'DuelDots Room Invite',
    );
  }
}

class _PlayerStatus extends StatelessWidget {
  const _PlayerStatus({
    required this.label,
    required this.joined,
    required this.color,
  });

  final String label;
  final bool joined;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: joined ? color : Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 16),
            Text(label, style: Theme.of(context).textTheme.titleLarge),
            const Spacer(),
            Text(
              joined ? 'Joined' : 'Waiting...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: joined ? AppColors.success : AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
