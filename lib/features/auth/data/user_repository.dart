import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/app_constants.dart';
import '../domain/user_model.dart';

class UserRepository {
  UserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection(AppConstants.usersCollection);

  Future<UserModel> createUser(String userId) async {
    final username = _generateUsername();
    final user = UserModel(id: userId, username: username);
    await _users.doc(userId).set(user.toMap());
    return user;
  }

  Future<UserModel?> getUser(String userId) async {
    final doc = await _users.doc(userId).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!);
  }

  Stream<UserModel?> watchUser(String userId) {
    return _users.doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromMap(doc.data()!);
    });
  }

  Future<void> recordWin(String userId) async {
    await _users.doc(userId).update({
      'wins': FieldValue.increment(1),
      'totalGames': FieldValue.increment(1),
    });
  }

  Future<void> recordLoss(String userId) async {
    await _users.doc(userId).update({
      'losses': FieldValue.increment(1),
      'totalGames': FieldValue.increment(1),
    });
  }

  Future<void> recordDraw(String userId) async {
    await _users.doc(userId).update({
      'totalGames': FieldValue.increment(1),
    });
  }

  Future<List<UserModel>> getLeaderboard({int limit = 50}) async {
    final snapshot = await _users
        .orderBy('wins', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs
        .map((doc) => UserModel.fromMap(doc.data()))
        .toList();
  }

  String _generateUsername() {
    final adjectives = [
      'Swift', 'Bold', 'Clever', 'Lucky', 'Sharp',
      'Quick', 'Brave', 'Mighty', 'Silent', 'Fierce',
    ];
    final nouns = [
      'Dot', 'Grid', 'Cell', 'Star', 'King',
      'Ace', 'Pro', 'Hero', 'Wolf', 'Hawk',
    ];
    final random = Random();
    final adj = adjectives[random.nextInt(adjectives.length)];
    final noun = nouns[random.nextInt(nouns.length)];
    final num = random.nextInt(900) + 100;
    return '$adj$noun$num';
  }
}
