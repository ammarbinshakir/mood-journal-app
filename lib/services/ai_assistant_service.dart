import 'package:mood_journal_app/models/journal_entry.dart';
import 'package:mood_journal_app/models/mood_entry.dart';

class AIAssistantService {
  
  // Minimum days of data needed for meaningful insights
  final int _minEntriesForInsights = 3;
  
  // Analyze journal entries and mood data to generate insights
  Future<List<String>> generateInsights({
    required List<JournalEntry> journalEntries,
    required List<MoodEntry> moodEntries,
  }) async {
    if (journalEntries.length < _minEntriesForInsights || 
        moodEntries.length < _minEntriesForInsights) {
      return [
        "Keep adding entries to get personalized insights about your mood patterns."
      ];
    }
    
    final List<String> insights = [];
    
    // Pattern 1: Mood trends
    final moodTrendInsight = _analyzeMoodTrends(moodEntries);
    if (moodTrendInsight != null) {
      insights.add(moodTrendInsight);
    }
    
    // Pattern 2: Content sentiment correlation with mood
    final sentimentInsight = _analyzeSentimentMoodCorrelation(journalEntries);
    if (sentimentInsight != null) {
      insights.add(sentimentInsight);
    }
    
    // Pattern 3: Day of week patterns
    final dayOfWeekInsight = _analyzeDayOfWeekPatterns(moodEntries);
    if (dayOfWeekInsight != null) {
      insights.add(dayOfWeekInsight);
    }
    
    // If no specific insights, provide a general one
    if (insights.isEmpty) {
      insights.add(
        "I notice you've been journaling consistently. This practice can help improve self-awareness."
      );
    }
    
    return insights;
  }
  
  // Generate personalized writing prompts based on recent mood and journal patterns
  Future<String> generateWritingPrompt({
    required List<JournalEntry> recentEntries,
    required List<MoodEntry> recentMoods,
  }) async {
    // Get user's current dominant mood
    final currentMood = recentMoods.isNotEmpty ? recentMoods.first.mood : null;
    
    // Check if we should use a mood-based prompt
    if (currentMood != null) {
      // Happy mood prompts
      if (currentMood == MoodType.happy) {
        final happyPrompts = [
          "What's something that brought you joy today? How can you bring more of that into your life?",
          "Describe something you're grateful for today and why it matters to you.",
          "What accomplishment, no matter how small, are you proud of today?",
          "Who made a positive difference in your life recently? What did they do?",
        ];
        return _getRandomPrompt(happyPrompts);
      }
      
      // Sad mood prompts
      else if (currentMood == MoodType.sad) {
        final sadPrompts = [
          "What's been challenging recently? What's one small step you could take to address it?",
          "What's one gentle thing you could do for yourself today when you're feeling down?",
          "Is there someone you could reach out to for support? How might they help?",
          "What has helped you feel better in the past when you've felt this way?",
        ];
        return _getRandomPrompt(sadPrompts);
      }
      
      // Neutral mood prompts
      else {
        final neutralPrompts = [
          "What's on your mind today that you'd like to explore further?",
          "How would you describe your energy levels today? What might be affecting them?",
          "What's something you're looking forward to? How does thinking about it make you feel?",
          "If you could change one thing about today, what would it be and why?",
        ];
        return _getRandomPrompt(neutralPrompts);
      }
    }
    
    // Default prompts if no mood data
    final defaultPrompts = [
      "What's been on your mind lately that you'd like to write about?",
      "How are you feeling right now? Take a moment to check in with yourself.",
      "What's one goal you're working towards? What steps can you take to move closer to it?",
      "Reflect on a recent interaction that had an impact on you. What made it significant?",
    ];
    
    return _getRandomPrompt(defaultPrompts);
  }
  
  // Generate personalized mood-improvement suggestions based on user's mood history
  Future<List<String>> suggestMoodImprovementActivities(MoodType currentMood) async {
    // Get historical data on what has worked for user (mock implementation)
    final activities = <String>[];
    
    // For sad mood
    if (currentMood == MoodType.sad) {
      activities.addAll([
        "Take a 10-minute walk outside",
        "Call or message a friend",
        "Listen to uplifting music",
        "Practice deep breathing for 5 minutes",
        "Write down three things you're grateful for"
      ]);
    }
    // For neutral mood
    else if (currentMood == MoodType.neutral) {
      activities.addAll([
        "Try a new hobby or activity",
        "Organize a small area of your home",
        "Read a few pages of an inspiring book",
        "Plan something to look forward to",
        "Do a quick workout or stretch session"
      ]);
    }
    // For happy mood
    else {
      activities.addAll([
        "Share your positive feeling with someone",
        "Note what contributed to this feeling",
        "Engage in a creative activity",
        "Express gratitude to someone",
        "Set a goal while you have positive energy"
      ]);
    }
    
    // Return 3 random suggestions
    activities.shuffle();
    return activities.take(3).toList();
  }
  
