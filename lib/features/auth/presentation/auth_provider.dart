import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';
import '../data/user_repository.dart';
import '../domain/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authRepositoryProvider).currentUser;
});

final userProfileProvider = StreamProvider<UserModel?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(null);
  return ref.watch(userRepositoryProvider).watchUser(user.uid);
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(
    authRepo: ref.watch(authRepositoryProvider),
    userRepo: ref.watch(userRepositoryProvider),
  );
});

class AuthService {
  AuthService({required this.authRepo, required this.userRepo});

  final AuthRepository authRepo;
  final UserRepository userRepo;

  Future<UserModel> ensureAuthenticated() async {
    User? user = authRepo.currentUser;
    if (user == null) {
      user = await authRepo.signInAnonymously();
    }

    var profile = await userRepo.getUser(user.uid);
    if (profile == null) {
      profile = await userRepo.createUser(user.uid);
    }

    return profile;
  }
}
