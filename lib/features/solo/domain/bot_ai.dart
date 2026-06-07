import 'dart:math';

import '../../../core/constants/app_constants.dart';
import '../../game/domain/game_logic.dart';

class BotAi {
  static final _random = Random();

  static ({int row, int col})? pickMove(
    List<List<int>> board,
    int botPlayer,
  ) {
    final candidates = <({int row, int col, int score})>[];

    for (var row = 0; row < AppConstants.boardSize; row++) {
      for (var col = 0; col < AppConstants.boardSize; col++) {
        if (!GameLogic.isValidMove(board, row, col)) continue;

        final newBoard = GameLogic.makeMove(board, row, col, botPlayer);
        final scores = GameLogic.calculateScores(newBoard);
        final myScore = botPlayer == CellState.player1.value
            ? scores.score1
            : scores.score2;
        final captures = _countGainedDots(board, newBoard, botPlayer);

        final score = captures * 15 + myScore + _random.nextInt(3);
        candidates.add((row: row, col: col, score: score));
      }
    }

    if (candidates.isEmpty) return null;

    candidates.sort((a, b) => b.score.compareTo(a.score));
    final bestScore = candidates.first.score;
    final topMoves =
        candidates.where((m) => m.score >= bestScore - 2).toList();
    final pick = topMoves[_random.nextInt(topMoves.length)];
    return (row: pick.row, col: pick.col);
  }

  static int _countGainedDots(
    List<List<int>> before,
    List<List<int>> after,
    int player,
  ) {
    return GameLogic.countCells(after, player) -
        GameLogic.countCells(before, player);
  }
}
