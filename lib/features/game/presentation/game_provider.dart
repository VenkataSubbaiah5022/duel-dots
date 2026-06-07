import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../auth/presentation/auth_provider.dart';
import '../data/match_repository.dart';
import '../domain/game_logic.dart';
import '../../room/data/room_repository.dart';
import '../../room/domain/room_model.dart';
import '../../room/presentation/room_provider.dart';

final matchRepositoryProvider = Provider<MatchRepository>((ref) {
  return MatchRepository();
});

final gameServiceProvider = Provider<GameService>((ref) {
  return GameService(
    roomRepo: ref.watch(roomRepositoryProvider),
    matchRepo: ref.watch(matchRepositoryProvider),
    userRepo: ref.watch(userRepositoryProvider),
    authRepo: ref.watch(authRepositoryProvider),
  );
});

class GameService {
  GameService({
    required this.roomRepo,
    required this.matchRepo,
    required this.userRepo,
    required this.authRepo,
  });

  final RoomRepository roomRepo;
  final MatchRepository matchRepo;
  final dynamic userRepo;
  final dynamic authRepo;

  final Set<String> _recordedRooms = {};

  String? get currentUserId => authRepo.currentUser?.uid;

  int? getPlayerSlot(RoomModel room) {
    return GameLogic.getPlayerSlot(
      room.player1,
      room.player2,
      currentUserId ?? '',
    );
  }

  bool isMyTurn(RoomModel room) {
    final slot = getPlayerSlot(room);
    return slot != null && slot == room.currentTurn;
  }

  Future<void> makeMove(RoomModel room, int row, int col) async {
    final userId = currentUserId;
    if (userId == null) return;

    final playerSlot = getPlayerSlot(room);
    if (playerSlot == null) return;

    final board = room.board;
    if (board == null) return;

    if (!isMyTurn(room)) return;
    if (!GameLogic.isValidMove(board, row, col)) return;

    final newBoard = GameLogic.makeMove(board, row, col, playerSlot);
    final scores = GameLogic.calculateScores(newBoard);

    String? winner;
    RoomStatus? status;
    final nextTurn = GameLogic.isBoardFull(newBoard)
        ? room.currentTurn
        : GameLogic.nextTurn(room.currentTurn);

    if (GameLogic.isBoardFull(newBoard)) {
      winner = GameLogic.determineWinner(scores.score1, scores.score2);
      status = RoomStatus.finished;
    }

    await roomRepo.makeMove(
      room.roomId,
      row,
      col,
      playerSlot,
      newBoard,
      nextTurn,
      scores.score1,
      scores.score2,
      winner: winner,
      status: status,
    );
  }

  Future<void> recordMyResult(RoomModel room) async {
    if (room.status != RoomStatus.finished || room.winner == null) return;
    if (_recordedRooms.contains(room.roomId)) return;

    final userId = currentUserId;
    if (userId == null) return;

    _recordedRooms.add(room.roomId);

    try {
      await matchRepo.saveMatch(
        roomId: room.roomId,
        player1: room.player1!,
        player2: room.player2!,
        winner: room.winner!,
        score1: room.score1,
        score2: room.score2,
      );

      final isPlayer1 = room.player1 == userId;
      final iWon = (room.winner == 'player1' && isPlayer1) ||
          (room.winner == 'player2' && !isPlayer1);

      if (room.winner == 'draw') {
        await userRepo.recordDraw(userId);
      } else if (iWon) {
        await userRepo.recordWin(userId);
      } else {
        await userRepo.recordLoss(userId);
      }
    } catch (_) {
      _recordedRooms.remove(room.roomId);
    }
  }

  Future<void> leaveRoom(String roomCode) async {
    await roomRepo.deleteRoom(roomCode);
  }

  Future<void> playAgain(String roomCode) async {
    await roomRepo.resetRoom(roomCode);
  }
}
