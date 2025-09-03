import 'package:flutter/foundation.dart';
import 'package:mood_journal_app/models/user_model.dart';
import 'package:mood_journal_app/services/auth_service.dart';
import 'package:mood_journal_app/utils/exceptions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  
  // User state
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;

  // Mock user ID for development
  final String _mockUserId = 'mock-user-id';

  AuthProvider({required AuthService authService}) : _authService = authService {
    _checkAuthStatus();
  }

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;
  String get userId => _currentUser?.id ?? _mockUserId;
  
  // Reset error state
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Check if user is already authenticated
  Future<void> _checkAuthStatus() async {
    _setLoading(true);
    
    try {
      // Check if we have mock user data in shared preferences
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      
      if (isLoggedIn) {
                  // Get mock user data
          // Safely handle badges which might be stored as a string instead of a list
          List<String> badges = [];
          try {
            final storedBadges = prefs.getStringList('user_badges_$_mockUserId');
            if (storedBadges != null) {
              badges = storedBadges;
            }
          } catch (e) {
            // In case of error, use an empty list
            badges = [];
          }
          
          _currentUser = UserModel(
            id: _mockUserId,
            email: prefs.getString('user_email') ?? 'test@example.com',
            points: prefs.getInt('user_points_$_mockUserId') ?? 0,
            badges: badges,
          );
        _isAuthenticated = true;
      } else {
        // Check if we have a current user
        final userId = _authService.currentUser;
        if (userId != null) {
          // Get user data
          final userData = await _authService.getUserData(userId);
          if (userData != null) {
            _currentUser = userData;
            _isAuthenticated = true;
          }
        }
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Sign in with email and password
  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _clearError();
    
    try {
      // Perform sign in
      final success = await _authService.signInWithEmailAndPassword(email, password);
      
      if (success) {
        // Save user data in shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_logged_in', true);
        await prefs.setString('user_email', email);
        
        // Get user ID from auth service
        final userId = _authService.currentUser ?? _mockUserId;
        
        // Set user data
        // Safely handle badges which might be stored as a string instead of a list
        List<String> badges = [];
        try {
          final storedBadges = prefs.getStringList('user_badges_$userId');
          if (storedBadges != null) {
            badges = storedBadges;
          }
        } catch (e) {
          // In case of error, use an empty list
          badges = [];
        }
        
        _currentUser = UserModel(
          id: userId,
          email: email,
          points: prefs.getInt('user_points_$userId') ?? 0,
          badges: badges,
        );
        _isAuthenticated = true;
      }
      
      return true;
    } catch (e) {
      _setError(e is AuthException ? e.message : e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Register with email and password
  Future<bool> register(String email, String password) async {
    _setLoading(true);
    _clearError();
    
    try {
      // Register with mock service
      final success = await _authService.registerWithEmailAndPassword(email, password);
      
      if (success) {
        // Save user data in shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_logged_in', true);
        await prefs.setString('user_email', email);
        
        // Get user ID from auth service
        final userId = _authService.currentUser ?? _mockUserId;
        
        // Set user data with empty badges list for new users
        _currentUser = UserModel(
          id: userId,
          email: email,
          points: 0,
          badges: [],
        );
        _isAuthenticated = true;
      }
      
      return true;
    } catch (e) {
      _setError(e is AuthException ? e.message : e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign out
  Future<void> signOut() async {
    _setLoading(true);
    
    try {
      // Sign out from auth service
      await _authService.signOut();
      
      // Clear shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', false);
      
      _currentUser = null;
      _isAuthenticated = false;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _authService.resetPassword(email);
      return true;
    } catch (e) {
      _setError(e is AuthException ? e.message : e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update user points and badges
  Future<void> updateUserPoints(int points, List<String> badges) async {
    if (_currentUser == null) return;
    
    try {
      final updatedUser = _currentUser!.copyWith(
        points: points,
        badges: badges,
      );
      
      if (_authService.useMockData) {
        // Update local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('user_points_${_currentUser!.id}', points);
        await prefs.setStringList('user_badges_${_currentUser!.id}', badges);
      } else {
        // Update Firestore
        await _authService.updateUserData(updatedUser);
      }
      
      _currentUser = updatedUser;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Helper methods to update state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
