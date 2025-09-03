import 'package:mood_journal_app/models/journal_entry.dart';
import 'package:mood_journal_app/models/mood_entry.dart';
import 'package:mood_journal_app/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mood_journal_app/utils/exceptions.dart';
import 'dart:convert';
import 'dart:math';

class JournalService {
  final ApiService _apiService;
  
  // Use mock data for development
  final bool useMockData;
  
  JournalService({
    required ApiService apiService, 
    this.useMockData = true
  }) : _apiService = apiService;
  
  // Get all journal entries for a user
  Future<List<JournalEntry>> getJournalEntries(String userId) async {
    try {
      if (useMockData) {
        final data = await _getMockJournalEntries(userId);
        return data;
      } else {
        final response = await _apiService.get('journal/entries?userId=$userId');
        final List<dynamic> entriesData = response['entries'] ?? [];
        return entriesData
            .map((entry) => JournalEntry.fromMap(entry))
            .toList();
      }
    } catch (e) {
      throw ApiException('Failed to get journal entries: ${e.toString()}');
    }
  }
  
  // Get a specific journal entry
  Future<JournalEntry> getJournalEntry(String entryId) async {
    try {
      if (useMockData) {
        final entries = await _getMockJournalEntries('mock-user-id');
        final entry = entries.firstWhere(
          (e) => e.id == entryId,
          orElse: () => throw ApiException('Journal entry not found'),
        );
        return entry;
      } else {
        final response = await _apiService.get('journal/entries/$entryId');
        return JournalEntry.fromMap(response);
      }
    } catch (e) {
      throw ApiException('Failed to get journal entry: ${e.toString()}');
    }
  }
  
  // Create a new journal entry
  Future<JournalEntry> createJournalEntry(JournalEntry entry) async {
    try {
      if (useMockData) {
        // Create new entry in local storage
        final prefs = await SharedPreferences.getInstance();
        final entriesJson = prefs.getString('journal_entries_${entry.userId}') ?? '[]';
        final entries = List<Map<String, dynamic>>.from(
          json.decode(entriesJson),
        );
        
        // Generate a unique ID
        final newId = 'entry-${DateTime.now().millisecondsSinceEpoch}';
        final newEntry = entry.copyWith(
          id: newId,
          timestamp: DateTime.now(),
        );
        
        entries.add(newEntry.toMap());
        await prefs.setString('journal_entries_${entry.userId}', json.encode(entries));
        
        // Update user points and check for badges
        await _updateUserPoints(entry.userId);
        
        return newEntry;
      } else {
        final response = await _apiService.post(
          'journal/entries',
          entry.toMap(),
        );
        return JournalEntry.fromMap(response);
      }
    } catch (e) {
      throw ApiException('Failed to create journal entry: ${e.toString()}');
    }
  }
  
  // Update an existing journal entry
  Future<JournalEntry> updateJournalEntry(JournalEntry entry) async {
    try {
      if (useMockData) {
        // Update entry in local storage
        final prefs = await SharedPreferences.getInstance();
        final entriesJson = prefs.getString('journal_entries_${entry.userId}') ?? '[]';
        final entries = List<Map<String, dynamic>>.from(
          json.decode(entriesJson),
        );
        
        final index = entries.indexWhere((e) => e['id'] == entry.id);
        if (index == -1) {
          throw ApiException('Journal entry not found');
        }
        
        entries[index] = entry.toMap();
        await prefs.setString('journal_entries_${entry.userId}', json.encode(entries));
        
        return entry;
      } else {
        final response = await _apiService.put(
          'journal/entries/${entry.id}',
          entry.toMap(),
        );
        return JournalEntry.fromMap(response);
      }
    } catch (e) {
      throw ApiException('Failed to update journal entry: ${e.toString()}');
    }
  }
  
