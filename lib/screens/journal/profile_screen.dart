import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mood_journal_app/models/badge.dart' as app_badge;
import 'package:mood_journal_app/providers/auth_provider.dart';
import 'package:mood_journal_app/providers/journal_provider.dart';
import 'package:mood_journal_app/widgets/loading_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<String> _userBadges = [];
  int _userPoints = 0;
  int _totalEntries = 0;
  int _totalMoods = 0;
  bool _isLoading = false;
  
  // Get predefined badges from the model
  List<app_badge.Badge> get predefinedBadges => app_badge.predefinedBadges;
  
  @override
  void initState() {
    super.initState();
    _loadUserStats();
  }
  
  Future<void> _loadUserStats() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final journalProvider = Provider.of<JournalProvider>(context, listen: false);
      
      final prefs = await SharedPreferences.getInstance();
      final badges = prefs.getStringList('user_badges_${authProvider.userId}') ?? [];
      final points = prefs.getInt('user_points_${authProvider.userId}') ?? 0;
      
      setState(() {
        _userBadges = badges;
        _userPoints = points;
        _totalEntries = journalProvider.entries.length;
        _totalMoods = journalProvider.moods.length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return LoadingOverlay(
      isLoading: _isLoading || authProvider.isLoading,
      child: RefreshIndicator(
        onRefresh: _loadUserStats,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // User profile section
            _buildUserProfileSection(),
            const SizedBox(height: 24),
            
            // Stats section
            _buildStatsSection(),
            const SizedBox(height: 24),
            
            // Badges section
            _buildBadgesSection(),
            const SizedBox(height: 24),
            
            // Settings section
            _buildSettingsSection(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildUserProfileSection() {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                user?.email != null && user!.email.isNotEmpty ? user.email[0].toUpperCase() : 'U',
                style: const TextStyle(
                  fontSize: 40,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // User name/email
            Text(
              user?.email ?? 'User',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            
            // Points
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  '$_userPoints points',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            _buildStatItem(Icons.book, 'Journal Entries', _totalEntries.toString()),
            const Divider(),
            _buildStatItem(Icons.mood, 'Mood Records', _totalMoods.toString()),
            const Divider(),
            _buildStatItem(Icons.emoji_events, 'Badges Earned', _userBadges.length.toString()),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBadgesSection() {
    // Get badge details for user badges
    final userBadgeDetails = predefinedBadges
        .where((badge) => _userBadges.contains(badge.id))
        .toList();
    
    // Get locked badges
    final lockedBadges = predefinedBadges
        .where((badge) => !_userBadges.contains(badge.id))
        .toList();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Badges',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            if (userBadgeDetails.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No badges earned yet. Keep using the app to earn badges!',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: userBadgeDetails
                    .map((badge) => _buildBadgeItem(badge, false))
                    .toList(),
              ),
            
            if (lockedBadges.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Badges to Earn',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: lockedBadges
                    .map((badge) => _buildBadgeItem(badge, true))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildBadgeItem(app_badge.Badge badge, bool locked) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Text(badge.icon),
                const SizedBox(width: 8),
                Text(badge.name),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(badge.description),
                const SizedBox(height: 8),
                Text('Required Points: ${badge.requiredPoints}'),
                const SizedBox(height: 16),
                Text(
                  locked ? 'Keep going to earn this badge!' : 'Badge earned!',
                  style: TextStyle(
                    color: locked ? Colors.orange : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: locked
                  ? Colors.grey.shade300
                  : Theme.of(context).colorScheme.primaryContainer,
              shape: BoxShape.circle,
              border: Border.all(
                color: locked
                    ? Colors.grey
                    : Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                badge.icon,
                style: TextStyle(
                  fontSize: 32,
                  color: locked ? Colors.grey : null,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            badge.name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: locked ? Colors.grey : null,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildSettingsSection() {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.nightlight_round),
            title: const Text('Dark Mode'),
            trailing: Switch(
              value: Theme.of(context).brightness == Brightness.dark,
              onChanged: (value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Theme switching not implemented yet'),
                  ),
                );
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            trailing: Switch(
              value: false,
              onChanged: (value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notifications not implemented yet'),
                  ),
                );
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Support'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Help & Support not implemented yet'),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('About MoodJournal'),
                  content: const Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Version: 1.0.0'),
                      SizedBox(height: 8),
                      Text('A Flutter app for tracking moods and journal entries.'),
                      SizedBox(height: 16),
                      Text('Created for Technical Assessment'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
