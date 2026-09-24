import '../models/category_model.dart';
import '../models/question_model.dart';
import '../models/quiz_result_model.dart';
import '../services/quiz_service.dart';

class QuizRepository {
  final QuizService quizService;

  QuizRepository({required this.quizService});

  Future<List<CategoryModel>> getCategories() async {
    return await quizService.getCategories();
  }

  Future<List<int>> getCategorySessions(String categoryName) async {
    return await quizService.getCategorySessions(categoryName);
  }

  Future<List<QuestionModel>> getQuestions({
    required String category,
    int? session,
  }) async {
    return await quizService.getQuestions(category: category, session: session);
  }

  Future<QuizResultModel> saveResult({
    required String category,
    required int session,
    required int score,
    required int total,
    required double percentage,
  }) async {
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
