class UserModel {
  final String id;
  final String email;
  final int points;
  final List<String> badges;

  UserModel({
    required this.id,
    required this.email,
    this.points = 0,
    this.badges = const [],
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      points: map['points'] ?? 0,
      badges: List<String>.from(map['badges'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'points': points,
      'badges': badges,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    int? points,
    List<String>? badges,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      points: points ?? this.points,
      badges: badges ?? this.badges,
    );
  }
}
