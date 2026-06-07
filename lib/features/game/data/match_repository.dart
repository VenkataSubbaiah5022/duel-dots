import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/app_constants.dart';
import '../domain/match_model.dart';

class MatchRepository {
  MatchRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _matches =>
      _firestore.collection(AppConstants.matchesCollection);

  Future<void> saveMatch({
    required String roomId,
    required String player1,
    required String player2,
    required String winner,
    required int score1,
    required int score2,
  }) async {
    await _matches.doc(roomId).set({
      'matchId': roomId,
      'winner': winner,
      'score1': score1,
      'score2': score2,
      'player1': player1,
      'player2': player2,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
