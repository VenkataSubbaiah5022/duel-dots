class MatchModel {
  const MatchModel({
    required this.matchId,
    required this.winner,
    required this.score1,
    required this.score2,
    required this.player1,
    required this.player2,
    required this.createdAt,
  });

  final String matchId;
  final String winner;
  final int score1;
  final int score2;
  final String player1;
  final String player2;
  final DateTime createdAt;

  factory MatchModel.fromMap(String id, Map<String, dynamic> map) {
    return MatchModel(
      matchId: id,
      winner: map['winner'] as String? ?? '',
      score1: (map['score1'] as num?)?.toInt() ?? 0,
      score2: (map['score2'] as num?)?.toInt() ?? 0,
      player1: map['player1'] as String? ?? '',
      player2: map['player2'] as String? ?? '',
      createdAt: (map['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'matchId': matchId,
      'winner': winner,
      'score1': score1,
      'score2': score2,
      'player1': player1,
      'player2': player2,
      'createdAt': createdAt,
    };
  }
}
