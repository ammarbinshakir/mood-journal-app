import 'package:flutter/material.dart';
import 'package:mood_journal_app/models/journal_entry.dart';
import 'package:intl/intl.dart';

class JournalEntryCard extends StatelessWidget {
  final JournalEntry entry;
  final VoidCallback onTap;

  const JournalEntryCard({
    super.key,
    required this.entry,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Get emoji based on mood
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

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row with mood emoji
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      entry.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (moodEmoji.isNotEmpty)
                    Text(
                      moodEmoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Date
              Text(
                DateFormat('MMM dd, yyyy - HH:mm').format(entry.timestamp),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 8),
              
              // Content preview
              Text(
                entry.content,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
