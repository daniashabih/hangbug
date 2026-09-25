import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hangbug/core/storage/secure_storage_service.dart';
import 'package:hangbug/core/theme/app_theme.dart';
import 'package:hangbug/models/user_model.dart';
import 'package:hangbug/providers/auth_provider.dart';
import 'package:hangbug/providers/core_providers.dart';
import 'package:hangbug/screens/auth/login_screen.dart';
import 'package:hangbug/services/guest_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeSecureStorageService extends SecureStorageService {
  final Map<String, String> _data = {};

  @override
  Future<void> saveToken(String token) async => _data['token'] = token;

  @override
  Future<String?> getToken() async => _data['token'];

  @override
  Future<void> deleteToken() async => _data.remove('token');

  @override
  Future<void> saveUserData(Map<String, dynamic> userData) async =>
      _data['user'] = jsonEncode(userData);

  @override
  Future<Map<String, dynamic>?> getUserData() async {
    final raw = _data['user'];
    return raw != null ? jsonDecode(raw) : null;
  }

  @override
  Future<void> clearAll() async => _data.clear();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('UserModel & AuthState Guest Mode Tests', () {
    test('UserModel.guestUser has expected guest properties', () {
      const guest = UserModel.guestUser;
      expect(guest.id, equals('guest'));
      expect(guest.name, equals('Guest Tester'));
      expect(guest.role, equals('guest'));
      expect(guest.isGuest, isTrue);
      expect(guest.isAdmin, isFalse);
    });

    test('Regular user is not considered guest', () {
      const user = UserModel(
        id: 'u123',
        name: 'Regular Learner',
        email: 'learner@example.com',
        role: 'user',
      );
      expect(user.isGuest, isFalse);
      expect(user.isAdmin, isFalse);
    });

    test('AuthState reflects guest state accurately', () {
      const unauth = AuthState();
      expect(unauth.isAuthenticated, isFalse);
      expect(unauth.isGuest, isFalse);

      const guestAuth = AuthState(user: UserModel.guestUser);
      expect(guestAuth.isAuthenticated, isTrue);
      expect(guestAuth.isGuest, isTrue);
      expect(guestAuth.isAdmin, isFalse);
    });
  });

  group('GuestStorageService Tests', () {
    test('Initial guest dashboard has zeroed stats and empty lists', () async {
      final service = GuestStorageService();
      final dashboard = await service.getGuestDashboard();

      expect(dashboard.user?.isGuest, isTrue);
      expect(dashboard.stats.totalQuizzes, equals(0));
      expect(dashboard.stats.averageScore, equals(0.0));
      expect(dashboard.stats.certificates, equals(0));
      expect(dashboard.recentAttempts, isEmpty);
      expect(dashboard.certificates, isEmpty);
    });

    test('saveGuestResult updates stats and generates certificate on >= 80%', () async {
      final service = GuestStorageService();

      // Submit a passing quiz with score 80% (certified)
      final result = await service.saveGuestResult(
        category: 'JavaScript',
        session: 1,
        score: 4,
        total: 5,
        percentage: 80.0,
      );

      expect(result.id, startsWith('HB-GUEST-'));
      expect(result.isCertified, isTrue);

      final certs = await service.getGuestCertificates();
      expect(certs.length, equals(1));
      expect(certs.first.category, equals('JavaScript'));
      expect(certs.first.score, equals(80));

      final dashboard = await service.getGuestDashboard();
      expect(dashboard.stats.totalQuizzes, equals(1));
      expect(dashboard.stats.passedQuizzes, equals(1));
      expect(dashboard.stats.certificates, equals(1));
      expect(dashboard.stats.averageScore, equals(80.0));
      expect(dashboard.recentAttempts.length, equals(1));
    });

    test('resetGuestData clears all guest progress', () async {
      final service = GuestStorageService();

      await service.saveGuestResult(
        category: 'Python',
        session: 1,
        score: 3,
        total: 3,
        percentage: 100.0,
      );

      var certs = await service.getGuestCertificates();
      expect(certs, isNotEmpty);

      await service.resetGuestData();

      certs = await service.getGuestCertificates();
      expect(certs, isEmpty);

      final dashboard = await service.getGuestDashboard();
      expect(dashboard.stats.totalQuizzes, equals(0));
    });

    test('Fallback content provides valid categories and questions', () {
      final categories = GuestStorageService.fallbackCategories;
      expect(categories, isNotEmpty);
      expect(categories.any((c) => c.name == 'JavaScript'), isTrue);
      expect(categories.any((c) => c.name == 'Python'), isTrue);

      final jsQuestions = GuestStorageService.getFallbackQuestions('JavaScript');
      expect(jsQuestions, isNotEmpty);
      expect(jsQuestions.first.options, isNotEmpty);
      expect(jsQuestions.first.correctAnswer, isNotEmpty);

      final pyQuestions = GuestStorageService.getFallbackQuestions('Python');
      expect(pyQuestions, isNotEmpty);

      final flutterQuestions = GuestStorageService.getFallbackQuestions('Flutter');
      expect(flutterQuestions, isNotEmpty);
    });
  });

  group('LoginScreen Guest Mode Widget Tests', () {
    testWidgets('LoginScreen displays Continue as Guest button and OR divider', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            secureStorageProvider.overrideWithValue(FakeSecureStorageService()),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const LoginScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('OR'), findsOneWidget);
      expect(find.text('Continue as Guest'), findsOneWidget);
      expect(
        find.text('Explore quizzes and test certification features without signing in'),
        findsOneWidget,
      );
    });
  });
}
