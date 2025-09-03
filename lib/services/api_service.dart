import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:mood_journal_app/utils/exceptions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl;
  final http.Client _client;
  final FlutterSecureStorage _secureStorage;

  // For offline cache
  final bool enableOfflineMode;

  // Use mock API for development
  final bool useMockData;

  // Maximum retry attempts
  final int maxRetries;
  
  // Timeout duration
  final Duration timeout;

  ApiService({
    required this.baseUrl,
    http.Client? client,
    FlutterSecureStorage? secureStorage,
    this.enableOfflineMode = true,
    this.useMockData = true,
    this.maxRetries = 3,
    this.timeout = const Duration(seconds: 10),
  })  : _client = client ?? http.Client(),
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  // Get authentication token
  Future<String?> getToken() async {
    try {
      return await _secureStorage.read(key: 'auth_token');
    } catch (e) {
      throw StorageException('Failed to get authentication token');
    }
  }

  // Save authentication token
  Future<void> saveToken(String token) async {
    try {
      await _secureStorage.write(key: 'auth_token', value: token);
    } catch (e) {
      throw StorageException('Failed to save authentication token');
    }
  }

  // Delete authentication token
  Future<void> deleteToken() async {
    try {
      await _secureStorage.delete(key: 'auth_token');
    } catch (e) {
      throw StorageException('Failed to delete authentication token');
    }
  }

  // Generic GET request with retry logic and offline support
  Future<Map<String, dynamic>> get(String endpoint) async {
    if (!await _isConnected() && enableOfflineMode) {
      return await _getOfflineData(endpoint);
    }

    int attempts = 0;
    Exception? lastException;

    while (attempts < maxRetries) {
      try {
        final token = await getToken();
        final response = await _client
            .get(
              Uri.parse('$baseUrl/$endpoint'),
              headers: _getHeaders(token),
            )
            .timeout(timeout);

        final responseData = _handleResponse(response);
        
        if (enableOfflineMode) {
          await _saveOfflineData(endpoint, responseData);
        }
        
        return responseData;
      } on TimeoutException {
        lastException = ApiException('Request timed out');
        attempts++;
      } on SocketException {
        lastException = NetworkException('No internet connection');
        if (enableOfflineMode) {
          return await _getOfflineData(endpoint);
        }
        attempts++;
      } on http.ClientException {
        lastException = ApiException('HTTP request failed');
        attempts++;
      } catch (e) {
        lastException = ApiException('Unknown error occurred: ${e.toString()}');
        attempts++;
      }

      // Wait before retrying
      if (attempts < maxRetries) {
        await Future.delayed(Duration(milliseconds: 500 * attempts));
      }
    }

    if (enableOfflineMode) {
      return await _getOfflineData(endpoint);
    }

    throw lastException ?? ApiException('Request failed after $maxRetries attempts');
  }

  // Generic POST request with retry logic
  Future<Map<String, dynamic>> post(
    String endpoint, 
    Map<String, dynamic> data,
  ) async {
    int attempts = 0;
    Exception? lastException;

    while (attempts < maxRetries) {
      try {
        final token = await getToken();
        final response = await _client
            .post(
              Uri.parse('$baseUrl/$endpoint'),
              headers: _getHeaders(token),
              body: json.encode(data),
            )
            .timeout(timeout);

        return _handleResponse(response);
      } on TimeoutException {
        lastException = ApiException('Request timed out');
        attempts++;
      } on SocketException {
        lastException = NetworkException('No internet connection');
        attempts++;
      } on http.ClientException {
        lastException = ApiException('HTTP request failed');
        attempts++;
      } catch (e) {
        lastException = ApiException('Unknown error occurred: ${e.toString()}');
        attempts++;
      }

      // Wait before retrying
      if (attempts < maxRetries) {
        await Future.delayed(Duration(milliseconds: 500 * attempts));
      }
    }

    throw lastException ?? ApiException('Request failed after $maxRetries attempts');
  }

  // Generic PUT request with retry logic
  Future<Map<String, dynamic>> put(
    String endpoint, 
    Map<String, dynamic> data,
  ) async {
    int attempts = 0;
    Exception? lastException;

    while (attempts < maxRetries) {
      try {
        final token = await getToken();
        final response = await _client
            .put(
              Uri.parse('$baseUrl/$endpoint'),
              headers: _getHeaders(token),
              body: json.encode(data),
            )
            .timeout(timeout);

        return _handleResponse(response);
      } on TimeoutException {
        lastException = ApiException('Request timed out');
        attempts++;
      } on SocketException {
        lastException = NetworkException('No internet connection');
        attempts++;
      } on http.ClientException {
        lastException = ApiException('HTTP request failed');
        attempts++;
      } catch (e) {
        lastException = ApiException('Unknown error occurred: ${e.toString()}');
        attempts++;
      }

      // Wait before retrying
      if (attempts < maxRetries) {
        await Future.delayed(Duration(milliseconds: 500 * attempts));
      }
    }

    throw lastException ?? ApiException('Request failed after $maxRetries attempts');
  }

  // Generic DELETE request with retry logic
  Future<Map<String, dynamic>> delete(String endpoint) async {
    int attempts = 0;
    Exception? lastException;

    while (attempts < maxRetries) {
      try {
        final token = await getToken();
        final response = await _client
            .delete(
              Uri.parse('$baseUrl/$endpoint'),
              headers: _getHeaders(token),
            )
            .timeout(timeout);

        return _handleResponse(response);
      } on TimeoutException {
        lastException = ApiException('Request timed out');
        attempts++;
      } on SocketException {
        lastException = NetworkException('No internet connection');
        attempts++;
      } on http.ClientException {
        lastException = ApiException('HTTP request failed');
        attempts++;
      } catch (e) {
        lastException = ApiException('Unknown error occurred: ${e.toString()}');
        attempts++;
      }

      // Wait before retrying
      if (attempts < maxRetries) {
        await Future.delayed(Duration(milliseconds: 500 * attempts));
      }
    }

    throw lastException ?? ApiException('Request failed after $maxRetries attempts');
  }

  // Mock API implementation
  Future<Map<String, dynamic>> mockApi(String endpoint, {Map<String, dynamic>? data}) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Mock endpoints
    if (endpoint.contains('login') || endpoint.contains('register')) {
      return {
        'token': 'mock-jwt-token-${DateTime.now().millisecondsSinceEpoch}',
        'user': {
          'id': 'mock-user-id',
          'email': data?['email'] ?? 'test@example.com',
        }
      };
    } else if (endpoint.contains('journal')) {
      return {
        'entries': [
          {
            'id': '1',
            'title': 'My First Journal Entry',
            'content': 'This is my first journal entry. I feel great today!',
            'timestamp': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
            'mood': 'happy',
          },
          {
            'id': '2',
            'title': 'Having a tough day',
            'content': 'Today was challenging but I got through it.',
            'timestamp': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
            'mood': 'sad',
          },
        ]
      };
    } else if (endpoint.contains('moods')) {
      return {
        'moods': [
          {
            'id': '1',
            'mood': 'happy',
            'timestamp': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
          },
          {
            'id': '2',
            'mood': 'sad',
            'timestamp': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
          },
          {
            'id': '3',
            'mood': 'neutral',
            'timestamp': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
          },
        ]
      };
    } else if (endpoint.contains('badges')) {
      return {
        'badges': [
          {
            'id': 'beginner_journal',
            'name': 'Beginner Journalist',
            'description': 'Added 5 journal entries',
            'icon': '📝',
          },
        ]
      };
    } else {
      return {
        'message': 'Endpoint not found',
        'success': false,
      };
    }
  }

  // Helper method to handle API response
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      Map<String, dynamic> errorData = {};
      try {
        errorData = json.decode(response.body);
      } catch (_) {
        errorData = {'message': 'Failed to process server response'};
      }
      
      final errorMessage = errorData['message'] ?? 'An unknown error occurred';
      throw ApiException(errorMessage, statusCode: response.statusCode);
    }
  }

  // Check internet connectivity
  Future<bool> _isConnected() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  // Get request headers with authorization
  Map<String, String> _getHeaders(String? token) {
    final headers = {
      'Content-Type': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // Save data for offline use
  Future<void> _saveOfflineData(String endpoint, Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('offline_$endpoint', json.encode(data));
      await prefs.setString('offline_${endpoint}_timestamp', DateTime.now().toIso8601String());
    } catch (e) {
      // Silently fail - offline data isn't critical
    }
  }

  // Get offline data
  Future<Map<String, dynamic>> _getOfflineData(String endpoint) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('offline_$endpoint');
      
      if (data != null) {
        return json.decode(data);
      }
      
      // If no offline data, use mock data as fallback
      if (useMockData) {
        return await mockApi(endpoint);
      }
      
      throw StorageException('No offline data available');
    } catch (e) {
      if (useMockData) {
        return await mockApi(endpoint);
      }
      throw StorageException('Failed to retrieve offline data');
    }
  }
  
  // Dispose resources
  void dispose() {
    _client.close();
  }
}
