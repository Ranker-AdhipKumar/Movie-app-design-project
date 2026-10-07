import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/repositories/auth_repository.dart';
import 'package:movie_app/services/auth_service.dart';

void main() {
  group('AuthService Tests', () {
    late AuthService authService;

    setUp(() {
      authService = AuthService();
    });

    test('login succeeds with pre-registered demo credentials', () async {
      final user = await authService.login(
        email: 'demo@flickvault.com',
        password: 'password123',
      );

      expect(user.email, 'demo@flickvault.com');
      expect(user.name, 'Alex Rivera');
      expect(user.id, isNotEmpty);
    });

    test('login fails with wrong password', () async {
      expect(
        () => authService.login(
          email: 'demo@flickvault.com',
          password: 'wrongpassword',
        ),
        throwsA(isA<AuthException>()),
      );
    });

    test('login fails with invalid email format', () async {
      expect(
        () => authService.login(
          email: 'notanemail',
          password: 'password123',
        ),
        throwsA(isA<AuthException>()),
      );
    });

    test('guest login generates valid cinema guest user', () async {
      final user = await authService.loginAsGuest();
      expect(user.name, 'Cinema Guest');
      expect(user.email, 'guest@flickvault.com');
    });

    test('register successfully creates new account', () async {
      final user = await authService.register(
        name: 'Sarah Connor',
        email: 'sarah@resistance.org',
        password: 'terminator2',
      );

      expect(user.name, 'Sarah Connor');
      expect(user.email, 'sarah@resistance.org');
    });
  });

  group('AuthRepository State Lifecycle Tests', () {
    late AuthRepository authRepository;

    setUp(() {
      authRepository = AuthRepository();
    });

    test('initial state is unauthenticated', () {
      expect(authRepository.isAuthenticated, false);
      expect(authRepository.currentUser, isNull);
    });

    test('login updates authentication state and user', () async {
      final success = await authRepository.login(
        email: 'demo@flickvault.com',
        password: 'password123',
      );

      expect(success, true);
      expect(authRepository.isAuthenticated, true);
      expect(authRepository.currentUser?.name, 'Alex Rivera');
    });

    test('logout clears user session', () async {
      await authRepository.loginAsGuest();
      expect(authRepository.isAuthenticated, true);

      authRepository.logout();
      expect(authRepository.isAuthenticated, false);
      expect(authRepository.currentUser, isNull);
    });
  });
}