  // Private helper methods
  String? _analyzeMoodTrends(List<MoodEntry> moodEntries) {
    if (moodEntries.length < 5) return null;
    
    // Count moods
    int happy = 0, sad = 0, neutral = 0;
    for (final entry in moodEntries.take(7)) {
      if (entry.mood == MoodType.happy) happy++;
      else if (entry.mood == MoodType.sad) sad++;
      else if (entry.mood == MoodType.neutral) neutral++;
    }
    
    // Generate insight based on dominant mood
    if (happy > sad && happy > neutral) {
      return "I notice you've been feeling happy often this week. Great job maintaining positive emotions!";
    } else if (sad > happy && sad > neutral) {
      return "You've recorded several sad moods recently. Remember to practice self-care and consider what might help lift your spirits.";
    } else if (neutral > happy && neutral > sad) {
      return "You've been feeling mostly neutral lately. Consider trying new activities that might bring more joy into your day.";
    } else if (happy == sad && happy > neutral) {
      return "Your mood has been fluctuating between happy and sad. Journaling about these shifts might help identify patterns.";
    }
    
    return null;
  }
  
  String? _analyzeSentimentMoodCorrelation(List<JournalEntry> entries) {
    if (entries.length < 5) return null;
    
    // This is a simple mock implementation
    // In a real app, you'd use proper sentiment analysis
    final keywords = {
      'positive': ['happy', 'joy', 'excited', 'grateful', 'thankful', 'love', 'enjoyed'],
      'negative': ['sad', 'angry', 'anxious', 'stressed', 'worried', 'tired', 'frustrated']
    };
    
    int positiveEntries = 0;
    int negativeEntries = 0;
    
    for (final entry in entries.take(5)) {
      final content = entry.content.toLowerCase();
      bool hasPositive = keywords['positive']!.any((word) => content.contains(word));
      bool hasNegative = keywords['negative']!.any((word) => content.contains(word));
      
      if (hasPositive && !hasNegative) positiveEntries++;
      if (hasNegative && !hasPositive) negativeEntries++;
    }
    
    if (positiveEntries > negativeEntries * 2) {
      return "You tend to use a lot of positive words in your journal. This suggests you're focusing on the good things in life.";
    } else if (negativeEntries > positiveEntries * 2) {
      return "I notice you often use words that express challenging emotions. Writing can be a healthy way to process these feelings.";
    }
    
    return null;
  }
  
  String? _analyzeDayOfWeekPatterns(List<MoodEntry> entries) {
    if (entries.length < 7) return null;
    
    // Count moods by day of week
    final weekdayMoods = List.generate(7, (_) => {'happy': 0, 'neutral': 0, 'sad': 0});
    
    for (final entry in entries) {
      final dayOfWeek = entry.timestamp.weekday - 1; // 0 = Monday, 6 = Sunday
      final mood = entry.mood.name.toLowerCase();
      weekdayMoods[dayOfWeek][mood] = (weekdayMoods[dayOfWeek][mood] ?? 0) + 1;
    }
    
    // Find the happiest day
    int happiestDay = -1;
    int maxHappy = -1;
    
    for (int i = 0; i < 7; i++) {
      if ((weekdayMoods[i]['happy'] ?? 0) > maxHappy) {
        maxHappy = weekdayMoods[i]['happy'] ?? 0;
        happiestDay = i;
      }
    }
    
    if (maxHappy >= 2 && happiestDay >= 0) {
      final days = ['Mondays', 'Tuesdays', 'Wednesdays', 'Thursdays', 'Fridays', 'Saturdays', 'Sundays'];
      return "You seem to feel happiest on ${days[happiestDay]}. What do you typically do that day that might contribute to this?";
    }
    
    return null;
  }
  
  String _getRandomPrompt(List<String> prompts) {
    prompts.shuffle();
    return prompts.first;
  }
}
