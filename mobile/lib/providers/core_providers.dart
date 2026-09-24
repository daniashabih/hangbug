import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_client.dart';
import '../core/storage/secure_storage_service.dart';
import '../repositories/admin_repository.dart';
import '../repositories/auth_repository.dart';
import '../repositories/dashboard_repository.dart';
import '../repositories/quiz_repository.dart';
import '../services/admin_service.dart';
import '../services/auth_service.dart';
import '../services/dashboard_service.dart';
import '../services/quiz_service.dart';

// Storage Provider
final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

// ApiClient Provider
final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return ApiClient(secureStorage: storage);
});

// Auth Providers
final authServiceProvider = Provider<AuthService>((ref) {
  final client = ref.watch(apiClientProvider);
  return AuthService(apiClient: client);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final service = ref.watch(authServiceProvider);
  final storage = ref.watch(secureStorageProvider);
  return AuthRepository(authService: service, secureStorage: storage);
});

// Quiz Providers
final quizServiceProvider = Provider<QuizService>((ref) {
  final client = ref.watch(apiClientProvider);
  return QuizService(apiClient: client);
});

final quizRepositoryProvider = Provider<QuizRepository>((ref) {
  final service = ref.watch(quizServiceProvider);
  return QuizRepository(quizService: service);
});

// Dashboard Providers
final dashboardServiceProvider = Provider<DashboardService>((ref) {
  final client = ref.watch(apiClientProvider);
  return DashboardService(apiClient: client);
});

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final service = ref.watch(dashboardServiceProvider);
  return DashboardRepository(dashboardService: service);
});

// Admin Providers
final adminServiceProvider = Provider<AdminService>((ref) {
  final client = ref.watch(apiClientProvider);
  return AdminService(apiClient: client);
});

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  final service = ref.watch(adminServiceProvider);
  return AdminRepository(adminService: service);
});
