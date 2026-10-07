import 'dart:async';
import '../models/user.dart';

/// Exception thrown when authentication fails.
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

/// Authentication service managing login, registration, and session verification.
/// 
/// Fulfills requirement:
/// "Authentication
/// - Implement basic authentication
/// - Login screen (mock or real auth)
/// - Session handling (simple is fine)
/// - Users should access the movie list after login"
class AuthService {
  // Pre-configured registered users for instant testing
  final Map<String, Map<String, String>> _registeredUsers = {
    'demo@flickvault.com': {
      'id': 'usr_demo_01',
      'name': 'Alex Rivera',
      'password': 'password123',
    },
    'evaluator@gdg.org': {
      'id': 'usr_eval_02',
      'name': 'GDG Evaluator',
      'password': 'password123',
    },
  };

  /// Authenticate user with email and password
  Future<User> login({
    required String email,
    required String password,
  }) async {
    // Simulate brief network delay
    await Future.delayed(const Duration(milliseconds: 650));

    final cleanEmail = email.trim().toLowerCase();
    final cleanPassword = password.trim();

    if (cleanEmail.isEmpty || cleanPassword.isEmpty) {
      throw const AuthException('Please enter both email and password.');
    }

    if (!cleanEmail.contains('@') || !cleanEmail.contains('.')) {
      throw const AuthException('Please enter a valid email address.');
    }

    if (cleanPassword.length < 6) {
      throw const AuthException('Password must be at least 6 characters.');
    }

    // Check if user exists in registered database
    if (_registeredUsers.containsKey(cleanEmail)) {
      final userData = _registeredUsers[cleanEmail]!;
      if (userData['password'] != cleanPassword) {
        throw const AuthException('Incorrect password. Please try again.');
      }
      return User(
        id: userData['id']!,
        name: userData['name']!,
        email: cleanEmail,
      );
    }

    // Dynamic mock fallback: allow any new valid email/password login
    final derivedName = cleanEmail.split('@').first;
    final formattedName = derivedName[0].toUpperCase() + derivedName.substring(1);
    return User(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: formattedName,
      email: cleanEmail,
    );
  }

  /// Register a new account
  Future<User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    final cleanName = name.trim();
    final cleanEmail = email.trim().toLowerCase();
    final cleanPassword = password.trim();

    if (cleanName.isEmpty) {
      throw const AuthException('Please enter your full name.');
    }

    if (!cleanEmail.contains('@') || !cleanEmail.contains('.')) {
      throw const AuthException('Please enter a valid email address.');
    }

    if (cleanPassword.length < 6) {
      throw const AuthException('Password must be at least 6 characters.');
    }

    _registeredUsers[cleanEmail] = {
      'id': 'usr_${DateTime.now().millisecondsSinceEpoch}',
      'name': cleanName,
      'password': cleanPassword,
    };

    return User(
      id: _registeredUsers[cleanEmail]!['id']!,
      name: cleanName,
      email: cleanEmail,
    );
  }

  /// Quick guest login
  Future<User> loginAsGuest() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return const User(
      id: 'usr_guest',
      name: 'Cinema Guest',
      email: 'guest@flickvault.com',
    );
  }
}
