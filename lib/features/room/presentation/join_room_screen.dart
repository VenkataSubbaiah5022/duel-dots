import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/app_button.dart';
import 'room_provider.dart';

class JoinRoomScreen extends ConsumerStatefulWidget {
  const JoinRoomScreen({super.key});

  @override
  ConsumerState<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends ConsumerState<JoinRoomScreen> {
  final _controller = TextEditingController();
  bool _isJoining = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _joinRoom() async {
    final code = _controller.text.trim().toUpperCase();
    if (code.length != AppConstants.roomCodeLength) {
      setState(() => _error = 'Enter a valid ${AppConstants.roomCodeLength}-character room code');
      return;
    }

    setState(() {
      _isJoining = true;
      _error = null;
    });

    try {
      await ref.read(roomServiceProvider).joinRoom(code);
      if (mounted) context.go('/waiting/$code');
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isJoining = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Join Room')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              Text(
                'Enter Room Code',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Ask your friend for their room code',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _controller,
                textAlign: TextAlign.center,
                textCapitalization: TextCapitalization.characters,
                maxLength: AppConstants.roomCodeLength,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      letterSpacing: 6,
                    ),
                decoration: const InputDecoration(
                  hintText: 'A8P7X',
                  counterText: '',
                ),
                onChanged: (_) {
                  if (_error != null) setState(() => _error = null);
                },
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
              const Spacer(),
              AppButton(
                label: 'Join Room',
                isLoading: _isJoining,
                onPressed: _isJoining ? null : _joinRoom,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