  // Delete a journal entry
  Future<void> deleteJournalEntry(String entryId, String userId) async {
    try {
      if (useMockData) {
        // Delete entry from local storage
        final prefs = await SharedPreferences.getInstance();
        final entriesJson = prefs.getString('journal_entries_$userId') ?? '[]';
        
        try {
          // Safely decode the JSON and handle potential type issues
          final List<dynamic> decodedList = json.decode(entriesJson);
          
          // Safely cast each item to Map<String, dynamic>
          final entries = decodedList.map((item) => 
            Map<String, dynamic>.from(item as Map<dynamic, dynamic>)
          ).toList();
          
          // Filter out the entry to delete
          final filteredEntries = entries.where((e) => e['id'] != entryId).toList();
          
          // Save the updated list back to SharedPreferences
          await prefs.setString('journal_entries_$userId', json.encode(filteredEntries));
          
          // Update user points and badges after deletion
          await _updateUserPoints(userId);
        } catch (jsonError) {
          // Handle JSON parsing errors gracefully
          print('Error parsing journal entries JSON: $jsonError');
          // Still continue with the operation, even if local storage update failed
        }
      } else {
        await _apiService.delete('journal/entries/$entryId');
      }
    } catch (e) {
      throw ApiException('Failed to delete journal entry: ${e.toString()}');
    }
  }
  
  // Record a mood entry
  Future<MoodEntry> recordMood(MoodEntry moodEntry) async {
    try {
      if (useMockData) {
        // Save mood entry to local storage
        final prefs = await SharedPreferences.getInstance();
        final moodsJson = prefs.getString('mood_entries_${moodEntry.userId}') ?? '[]';
        final moods = List<Map<String, dynamic>>.from(
          json.decode(moodsJson),
        );
        
        // Generate a unique ID
        final newId = 'mood-${DateTime.now().millisecondsSinceEpoch}';
        final newMood = MoodEntry(
          id: newId,
          mood: moodEntry.mood,
          timestamp: DateTime.now(),
          userId: moodEntry.userId,
        );
        
        moods.add(newMood.toMap());
        await prefs.setString('mood_entries_${moodEntry.userId}', json.encode(moods));
        
        // Update user points and check for badges
        await _updateUserPoints(moodEntry.userId);
        
        return newMood;
      } else {
        final response = await _apiService.post(
          'moods',
          moodEntry.toMap(),
        );
        return MoodEntry.fromMap(response);
      }
    } catch (e) {
      throw ApiException('Failed to record mood: ${e.toString()}');
    }
  }
  
  // Get mood entries for a user
  Future<List<MoodEntry>> getMoodEntries(String userId) async {
    try {
      if (useMockData) {
        // Get mood entries from local storage
        final prefs = await SharedPreferences.getInstance();
        final moodsJson = prefs.getString('mood_entries_$userId') ?? '[]';
        final moods = List<Map<String, dynamic>>.from(
          json.decode(moodsJson),
        );
        
        if (moods.isEmpty) {
          // Return mock data if no entries yet
          return _getMockMoodEntries(userId);
        }
        
        return moods
            .map((mood) => MoodEntry.fromMap(mood))
            .toList();
      } else {
        final response = await _apiService.get('moods?userId=$userId');
        final List<dynamic> moodsData = response['moods'] ?? [];
        return moodsData
            .map((mood) => MoodEntry.fromMap(mood))
            .toList();
      }
    } catch (e) {
      throw ApiException('Failed to get mood entries: ${e.toString()}');
    }
  }
  
  // Generate mock journal entries
  Future<List<JournalEntry>> _getMockJournalEntries(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final entriesJson = prefs.getString('journal_entries_$userId') ?? '[]';
    final entries = List<Map<String, dynamic>>.from(
      json.decode(entriesJson),
    );
    
    if (entries.isEmpty) {
      // Generate some mock entries if none exist yet
      final mockEntries = [
        JournalEntry(
          id: 'entry-1',
          title: 'My First Journal Entry',
          content: 'Today was a great day! I started my mood journal app and I\'m feeling positive about it.',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          userId: userId,
          mood: 'happy',
        ),
        JournalEntry(
          id: 'entry-2',
          title: 'Feeling Down',
          content: 'Had a tough day at work. Things didn\'t go as planned, but tomorrow is another day.',
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          userId: userId,
          mood: 'sad',
        ),
        JournalEntry(
          id: 'entry-3',
          title: 'Just an Average Day',
          content: 'Nothing special happened today. Just a regular day with its ups and downs.',
          timestamp: DateTime.now().subtract(const Duration(days: 3)),
          userId: userId,
          mood: 'neutral',
        ),
      ];
      
      // Save mock entries to local storage
      await prefs.setString(
        'journal_entries_$userId',
        json.encode(mockEntries.map((e) => e.toMap()).toList()),
      );
      
      return mockEntries;
    }
    
    return entries
        .map((entry) => JournalEntry.fromMap(entry))
        .toList();
  }
  
