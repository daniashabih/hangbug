import '../models/category_model.dart';
import '../models/question_model.dart';
import '../models/quiz_result_model.dart';
import '../services/guest_storage_service.dart';
import '../services/quiz_service.dart';

class QuizRepository {
  final QuizService quizService;
  final GuestStorageService guestStorage;

  QuizRepository({
    required this.quizService,
    required this.guestStorage,
  });

  Future<List<CategoryModel>> getCategories() async {
    try {
      final categories = await quizService.getCategories();
      if (categories.isNotEmpty) return categories;
      return GuestStorageService.fallbackCategories;
    } catch (_) {
      return GuestStorageService.fallbackCategories;
    }
  }

  Future<List<int>> getCategorySessions(String categoryName) async {
    try {
      final sessions = await quizService.getCategorySessions(categoryName);
      if (sessions.isNotEmpty) return sessions;
      return [1, 2, 3];
    } catch (_) {
      return [1, 2, 3];
    }
  }

  Future<List<QuestionModel>> getQuestions({
    required String category,
    int? session,
  }) async {
    try {
      final questions = await quizService.getQuestions(
        category: category,
        session: session,
      );
      if (questions.isNotEmpty) return questions;
      return GuestStorageService.getFallbackQuestions(category, session);
    } catch (_) {
      return GuestStorageService.getFallbackQuestions(category, session);
    }
  }

  Future<QuizResultModel> saveResult({
    required String category,
    required int session,
    required int score,
    required int total,
    required double percentage,
    bool isGuest = false,
  }) async {
    if (isGuest) {
      return await guestStorage.saveGuestResult(
        category: category,
        session: session,
        score: score,
        total: total,
        percentage: percentage,
      );
    }

    return await quizService.saveResult(
      category: category,
      session: session,
      score: score,
      total: total,
      percentage: percentage,
    );
  }

  Future<List<QuizResultModel>> getMyResults() async {
    return await quizService.getMyResults();
  }
}
