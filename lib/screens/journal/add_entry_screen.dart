import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mood_journal_app/models/journal_entry.dart';
import 'package:mood_journal_app/models/mood_entry.dart';
import 'package:mood_journal_app/providers/auth_provider.dart';
import 'package:mood_journal_app/providers/journal_provider.dart';
import 'package:mood_journal_app/widgets/loading_overlay.dart';

class AddEntryScreen extends StatefulWidget {
  final JournalEntry? entryToEdit;
  final String? promptText;

  const AddEntryScreen({
    super.key,
    this.entryToEdit,
    this.promptText,
  });

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String? _selectedMood;

  bool get isEditing => widget.entryToEdit != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _titleController.text = widget.entryToEdit!.title;
      _contentController.text = widget.entryToEdit!.content;
      _selectedMood = widget.entryToEdit!.mood;
    } else if (widget.promptText != null) {
      // If there's a writing prompt, add it to the content
      _contentController.text = "Prompt: ${widget.promptText}\n\nMy thoughts:\n";
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveEntry() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final journalProvider = Provider.of<JournalProvider>(context, listen: false);
      
      if (isEditing) {
        final success = await journalProvider.updateJournalEntry(
          widget.entryToEdit!.id,
          _titleController.text.trim(),
          _contentController.text.trim(),
          _selectedMood,
        );
        
        if (mounted) {
          if (success) {
            Navigator.pop(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(journalProvider.error ?? 'Failed to update entry'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        final entry = await journalProvider.createJournalEntry(
          _titleController.text.trim(),
          _contentController.text.trim(),
          _selectedMood,
        );
        
        if (mounted) {
          if (entry != null) {
            Navigator.pop(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(journalProvider.error ?? 'Failed to create entry'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final journalProvider = Provider.of<JournalProvider>(context);
    
    return LoadingOverlay(
      isLoading: journalProvider.isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEditing ? 'Edit Journal Entry' : 'New Journal Entry'),
          actions: [
            TextButton(
              onPressed: _saveEntry,
              child: const Text('Save'),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Title field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Mood selection
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'How are you feeling?',
                  border: OutlineInputBorder(),
                ),
                value: _selectedMood,
                items: [
                  DropdownMenuItem(
                    value: 'happy',
                    child: Row(
                      children: [
                        const Text('😊'),
                        const SizedBox(width: 8),
                        const Text('Happy'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'neutral',
                    child: Row(
                      children: [
                        const Text('😐'),
                        const SizedBox(width: 8),
                        const Text('Neutral'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'sad',
                    child: Row(
                      children: [
                        const Text('😔'),
                        const SizedBox(width: 8),
                        const Text('Sad'),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedMood = value;
                  });
                },
                hint: const Text('Select a mood'),
              ),
              const SizedBox(height: 16),
              
              // Content field
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Journal Entry',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 15,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some content';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
