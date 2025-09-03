import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:mood_journal_app/models/mood_entry.dart';
import 'package:mood_journal_app/providers/journal_provider.dart';
import 'package:mood_journal_app/widgets/loading_overlay.dart';

class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen> {
  // Date range for filtering (default to last 7 days)
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 6));
  DateTime _endDate = DateTime.now();
  
  @override
  Widget build(BuildContext context) {
    final journalProvider = Provider.of<JournalProvider>(context);
    
    // Get moods for the selected date range
    final moodEntries = journalProvider.getMoodsForDateRange(_startDate, _endDate);
    
    return LoadingOverlay(
      isLoading: journalProvider.isLoading,
      child: RefreshIndicator(
        onRefresh: journalProvider.loadMoodEntries,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date range selector
              _buildDateRangeSelector(context),
              const SizedBox(height: 24),
              
              // Mood stats
              _buildMoodStats(moodEntries),
              const SizedBox(height: 24),
              
              // Mood history
              Expanded(
                child: _buildMoodHistory(moodEntries),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildDateRangeSelector(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date Range',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _startDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null && picked != _startDate) {
                        setState(() {
                          _startDate = picked;
                        });
                      }
                    },
                    child: Text(DateFormat('MMM dd, yyyy').format(_startDate)),
                  ),
                ),
                const SizedBox(width: 16),
                const Text('to'),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _endDate,
                        firstDate: _startDate,
                        lastDate: DateTime.now(),
                      );
                      if (picked != null && picked != _endDate) {
                        setState(() {
                          _endDate = picked;
                        });
                      }
                    },
                    child: Text(DateFormat('MMM dd, yyyy').format(_endDate)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTimeRangeButton('Last 7 Days', () {
                  setState(() {
                    _endDate = DateTime.now();
                    _startDate = _endDate.subtract(const Duration(days: 6));
                  });
                }),
                _buildTimeRangeButton('Last 30 Days', () {
                  setState(() {
                    _endDate = DateTime.now();
                    _startDate = _endDate.subtract(const Duration(days: 29));
                  });
                }),
                _buildTimeRangeButton('All Time', () {
                  setState(() {
                    _endDate = DateTime.now();
                    _startDate = DateTime(2020);
                  });
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTimeRangeButton(String text, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(text),
    );
  }
  
  Widget _buildMoodStats(List<MoodEntry> entries) {
    // Count moods
    int happy = 0;
    int neutral = 0;
    int sad = 0;
    
    for (final entry in entries) {
      switch (entry.mood) {
        case MoodType.happy:
          happy++;
          break;
        case MoodType.neutral:
          neutral++;
          break;
        case MoodType.sad:
          sad++;
          break;
      }
    }
    
    final total = entries.isNotEmpty ? entries.length : 1;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mood Summary',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMoodStat('😊', 'Happy', happy, total, Colors.green),
                _buildMoodStat('😐', 'Neutral', neutral, total, Colors.amber),
                _buildMoodStat('😔', 'Sad', sad, total, Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMoodStat(
    String emoji,
    String label,
    int count,
    int total,
    Color color,
  ) {
    final percentage = total > 0 ? (count / total * 100).round() : 0;
    
    return Expanded(
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          Text(
            '$count ($percentage%)',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: total > 0 ? count / total : 0,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMoodHistory(List<MoodEntry> entries) {
    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.mood_bad,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No mood entries found',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Log your mood on the Journal tab',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }
    
    return ListView(
      children: [
        Text(
          'Mood History',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...entries.map((entry) => _buildMoodEntryItem(entry)).toList(),
      ],
    );
  }
  
  Widget _buildMoodEntryItem(MoodEntry entry) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Text(
          entry.mood.emoji,
          style: const TextStyle(fontSize: 24),
        ),
        title: Text(entry.mood.name),
        subtitle: Text(DateFormat('MMM dd, yyyy - HH:mm').format(entry.timestamp)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // View mood details (could link to journal entries from same day)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mood details feature coming soon!'),
            ),
          );
        },
      ),
    );
  }
}
