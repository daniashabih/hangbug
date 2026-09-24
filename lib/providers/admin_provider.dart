import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/admin_models.dart';
import '../models/question_model.dart';
import '../models/user_model.dart';
import 'core_providers.dart';
import 'dashboard_provider.dart';

final adminDashboardPeriodProvider = StateProvider<String>((ref) => '30d');

final adminDashboardProvider = FutureProvider.autoDispose<AdminDashboardModel>((ref) async {
  final repo = ref.watch(adminRepositoryProvider);
  final period = ref.watch(adminDashboardPeriodProvider);
  return await repo.getAdminDashboard(period: period);
});

final adminUsersProvider = FutureProvider.autoDispose<List<UserModel>>((ref) async {
  final repo = ref.watch(adminRepositoryProvider);
  return await repo.getAllUsers();
});

final adminCategoryFilterProvider = StateProvider<String?>((ref) => null);
final adminSessionFilterProvider = StateProvider<int?>((ref) => null);

final adminQuestionsProvider = FutureProvider.autoDispose<List<QuestionModel>>((ref) async {
  final repo = ref.watch(adminRepositoryProvider);
  final cat = ref.watch(adminCategoryFilterProvider);
  final ses = ref.watch(adminSessionFilterProvider);
  return await repo.getAllQuestions(category: cat, session: ses);
});

class AdminController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  AdminController(this.ref) : super(const AsyncValue.data(null));

  Future<bool> deleteUser(String userId) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(adminRepositoryProvider);
      await repo.deleteUser(userId);
      ref.invalidate(adminUsersProvider);
      ref.invalidate(adminDashboardProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> createQuestion({
    required String category,
    required int session,
    required String questionText,
    required List<String> options,
    required String correctAnswer,
    String difficulty = 'beginner',
  }) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(adminRepositoryProvider);
      await repo.createQuestion(
        category: category,
        session: session,
        questionText: questionText,
        options: options,
        correctAnswer: correctAnswer,
        difficulty: difficulty,
      );
      ref.invalidate(adminQuestionsProvider);
      ref.invalidate(adminDashboardProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> deleteQuestion(String questionId) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(adminRepositoryProvider);
      await repo.deleteQuestion(questionId);
      ref.invalidate(adminQuestionsProvider);
      ref.invalidate(adminDashboardProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> createCategory(String name) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(adminRepositoryProvider);
      await repo.createCategory(name);
      ref.invalidate(categoriesProvider);
      ref.invalidate(adminDashboardProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> deleteCategory(String categoryId) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(adminRepositoryProvider);
      await repo.deleteCategory(categoryId);
      ref.invalidate(categoriesProvider);
      ref.invalidate(adminDashboardProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> generateAiQuestions({
    required String topic,
    required int session,
    String difficulty = 'beginner',
    int count = 5,
  }) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(adminRepositoryProvider);
      await repo.generateAiQuestions(
        topic: topic,
        session: session,
        difficulty: difficulty,
        count: count,
      );
      ref.invalidate(adminQuestionsProvider);
      ref.invalidate(adminDashboardProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final adminControllerProvider = StateNotifierProvider<AdminController, AsyncValue<void>>((ref) {
  return AdminController(ref);
});
