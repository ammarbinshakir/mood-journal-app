import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:mood_journal_app/providers/journal_provider.dart';
import 'package:mood_journal_app/screens/journal/add_entry_screen.dart';
import 'package:mood_journal_app/widgets/loading_overlay.dart';
import 'package:mood_journal_app/widgets/entry_analysis_widget.dart';

class EntryDetailScreen extends StatelessWidget {
  const EntryDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final journalProvider = Provider.of<JournalProvider>(context);
    final entry = journalProvider.selectedEntry;
    
    if (entry == null) {
      // Navigate back if no entry is selected
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
      });
      return const SizedBox.shrink();
    }
    
    // Get mood emoji
    String moodEmoji = '';
    if (entry.mood != null) {
      switch (entry.mood!.toLowerCase()) {
        case 'happy':
          moodEmoji = '😊';
          break;
        case 'neutral':
          moodEmoji = '😐';
          break;
        case 'sad':
          moodEmoji = '😔';
          break;
      }
    }
    
    return LoadingOverlay(
      isLoading: journalProvider.isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Journal Entry'),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEntryScreen(entryToEdit: entry),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Entry'),
                    content: const Text('Are you sure you want to delete this entry? This action cannot be undone.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Delete'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                    ],
                  ),
                );
                
                if (confirm == true) {
                  try {
                    final success = await journalProvider.deleteJournalEntry(entry.id);
                    
                    if (success && context.mounted) {
                      // Show success message and navigate back
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Journal entry deleted successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.pop(context);
                    } else if (context.mounted) {
                      // Show error message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(journalProvider.error ?? 'Failed to delete entry'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } catch (e) {
                    // Fallback error handling
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error deleting entry: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                entry.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              // Date and mood
              Row(
                children: [
                  Text(
                    DateFormat('MMM dd, yyyy - HH:mm').format(entry.timestamp),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  if (moodEmoji.isNotEmpty) ...[
                    const SizedBox(width: 12),
                    Text(
                      moodEmoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      entry.mood!.capitalizeFirst(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),
              
              // Content
              Text(
                entry.content,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              
              // AI Analysis
              EntryAnalysisWidget(entry: entry),
            ],
          ),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalizeFirst() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
