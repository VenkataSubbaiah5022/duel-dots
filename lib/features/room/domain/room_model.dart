import '../../../core/constants/app_constants.dart';
import '../../game/domain/game_logic.dart';

class RoomModel {
  const RoomModel({
    required this.roomId,
    this.player1,
    this.player2,
    this.currentTurn = 1,
    this.board,
    this.status = RoomStatus.waiting,
    this.score1 = 0,
    this.score2 = 0,
    this.winner,
  });

  final String roomId;
  final String? player1;
  final String? player2;
  final int currentTurn;
  final List<List<int>>? board;
  final RoomStatus status;
  final int score1;
  final int score2;
  final String? winner;

  bool get isFull => player1 != null && player2 != null;

  int get playerCount =>
      (player1 != null ? 1 : 0) + (player2 != null ? 1 : 0);

  RoomModel copyWith({
    String? roomId,
    String? player1,
    String? player2,
    int? currentTurn,
    List<List<int>>? board,
    RoomStatus? status,
    int? score1,
    int? score2,
    String? winner,
  }) {
    return RoomModel(
      roomId: roomId ?? this.roomId,
      player1: player1 ?? this.player1,
      player2: player2 ?? this.player2,
      currentTurn: currentTurn ?? this.currentTurn,
      board: board ?? this.board,
      status: status ?? this.status,
      score1: score1 ?? this.score1,
      score2: score2 ?? this.score2,
      winner: winner ?? this.winner,
    );
  }

  factory RoomModel.fromMap(String id, Map<String, dynamic> map) {
    final boardData = map['board'] as List<dynamic>?;
    final board =
        boardData != null ? GameLogic.boardFromFirestore(boardData) : null;

    return RoomModel(
      roomId: id,
      player1: map['player1'] as String?,
      player2: map['player2'] as String?,
      currentTurn: (map['currentTurn'] as num?)?.toInt() ?? 1,
      board: board,
      status: RoomStatus.fromValue(map['status'] as String? ?? 'waiting'),
      score1: (map['score1'] as num?)?.toInt() ?? 0,
      score2: (map['score2'] as num?)?.toInt() ?? 0,
      winner: map['winner'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'roomId': roomId,
      'player1': player1,
      'player2': player2,
      'currentTurn': currentTurn,
      'board': board != null ? GameLogic.boardToFlat(board!) : null,
      'status': status.value,
      'score1': score1,
      'score2': score2,
      'winner': winner,
    };
  }
}
