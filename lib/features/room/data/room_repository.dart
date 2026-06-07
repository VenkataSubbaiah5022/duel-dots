import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/app_constants.dart';
import '../../game/domain/game_logic.dart';
import '../domain/room_model.dart';

class RoomRepository {
  RoomRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _rooms =>
      _firestore.collection(AppConstants.roomsCollection);

  String _generateRoomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random();
    return List.generate(
      AppConstants.roomCodeLength,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
  }

  Future<String> createRoom(String userId) async {
    String roomCode;
    DocumentSnapshot<Map<String, dynamic>> existing;

    do {
      roomCode = _generateRoomCode();
      existing = await _rooms.doc(roomCode).get();
    } while (existing.exists);

    final room = RoomModel(
      roomId: roomCode,
      player1: userId,
      status: RoomStatus.waiting,
    );

    await _rooms.doc(roomCode).set(room.toMap());
    return roomCode;
  }

  Future<RoomModel?> getRoom(String roomCode) async {
    final doc = await _rooms.doc(roomCode.toUpperCase()).get();
    if (!doc.exists) return null;
    return RoomModel.fromMap(doc.id, doc.data()!);
  }

  Stream<RoomModel?> watchRoom(String roomCode) {
    return _rooms.doc(roomCode.toUpperCase()).snapshots().map((doc) {
      if (!doc.exists) return null;
      return RoomModel.fromMap(doc.id, doc.data()!);
    });
  }

  Future<String> joinRoom(String roomCode, String userId) async {
    final code = roomCode.toUpperCase().trim();
    final docRef = _rooms.doc(code);

    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) {
        throw RoomException('Room not found');
      }

      final room = RoomModel.fromMap(snapshot.id, snapshot.data()!);

      if (room.status != RoomStatus.waiting) {
        throw RoomException('Room is no longer available');
      }

      if (room.player1 == userId) {
        return code;
      }

      if (room.player2 != null) {
        throw RoomException('Room is full');
      }

      transaction.update(docRef, {'player2': userId});
      return code;
    });
  }

  Future<void> startGame(String roomCode) async {
    final docRef = _rooms.doc(roomCode.toUpperCase());
    final board = GameLogic.createEmptyBoardFlat();

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;

      final data = snapshot.data()!;
      final status = data['status'] as String? ?? RoomStatus.waiting.value;
      final player1 = data['player1'] as String?;
      final player2 = data['player2'] as String?;

      if (status != RoomStatus.waiting.value) return;
      if (player1 == null || player2 == null) return;

      transaction.update(docRef, {
        'board': board,
        'status': RoomStatus.playing.value,
        'currentTurn': CellState.player1.value,
        'score1': 0,
        'score2': 0,
      });
    });
  }

  Future<void> makeMove(
    String roomCode,
    int row,
    int col,
    int player,
    List<List<int>> newBoard,
    int nextTurn,
    int score1,
    int score2,
    {String? winner, RoomStatus? status}
  ) async {
    final updates = <String, dynamic>{
      'board': GameLogic.boardToFlat(newBoard),
      'currentTurn': nextTurn,
      'score1': score1,
      'score2': score2,
    };

    if (winner != null) {
      updates['winner'] = winner;
      updates['status'] = RoomStatus.finished.value;
    }

    if (status != null) {
      updates['status'] = status.value;
    }

    await _rooms.doc(roomCode.toUpperCase()).update(updates);
  }

  Future<void> deleteRoom(String roomCode) async {
    await _rooms.doc(roomCode.toUpperCase()).delete();
  }

  Future<void> resetRoom(String roomCode) async {
    final board = GameLogic.createEmptyBoardFlat();
    await _rooms.doc(roomCode.toUpperCase()).update({
      'board': board,
      'status': RoomStatus.playing.value,
      'currentTurn': CellState.player1.value,
      'score1': 0,
      'score2': 0,
      'winner': FieldValue.delete(),
    });
  }
}

class RoomException implements Exception {
  RoomException(this.message);
  final String message;

  @override
  String toString() => message;
}
