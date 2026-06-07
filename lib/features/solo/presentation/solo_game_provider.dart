import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../game/domain/game_logic.dart';
import '../domain/bot_ai.dart';

enum SoloGameStatus { playing, finished }

class SoloGameState {
  const SoloGameState({
    required this.board,
    required this.currentTurn,
    required this.score1,
    required this.score2,
    required this.status,
    this.winner,
    this.isBotThinking = false,
  });

  final List<List<int>> board;
  final int currentTurn;
  final int score1;
  final int score2;
  final SoloGameStatus status;
  final String? winner;
  final bool isBotThinking;

  bool get isPlayerTurn => currentTurn == CellState.player1.value;

  SoloGameState copyWith({
    List<List<int>>? board,
    int? currentTurn,
    int? score1,
    int? score2,
    SoloGameStatus? status,
    String? winner,
    bool? isBotThinking,
  }) {
    return SoloGameState(
      board: board ?? this.board,
      currentTurn: currentTurn ?? this.currentTurn,
      score1: score1 ?? this.score1,
      score2: score2 ?? this.score2,
      status: status ?? this.status,
      winner: winner ?? this.winner,
      isBotThinking: isBotThinking ?? this.isBotThinking,
    );
  }

  factory SoloGameState.initial() {
    return SoloGameState(
      board: GameLogic.createEmptyBoard(),
      currentTurn: CellState.player1.value,
      score1: 0,
      score2: 0,
      status: SoloGameStatus.playing,
    );
  }
}

final soloGameProvider =
    StateNotifierProvider.autoDispose<SoloGameNotifier, SoloGameState>((ref) {
  return SoloGameNotifier(ref);
});

class SoloGameNotifier extends StateNotifier<SoloGameState> {
  SoloGameNotifier(this._ref) : super(SoloGameState.initial());

  final Ref _ref;
  bool _statsRecorded = false;

  Future<void> playerMove(int row, int col) async {
    if (state.status != SoloGameStatus.playing) return;
    if (!state.isPlayerTurn || state.isBotThinking) return;
    if (!GameLogic.isValidMove(state.board, row, col)) return;

    _applyMove(row, col, CellState.player1.value);

    if (state.status == SoloGameStatus.finished) {
      await _recordStats();
      return;
    }

    await _botMove();
  }

  Future<void> _botMove() async {
    state = state.copyWith(isBotThinking: true);
    await Future<void>.delayed(const Duration(milliseconds: 600));

    if (state.status != SoloGameStatus.playing) return;

    final move = BotAi.pickMove(state.board, CellState.player2.value);
    if (move == null) {
      state = state.copyWith(isBotThinking: false);
      return;
    }

    _applyMove(move.row, move.col, CellState.player2.value);
    state = state.copyWith(isBotThinking: false);

    if (state.status == SoloGameStatus.finished) {
      await _recordStats();
    }
  }

  void _applyMove(int row, int col, int player) {
    final newBoard = GameLogic.makeMove(state.board, row, col, player);
    final scores = GameLogic.calculateScores(newBoard);

    if (GameLogic.isBoardFull(newBoard)) {
      final winner = GameLogic.determineWinner(scores.score1, scores.score2);
      state = SoloGameState(
        board: newBoard,
        currentTurn: state.currentTurn,
        score1: scores.score1,
        score2: scores.score2,
        status: SoloGameStatus.finished,
        winner: winner,
      );
      return;
    }

    state = SoloGameState(
      board: newBoard,
      currentTurn: GameLogic.nextTurn(state.currentTurn),
      score1: scores.score1,
      score2: scores.score2,
      status: SoloGameStatus.playing,
    );
  }

  Future<void> _recordStats() async {
    if (_statsRecorded || state.winner == null) return;
    _statsRecorded = true;

    final userId = _ref.read(authRepositoryProvider).currentUser?.uid;
    if (userId == null) return;

    final userRepo = _ref.read(userRepositoryProvider);
    if (state.winner == 'draw') {
      await userRepo.recordDraw(userId);
    } else if (state.winner == 'player1') {
      await userRepo.recordWin(userId);
    } else {
      await userRepo.recordLoss(userId);
    }
  }

  void reset() {
    _statsRecorded = false;
    state = SoloGameState.initial();
  }
}