  // Generate mock mood entries
  List<MoodEntry> _getMockMoodEntries(String userId) {
    return [
      MoodEntry(
        id: 'mood-1',
        mood: MoodType.happy,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        userId: userId,
      ),
      MoodEntry(
        id: 'mood-2',
        mood: MoodType.sad,
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        userId: userId,
      ),
      MoodEntry(
        id: 'mood-3',
        mood: MoodType.neutral,
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        userId: userId,
      ),
      MoodEntry(
        id: 'mood-4',
        mood: MoodType.happy,
        timestamp: DateTime.now().subtract(const Duration(days: 4)),
        userId: userId,
      ),
      MoodEntry(
        id: 'mood-5',
        mood: MoodType.happy,
        timestamp: DateTime.now().subtract(const Duration(days: 5)),
        userId: userId,
      ),
    ];
  }
  
  // Update user points and check for badges
  Future<void> _updateUserPoints(String userId) async {
    try {
      // Get current journal entries count
      final entries = await getJournalEntries(userId);
      final moods = await getMoodEntries(userId);
      
      // Calculate total points (1 point per entry or mood)
      final totalPoints = entries.length + moods.length;
      
      // Store points in SharedPreferences for mock implementation
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_points_$userId', totalPoints);
      
      // Check for badges based on points
      if (totalPoints >= 5) {
        await _awardBadge(userId, 'beginner_journal');
      }
      
      if (totalPoints >= 10) {
        await _awardBadge(userId, 'deep_thinker');
      }
      
      if (totalPoints >= 30) {
        await _awardBadge(userId, 'journaling_master');
      }
      
      // Check for streak (consecutive days)
      final hasStreak = _checkForStreak(moods);
      if (hasStreak) {
        await _awardBadge(userId, 'emotion_tracker');
      }
      
    } catch (e) {
      // Silently fail - gamification isn't critical
    }
  }
  
  // Award a badge to the user
  Future<void> _awardBadge(String userId, String badgeId) async {
    try {
      // Get current badges
      final prefs = await SharedPreferences.getInstance();
      final badgesJson = prefs.getString('user_badges_$userId') ?? '[]';
      final badges = List<String>.from(json.decode(badgesJson));
      
      // Only add badge if user doesn't already have it
      if (!badges.contains(badgeId)) {
        badges.add(badgeId);
        await prefs.setString('user_badges_$userId', json.encode(badges));
      }
    } catch (e) {
      // Silently fail - gamification isn't critical
    }
  }
  
  // Check for a streak of consecutive days
  bool _checkForStreak(List<MoodEntry> moods) {
    // Sort moods by date
    final sortedMoods = List<MoodEntry>.from(moods)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    // Check for 7 consecutive days
    if (sortedMoods.length < 7) return false;
    
    // Get the first 7 entries and check if they cover consecutive days
    final dates = sortedMoods.take(7).map((m) => 
        DateTime(m.timestamp.year, m.timestamp.month, m.timestamp.day)
    ).toList();
    
    // Remove duplicates (in case of multiple entries on same day)
    final uniqueDates = dates.toSet().toList()
      ..sort((a, b) => b.compareTo(a));
    
    // If we don't have at least 7 unique dates, return false
    if (uniqueDates.length < 7) return false;
    
    // Check if the dates are consecutive
    for (int i = 0; i < uniqueDates.length - 1; i++) {
      final diff = uniqueDates[i].difference(uniqueDates[i + 1]).inDays;
      if (diff != 1) return false;
    }
    
    return true;
  }
}
