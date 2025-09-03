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
      // Just show a placeholder if no entry is selected
      return Scaffold(
        appBar: AppBar(title: const Text('Entry Details')),
        body: const Center(child: Text('No entry selected')),
      );
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
                    // Delete the entry
                    final success = await journalProvider.deleteJournalEntry(entry.id);
                    
                    // Only proceed if context is still mounted
                    if (!context.mounted) return;
                    
                    if (success) {
                      // Show success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Journal entry deleted successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      
                      // Pop only once after successful deletion
                      Navigator.of(context).pop();
                    } else {
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
