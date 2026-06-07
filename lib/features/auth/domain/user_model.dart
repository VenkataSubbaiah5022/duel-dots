class UserModel {
  const UserModel({
    required this.id,
    required this.username,
    this.wins = 0,
    this.losses = 0,
    this.totalGames = 0,
  });

  final String id;
  final String username;
  final int wins;
  final int losses;
  final int totalGames;

  double get winRate => totalGames > 0 ? wins / totalGames : 0.0;

  UserModel copyWith({
    String? id,
    String? username,
    int? wins,
    int? losses,
    int? totalGames,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      totalGames: totalGames ?? this.totalGames,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String? ?? '',
      username: map['username'] as String? ?? 'Player',
      wins: (map['wins'] as num?)?.toInt() ?? 0,
      losses: (map['losses'] as num?)?.toInt() ?? 0,
      totalGames: (map['totalGames'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'wins': wins,
      'losses': losses,
      'totalGames': totalGames,
    };
  }
}
