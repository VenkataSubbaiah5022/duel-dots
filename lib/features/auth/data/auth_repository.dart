import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  AuthRepository({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<User> signInAnonymously() async {
    final credential = await _auth.signInAnonymously();
    return credential.user!;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
