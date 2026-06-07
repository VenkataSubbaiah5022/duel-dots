import '../../../core/constants/app_constants.dart';

class GameLogic {
  static int get _cellCount =>
      AppConstants.boardSize * AppConstants.boardSize;

  static List<List<int>> createEmptyBoard() {
    return List.generate(
      AppConstants.boardSize,
      (_) => List.filled(AppConstants.boardSize, CellState.empty.value),
    );
  }

  /// Firestore does not support nested arrays — store board as a flat list.
  static List<int> createEmptyBoardFlat() {
    return List.filled(_cellCount, CellState.empty.value);
  }

  static List<int> boardToFlat(List<List<int>> board) {
    return [
      for (final row in board) ...row,
    ];
  }

  static List<List<int>> boardFromFirestore(List<dynamic> data) {
    if (data.isEmpty) return createEmptyBoard();

    if (data.first is List) {
      return data
          .map((row) => (row as List<dynamic>).map((c) => c as int).toList())
          .toList();
    }

    final flat = data.map((c) => (c as num).toInt()).toList();
    return List.generate(AppConstants.boardSize, (row) {
      return List.generate(AppConstants.boardSize, (col) {
        return flat[row * AppConstants.boardSize + col];
      });
    });
  }

  static bool isValidMove(List<List<int>> board, int row, int col) {
    if (row < 0 ||
        row >= AppConstants.boardSize ||
        col < 0 ||
        col >= AppConstants.boardSize) {
      return false;
    }
    return board[row][col] == CellState.empty.value;
  }

  static List<List<int>> makeMove(
    List<List<int>> board,
    int row,
    int col,
    int player,
  ) {
    final newBoard = board.map((r) => List<int>.from(r)).toList();
    newBoard[row][col] = player;

    final opponent = player == CellState.player1.value
        ? CellState.player2.value
        : CellState.player1.value;

    const directions = [
      [-1, 0],
      [1, 0],
      [0, -1],
      [0, 1],
    ];

    for (final dir in directions) {
      final nr = row + dir[0];
      final nc = col + dir[1];
      if (nr >= 0 &&
          nr < AppConstants.boardSize &&
          nc >= 0 &&
          nc < AppConstants.boardSize &&
          newBoard[nr][nc] == opponent) {
        newBoard[nr][nc] = player;
      }
    }

    return newBoard;
  }

  static bool isBoardFull(List<List<int>> board) {
    for (final row in board) {
      for (final cell in row) {
        if (cell == CellState.empty.value) return false;
      }
    }
    return true;
  }

  static int countCells(List<List<int>> board, int player) {
    int count = 0;
    for (final row in board) {
      for (final cell in row) {
        if (cell == player) count++;
      }
    }
    return count;
  }

  static ({int score1, int score2}) calculateScores(List<List<int>> board) {
    return (
      score1: countCells(board, CellState.player1.value),
      score2: countCells(board, CellState.player2.value),
    );
  }

  static String? determineWinner(int score1, int score2) {
    if (score1 > score2) return 'player1';
    if (score2 > score1) return 'player2';
    return 'draw';
  }

  static int nextTurn(int currentTurn) {
    return currentTurn == CellState.player1.value
        ? CellState.player2.value
        : CellState.player1.value;
  }

  static int? getPlayerSlot(String? player1, String? player2, String userId) {
    if (player1 == userId) return CellState.player1.value;
    if (player2 == userId) return CellState.player2.value;
    return null;
  }
}
