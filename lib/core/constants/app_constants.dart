class AppConstants {
  static const String appName = 'DuelDots';
  static const int boardSize = 5;
  static const int roomCodeLength = 5;
  static const String usersCollection = 'users';
  static const String roomsCollection = 'rooms';
  static const String matchesCollection = 'matches';
}

enum CellState {
  empty(0),
  player1(1),
  player2(2);

  const CellState(this.value);
  final int value;

  static CellState fromValue(int value) {
    return CellState.values.firstWhere(
      (e) => e.value == value,
      orElse: () => CellState.empty,
    );
  }
}

enum RoomStatus {
  waiting('waiting'),
  playing('playing'),
  finished('finished');

  const RoomStatus(this.value);
  final String value;

  static RoomStatus fromValue(String value) {
    return RoomStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => RoomStatus.waiting,
    );
  }
}

enum PlayerSlot {
  player1(1),
  player2(2);

  const PlayerSlot(this.value);
  final int value;

  static PlayerSlot fromValue(int value) {
    return PlayerSlot.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PlayerSlot.player1,
    );
  }
}
