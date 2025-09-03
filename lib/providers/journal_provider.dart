import 'package:flutter/foundation.dart';
import 'package:mood_journal_app/models/journal_entry.dart';
import 'package:mood_journal_app/models/mood_entry.dart';
import 'package:mood_journal_app/services/journal_service.dart';
import 'package:mood_journal_app/utils/exceptions.dart';

class JournalProvider with ChangeNotifier {
  final JournalService _journalService;
  final String _userId;
  
  // State
  List<JournalEntry> _entries = [];
  List<MoodEntry> _moods = [];
  JournalEntry? _selectedEntry;
  bool _isLoading = false;
  String? _error;
  
  JournalProvider({
    required JournalService journalService, 
    required String userId,
  })  : _journalService = journalService,
        _userId = userId {
    _loadInitialData();
  }
  
  // Getters
  List<JournalEntry> get entries => _entries;
  List<MoodEntry> get moods => _moods;
  JournalEntry? get selectedEntry => _selectedEntry;
  bool get isLoading => _isLoading;
  String? get error => _error;
  JournalService get journalService => _journalService;
  
  // Update user points and badges
  Future<void> updateUserPointsAndBadges() async {
    await _journalService.updateUserPoints(_userId);
  }
  
  // Clear error state
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  // Load initial data
  Future<void> _loadInitialData() async {
    await Future.wait([
      loadJournalEntries(),
      loadMoodEntries(),
    ]);
  }
  
  // Load journal entries
  Future<void> loadJournalEntries() async {
    _setLoading(true);
    
    try {
      final entries = await _journalService.getJournalEntries(_userId);
      entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      _entries = entries;
    } catch (e) {
      _setError(e is ApiException ? e.toString() : 'Failed to load journal entries');
    } finally {
      _setLoading(false);
    }
  }
  
  // Load mood entries
  Future<void> loadMoodEntries() async {
    _setLoading(true);
    
    try {
      final moods = await _journalService.getMoodEntries(_userId);
      moods.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      _moods = moods;
    } catch (e) {
      _setError(e is ApiException ? e.toString() : 'Failed to load mood entries');
    } finally {
      _setLoading(false);
    }
  }
  
  // Select an entry for viewing/editing
  void selectEntry(JournalEntry? entry) {
    _selectedEntry = entry;
    notifyListeners();
  }
  
  // Create a new journal entry
  Future<JournalEntry?> createJournalEntry(String title, String content, String? mood) async {
    _setLoading(true);
    _clearError();
    
    try {
      final newEntry = JournalEntry(
        id: '', // Will be assigned by the service
        title: title,
        content: content,
        timestamp: DateTime.now(),
        userId: _userId,
        mood: mood,
      );
      
      final createdEntry = await _journalService.createJournalEntry(newEntry);
      
      // Update local list
      _entries.insert(0, createdEntry);
      notifyListeners();
      
      return createdEntry;
    } catch (e) {
      _setError(e is ApiException ? e.toString() : 'Failed to create journal entry');
      return null;
    } finally {
      _setLoading(false);
    }
  }
  
  // Update an existing journal entry
  Future<bool> updateJournalEntry(
    String entryId,
    String title,
    String content,
    String? mood,
  ) async {
    _setLoading(true);
    _clearError();
    
    try {
      // Find existing entry
      final index = _entries.indexWhere((e) => e.id == entryId);
      if (index == -1) {
        _setError('Entry not found');
        return false;
      }
      
      final oldEntry = _entries[index];
      final updatedEntry = oldEntry.copyWith(
        title: title,
        content: content,
        mood: mood,
      );
      
      // Update entry
      final result = await _journalService.updateJournalEntry(updatedEntry);
      
      // Update local list
      _entries[index] = result;
      _selectedEntry = result;
      notifyListeners();
      
      return true;
    } catch (e) {
      _setError(e is ApiException ? e.toString() : 'Failed to update journal entry');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Delete a journal entry
  Future<bool> deleteJournalEntry(String entryId) async {
    _setLoading(true);
    _clearError();
    
    try {
      // First update the local list to ensure UI responsiveness
      final entryIndex = _entries.indexWhere((e) => e.id == entryId);
      JournalEntry? deletedEntry;
      
      // Store the entry temporarily in case we need to restore it
      if (entryIndex >= 0) {
        deletedEntry = _entries[entryIndex];
        _entries.removeAt(entryIndex);
      }
      
      // Clear selected entry if it's being deleted
      if (_selectedEntry?.id == entryId) {
        _selectedEntry = null;
      }
      
      // Notify UI immediately for better UX
      notifyListeners();
      
      try {
        // Then try to delete from the service
        await _journalService.deleteJournalEntry(entryId, _userId);
        return true;
      } catch (serviceError) {
        // If service call fails, restore the entry
        if (deletedEntry != null) {
          _entries.insert(entryIndex, deletedEntry);
          notifyListeners();
        }
        
        // Handle and propagate the error
        _setError(serviceError is ApiException ? serviceError.toString() : 'Failed to delete journal entry');
        return false;
      }
    } catch (e) {
      _setError('Failed to delete journal entry: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Record a mood
  Future<bool> recordMood(MoodType mood) async {
    _setLoading(true);
    _clearError();
    
    try {
      final moodEntry = MoodEntry(
        id: '', // Will be assigned by the service
        mood: mood,
        timestamp: DateTime.now(),
        userId: _userId,
      );
      
      final result = await _journalService.recordMood(moodEntry);
      
      // Update local list
      _moods.insert(0, result);
      notifyListeners();
      
      return true;
    } catch (e) {
      _setError(e is ApiException ? e.toString() : 'Failed to record mood');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Get moods for a specific date range
  List<MoodEntry> getMoodsForDateRange(DateTime start, DateTime end) {
    return _moods.where((mood) {
      final date = mood.timestamp;
      return date.isAfter(start) && date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }
  
  // Get entries for a specific date range
  List<JournalEntry> getEntriesForDateRange(DateTime start, DateTime end) {
    return _entries.where((entry) {
      final date = entry.timestamp;
      return date.isAfter(start) && date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }
  
  // Helper methods to update state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }
  
  void _clearError() {
    _error = null;
  }
}
