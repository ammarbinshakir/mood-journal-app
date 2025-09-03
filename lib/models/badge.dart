class Badge {
  final String id;
  final String name;
  final String description;
  final String icon;
  final int requiredPoints;

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.requiredPoints,
  });

  factory Badge.fromMap(Map<String, dynamic> map) {
    return Badge(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      icon: map['icon'] ?? '',
      requiredPoints: map['requiredPoints'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'requiredPoints': requiredPoints,
    };
  }
}

// Predefined badges
final List<Badge> predefinedBadges = [
  Badge(
    id: 'beginner_journal',
    name: 'Beginner Journalist',
    description: 'Added 5 journal entries',
    icon: '📝',
    requiredPoints: 5,
  ),
  Badge(
    id: 'emotion_tracker',
    name: 'Emotion Tracker',
    description: 'Tracked your mood for 7 consecutive days',
    icon: '🎯',
    requiredPoints: 7,
  ),
  Badge(
    id: 'deep_thinker',
    name: 'Deep Thinker',
    description: 'Created 10 journal entries',
    icon: '🧠',
    requiredPoints: 10,
  ),
  Badge(
    id: 'consistency_king',
    name: 'Consistency Champion',
    description: 'Added an entry every day for 2 weeks',
    icon: '👑',
    requiredPoints: 14,
  ),
  Badge(
    id: 'journaling_master',
    name: 'Journaling Master',
    description: 'Created 30 journal entries',
    icon: '🌟',
    requiredPoints: 30,
  ),
];
