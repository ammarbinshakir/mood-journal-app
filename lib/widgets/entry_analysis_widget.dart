import 'package:flutter/material.dart';
import 'package:mood_journal_app/models/journal_entry.dart';
import 'package:mood_journal_app/services/ai_assistant_service.dart';

class EntryAnalysisWidget extends StatefulWidget {
  final JournalEntry entry;
  
  const EntryAnalysisWidget({
    super.key,
    required this.entry,
  });

  @override
  State<EntryAnalysisWidget> createState() => _EntryAnalysisWidgetState();
}

class _EntryAnalysisWidgetState extends State<EntryAnalysisWidget> {
  final AIAssistantService _aiService = AIAssistantService();
  bool _expanded = false;
  bool _loading = false;
  String? _analysis;
  
  void _analyzeEntry() async {
    if (_analysis != null) {
      setState(() {
        _expanded = !_expanded;
      });
      return;
    }
    
    setState(() {
      _loading = true;
      _expanded = true;
    });
    
    try {
      // Simple sentiment analysis based on content
      final String content = widget.entry.content.toLowerCase();
      
      // Keywords to look for (this is a simplified version of what the real AI service would do)
      final positiveWords = ['happy', 'joy', 'excited', 'grateful', 'thankful', 'love', 'enjoyed'];
      final negativeWords = ['sad', 'angry', 'anxious', 'stressed', 'worried', 'tired', 'frustrated'];
      
      int positiveCount = 0;
      int negativeCount = 0;
      
      for (final word in positiveWords) {
        if (content.contains(word)) positiveCount++;
      }
      
      for (final word in negativeWords) {
        if (content.contains(word)) negativeCount++;
      }
      
      // Generate analysis text based on counts
      String analysis;
      if (positiveCount > negativeCount) {
        analysis = "This entry contains positive language. You seem to be in a good mood when writing this.";
      } else if (negativeCount > positiveCount) {
        analysis = "This entry has some negative emotions. Writing about challenges can help process them.";
      } else if (positiveCount > 0 && negativeCount > 0) {
        analysis = "Your entry has mixed emotions. Reflecting on both positive and negative aspects shows balanced thinking.";
      } else {
        analysis = "This entry is mostly neutral in tone. Consider adding more emotional context to track your feelings.";
      }
      
      // Add length analysis
      if (widget.entry.content.length > 200) {
        analysis += " You wrote quite a detailed entry, which is great for self-reflection.";
      } else {
        analysis += " Consider adding more detail in future entries to help with reflection later.";
      }
      
      setState(() {
        _analysis = analysis;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _analysis = "Unable to analyze this entry at the moment.";
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.psychology),
            title: const Text('AI Assistant Analysis'),
            subtitle: _expanded 
                ? null 
                : const Text('Tap to see what your writing reveals about your mood'),
            trailing: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
            onTap: _analyzeEntry,
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : Text(_analysis ?? 'Analyzing...'),
            ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.info_outline),
                    label: const Text('How does this work?'),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('About AI Analysis'),
                          content: const SingleChildScrollView(
                            child: Text(
                              'The AI Assistant analyzes your journal entries to identify patterns in your '
                              'writing and mood. It looks at the words you use, the length of your entries, '
                              'and other factors to provide insights.\n\n'
                              'This is a simple analysis meant to help you reflect on your writing and mood. '
                              'It\'s not a substitute for professional advice.'
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
