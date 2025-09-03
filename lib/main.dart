import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mood_journal_app/screens/auth/login_screen.dart';
import 'package:mood_journal_app/screens/journal/home_screen.dart';
import 'package:mood_journal_app/services/auth_service.dart';
import 'package:mood_journal_app/services/api_service.dart';
import 'package:mood_journal_app/services/journal_service.dart';
import 'package:mood_journal_app/providers/auth_provider.dart';
import 'package:mood_journal_app/providers/journal_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // We're using mock data exclusively, no Firebase initialization needed
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth provider setup
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
        Provider<ApiService>(
          create: (_) => ApiService(
            baseUrl: 'https://api.example.com',
            useMockData: true,
          ),
        ),
        Provider<JournalService>(
          create: (context) => JournalService(
            apiService: Provider.of<ApiService>(context, listen: false),
            useMockData: true,
          ),
        ),
        ChangeNotifierProxyProvider<AuthService, AuthProvider>(
          create: (context) => AuthProvider(
            authService: Provider.of<AuthService>(context, listen: false),
          ),
          update: (_, authService, previous) => previous ?? AuthProvider(
            authService: authService,
          ),
        ),
        ChangeNotifierProxyProvider2<JournalService, AuthProvider, JournalProvider>(
          create: (context) => JournalProvider(
            journalService: Provider.of<JournalService>(context, listen: false),
            userId: Provider.of<AuthProvider>(context, listen: false).userId,
          ),
          update: (_, journalService, authProvider, previous) => previous ?? JournalProvider(
            journalService: journalService,
            userId: authProvider.userId,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Mood Journal',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        themeMode: ThemeMode.system,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return authProvider.isAuthenticated 
        ? const HomeScreen() 
        : const LoginScreen();
  }
}




