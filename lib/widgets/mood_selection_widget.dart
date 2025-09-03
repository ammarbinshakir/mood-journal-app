import 'package:flutter/material.dart';
import 'package:mood_journal_app/models/mood_entry.dart';

class MoodSelectionWidget extends StatelessWidget {
  final Function(MoodType) onMoodSelected;

  const MoodSelectionWidget({
    super.key,
    required this.onMoodSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            spreadRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'How are you feeling today?',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMoodButton(
                context,
                MoodType.happy,
                MoodType.happy.emoji,
                'Happy',
              ),
              _buildMoodButton(
                context,
                MoodType.neutral,
                MoodType.neutral.emoji,
                'Neutral',
              ),
              _buildMoodButton(
                context,
                MoodType.sad,
                MoodType.sad.emoji,
                'Sad',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMoodButton(
    BuildContext context,
    MoodType mood,
    String emoji,
    String label,
  ) {
    return InkWell(
      onTap: () => onMoodSelected(mood),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 40),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
