import 'package:intl/intl.dart';

class JournalEntry {
  final String id;
  final String title;
  final String content;
  final DateTime timestamp;
  final String userId;
  final String? mood;

  JournalEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.timestamp,
    required this.userId,
    this.mood,
  });

  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      timestamp: map['timestamp'] != null 
          ? (map['timestamp'] is DateTime 
              ? map['timestamp'] 
              : DateTime.parse(map['timestamp']))
          : DateTime.now(),
      userId: map['userId'] ?? '',
      mood: map['mood'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
      'mood': mood,
    };
  }

  String get formattedDate {
    return DateFormat('MMM dd, yyyy - HH:mm').format(timestamp);
  }

  JournalEntry copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? timestamp,
    String? userId,
    String? mood,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      userId: userId ?? this.userId,
      mood: mood ?? this.mood,
    );
  }
}
