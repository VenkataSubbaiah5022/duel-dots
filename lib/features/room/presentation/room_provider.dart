import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../auth/presentation/auth_provider.dart';
import '../data/room_repository.dart';
import '../domain/room_model.dart';

final roomRepositoryProvider = Provider<RoomRepository>((ref) {
  return RoomRepository();
});

final roomStreamProvider =
    StreamProvider.family<RoomModel?, String>((ref, roomCode) {
  return ref.watch(roomRepositoryProvider).watchRoom(roomCode);
});

final roomServiceProvider = Provider<RoomService>((ref) {
  return RoomService(
    roomRepo: ref.watch(roomRepositoryProvider),
    authRepo: ref.watch(authRepositoryProvider),
  );
});

class RoomService {
  RoomService({required this.roomRepo, required this.authRepo});

  final RoomRepository roomRepo;
  final dynamic authRepo;

  String? get currentUserId => authRepo.currentUser?.uid;

  Future<String> createRoom() async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Not authenticated');
    return roomRepo.createRoom(userId);
  }

  Future<String> joinRoom(String roomCode) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Not authenticated');
    return roomRepo.joinRoom(roomCode, userId);
  }

  Future<void> startGameIfReady(RoomModel room) async {
    if (room.isFull && room.status == RoomStatus.waiting) {
      await roomRepo.startGame(room.roomId);
    }
  }
}
