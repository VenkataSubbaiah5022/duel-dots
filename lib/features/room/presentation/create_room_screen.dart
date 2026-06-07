import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/loading_indicator.dart';
import 'room_provider.dart';

class CreateRoomScreen extends ConsumerStatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  ConsumerState<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends ConsumerState<CreateRoomScreen> {
  String? _roomCode;
  bool _isCreating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _createRoom();
  }

  Future<void> _createRoom() async {
    setState(() {
      _isCreating = true;
      _error = null;
    });

    try {
      final code = await ref.read(roomServiceProvider).createRoom();
      if (mounted) {
        setState(() {
          _roomCode = code;
          _isCreating = false;
        });
        context.go('/waiting/$code');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isCreating = false;
        });
      }
    }
  }

  void _shareRoomCode() {
    if (_roomCode == null) return;
    Share.share(
      'Join my DuelDots game! Room Code: $_roomCode',
      subject: 'DuelDots Room Invite',
    );
  }

  void _copyRoomCode() {
    if (_roomCode == null) return;
    Clipboard.setData(ClipboardData(text: _roomCode!));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Room code copied!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Room')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _isCreating
              ? const LoadingIndicator(message: 'Creating room...')
              : _error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_error!, textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          AppButton(label: 'Retry', onPressed: _createRoom),
                        ],
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Spacer(),
                        const Icon(
                          Icons.meeting_room_outlined,
                          size: 64,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Room Code',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _copyRoomCode,
                          child: Text(
                            _roomCode ?? '',
                            style: Theme.of(context)
                                .textTheme
                                .headlineLarge
                                ?.copyWith(
                                  letterSpacing: 8,
                                  color: AppColors.primary,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap to copy',
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        const LoadingIndicator(
                          message: 'Waiting for Player...',
                        ),
                        const Spacer(),
                        AppButton(
                          label: 'Share Room Code',
                          icon: Icons.share,
                          onPressed: _shareRoomCode,
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}
