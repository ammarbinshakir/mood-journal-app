import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mood_journal_app/models/mood_entry.dart';
import 'package:mood_journal_app/providers/auth_provider.dart';
import 'package:mood_journal_app/providers/journal_provider.dart';
import 'package:mood_journal_app/screens/journal/add_entry_screen.dart';
import 'package:mood_journal_app/screens/journal/entry_detail_screen.dart';
import 'package:mood_journal_app/screens/journal/mood_tracker_screen.dart';
import 'package:mood_journal_app/screens/journal/profile_screen.dart';
import 'package:mood_journal_app/widgets/journal_entry_card.dart';
import 'package:mood_journal_app/widgets/loading_overlay.dart';
import 'package:mood_journal_app/widgets/mood_selection_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<String> _screenTitles = ['Journal', 'Mood Tracker', 'Profile'];
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final journalProvider = Provider.of<JournalProvider>(context);
    
    final screens = [
      _buildJournalTab(journalProvider),
      const MoodTrackerScreen(),
      const ProfileScreen(),
    ];
    
    return LoadingOverlay(
      isLoading: journalProvider.isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_screenTitles[_selectedIndex]),
          actions: [
            if (_selectedIndex == 0)
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  // TODO: Implement search functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Search not implemented yet')),
                  );
                },
              ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );
                
                if (confirm == true) {
                  await authProvider.signOut();
                }
              },
            ),
          ],
        ),
        body: screens[_selectedIndex],
        floatingActionButton: _selectedIndex == 0
            ? FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddEntryScreen(),
                    ),
                  );
                },
                child: const Icon(Icons.add),
              )
            : null,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.book),
              label: 'Journal',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.mood),
              label: 'Mood',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildJournalTab(JournalProvider journalProvider) {
    final entries = journalProvider.entries;
    
    return Column(
      children: [
        // Mood selection widget
        MoodSelectionWidget(
          onMoodSelected: (mood) async {
            final success = await journalProvider.recordMood(mood);
            if (mounted && success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Mood recorded: ${mood.name}'),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(journalProvider.error ?? 'Failed to record mood'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
        
        // Journal entries list
        Expanded(
          child: entries.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.book,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No journal entries yet',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap the + button to create your first entry',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: journalProvider.loadJournalEntries,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return JournalEntryCard(
                        entry: entry,
                        onTap: () {
                          journalProvider.selectEntry(entry);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EntryDetailScreen(),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}
