import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category_model.dart';
import '../models/certificate_model.dart';
import '../models/dashboard_model.dart';
import 'core_providers.dart';

// User Dashboard Data Provider
final userDashboardProvider =
    FutureProvider.autoDispose<UserDashboardModel>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  return await repository.getUserDashboard();
});

// Categories / Technologies Provider
final categoriesProvider =
    FutureProvider.autoDispose<List<CategoryModel>>((ref) async {
  final repository = ref.watch(quizRepositoryProvider);
  return await repository.getCategories();
});

// Certificates Provider
final certificatesProvider =
    FutureProvider.autoDispose<List<CertificateModel>>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  return await repository.getCertificates();
});
