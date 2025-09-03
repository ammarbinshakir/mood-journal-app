import 'package:mood_journal_app/models/user_model.dart';
import 'package:mood_journal_app/utils/exceptions.dart';
import 'dart:async';

class AuthService {
  // Using mock data only - no Firebase
  final bool useMockData = true;
  
  // Mock user ID
  String? _mockUserId;
  
  // Get current user ID (mock)
  String? get currentUser => _mockUserId;
  
  // Auth state changes stream (mock)
  final _authController = StreamController<String?>.broadcast();
  Stream<String?> get authStateChanges => _authController.stream;

  // Sign in with email and password
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      // Simulate sign in delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Simple validation
      if (email.isEmpty || !email.contains('@') || password.isEmpty) {
        throw AuthException('Invalid email or password');
      }
      
      // Mock successful login with test@example.com and password123
      if (email == 'test@example.com' && password == 'password123') {
        _mockUserId = 'mock-user-id';
        _authController.add(_mockUserId);
        return true;
      } else {
        throw AuthException('Invalid credentials');
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(e.toString());
    }
  }

  // Register with email and password
  Future<bool> registerWithEmailAndPassword(String email, String password) async {
    try {
      // Simulate registration delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Simple validation
      if (email.isEmpty || !email.contains('@') || password.length < 6) {
        throw AuthException('Invalid email or password too short (min 6 chars)');
      }
      
      // Create mock user ID and save it
      _mockUserId = 'mock-${DateTime.now().millisecondsSinceEpoch}';
      
      // Create mock user in local storage
      await createUserDocument(email, uid: _mockUserId);
      
      // Notify listeners
      _authController.add(_mockUserId);
      
      return true;
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(e.toString());
    }
  }
  
  // Create mock user document
  Future<void> createUserDocument(String email, {String? uid}) async {
    try {
      final userId = uid ?? 'mock-${DateTime.now().millisecondsSinceEpoch}';
      
      // Mock data - no actual storage, just simulating the operation
      // In a real implementation, this would save to a local database or preferences
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Return success
      return;
    } catch (e) {
      throw AuthException('Failed to create user profile');
    }
  }

  // Sign out
  Future<void> signOut() async {
    _mockUserId = null;
    _authController.add(null);
  }

  // Password reset
  Future<void> resetPassword(String email) async {
    try {
      // Simple validation
      if (email.isEmpty || !email.contains('@')) {
        throw AuthException('Invalid email address');
      }
      
      // Just simulate a delay for the mock implementation
      await Future.delayed(const Duration(seconds: 1));
      
      // Success (no actual email is sent)
      return;
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(e.toString());
    }
  }

  // Get user data
  Future<UserModel?> getUserData(String userId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Return mock user data
    return UserModel(
      id: userId,
      email: 'test@example.com',
      points: 10,
      badges: ['beginner_journal'],
    );
  }

  // Update user data
  Future<void> updateUserData(UserModel user) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    // In a real app, this would save to local storage or a database
    return;
  }
  
  // Close streams when service is disposed
  void dispose() {
    _authController.close();
  }
}
