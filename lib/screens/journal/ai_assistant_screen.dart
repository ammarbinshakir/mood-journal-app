import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mood_journal_app/models/journal_entry.dart';
import 'package:mood_journal_app/models/mood_entry.dart';
import 'package:mood_journal_app/providers/auth_provider.dart';
import 'package:mood_journal_app/providers/journal_provider.dart';
import 'package:mood_journal_app/services/ai_assistant_service.dart';
import 'package:mood_journal_app/screens/journal/add_entry_screen.dart';
import 'package:mood_journal_app/widgets/loading_overlay.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final AIAssistantService _aiService = AIAssistantService();
  bool _isLoading = false;
  List<String> _insights = [];
  String _writingPrompt = '';
  List<String> _suggestions = [];
  
  @override
  void initState() {
    super.initState();
    _loadAIData();
  }

  Future<void> _loadAIData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final journalProvider = Provider.of<JournalProvider>(context, listen: false);
      
      // Get journal entries and mood entries
      final journalEntries = journalProvider.entries;
      final moodEntries = journalProvider.moods;
      
      // Generate insights
      final insights = await _aiService.generateInsights(
        journalEntries: journalEntries,
        moodEntries: moodEntries,
      );
      
      // Generate writing prompt
      final writingPrompt = await _aiService.generateWritingPrompt(
        recentEntries: journalEntries.take(5).toList(),
        recentMoods: moodEntries.take(5).toList(),
      );
      
      // Get mood improvement suggestions based on most recent mood
      final currentMood = moodEntries.isNotEmpty ? moodEntries.first.mood : MoodType.neutral;
      final suggestions = await _aiService.suggestMoodImprovementActivities(currentMood);
      
      setState(() {
        _insights = insights;
        _writingPrompt = writingPrompt;
        _suggestions = suggestions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _insights = ["I'm having trouble analyzing your journal right now. Please try again later."];
        _writingPrompt = "What's on your mind today?";
        _suggestions = ["Take a deep breath", "Go for a walk", "Listen to calming music"];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: RefreshIndicator(
        onRefresh: _loadAIData,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('AI Journal Assistant'),
          ),
          body: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Assistant profile section
                  _buildAssistantProfile(),
                  const SizedBox(height: 24),
                  
                  // Insights section
                  _buildInsightsSection(),
                  const SizedBox(height: 24),
                  
                  // Writing prompt section
                  _buildWritingPromptSection(),
                  const SizedBox(height: 24),
                  
                  // Mood improvement suggestions
                  _buildSuggestionsSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildAssistantProfile() {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: const Icon(
            Icons.psychology_alt,
            size: 30,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Journal Assistant',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                'Analyzing your journal entries to provide personalized insights',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildInsightsSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb_outline),
                const SizedBox(width: 8),
                Text(
                  'Mood Insights',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._insights.map((insight) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.arrow_right, size: 20),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(insight),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildWritingPromptSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.edit_note),
                const SizedBox(width: 8),
                Text(
                  'Writing Prompt',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(_writingPrompt),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEntryScreen(
                      promptText: _writingPrompt,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.create),
              label: const Text('Write about this'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSuggestionsSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.spa_outlined),
                const SizedBox(width: 8),
                Text(
                  'Suggestions for Your Mood',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._suggestions.map((suggestion) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_outline, size: 20),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(suggestion),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }
}
