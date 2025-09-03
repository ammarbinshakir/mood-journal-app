import 'package:intl/intl.dart';

enum MoodType {
  happy,
  neutral,
  sad
}

extension MoodTypeExtension on MoodType {
  String get name {
    switch (this) {
      case MoodType.happy:
        return 'Happy';
      case MoodType.neutral:
        return 'Neutral';
      case MoodType.sad:
        return 'Sad';
    }
  }
  
  String get emoji {
    switch (this) {
      case MoodType.happy:
        return '😊';
      case MoodType.neutral:
        return '😐';
      case MoodType.sad:
        return '😔';
    }
  }
}

class MoodEntry {
  final String id;
  final MoodType mood;
  final DateTime timestamp;
  final String userId;

  MoodEntry({
    required this.id,
    required this.mood,
    required this.timestamp,
    required this.userId,
  });

  factory MoodEntry.fromMap(Map<String, dynamic> map) {
    return MoodEntry(
      id: map['id'] ?? '',
      mood: MoodType.values.firstWhere(
        (e) => e.name.toLowerCase() == (map['mood'] ?? '').toLowerCase(),
        orElse: () => MoodType.neutral,
      ),
      timestamp: map['timestamp'] != null 
          ? (map['timestamp'] is DateTime 
              ? map['timestamp'] 
              : DateTime.parse(map['timestamp']))
          : DateTime.now(),
      userId: map['userId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mood': mood.name.toLowerCase(),
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
    };
  }

  String get formattedDate {
    return DateFormat('MMM dd, yyyy - HH:mm').format(timestamp);
  }
}
