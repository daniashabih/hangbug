import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../models/category_model.dart';
import '../models/question_model.dart';
import '../models/quiz_result_model.dart';

class QuizService {
  final ApiClient apiClient;

  QuizService({required this.apiClient});

  // Get all available technologies
  Future<List<CategoryModel>> getCategories() async {
    final response = await apiClient.get(ApiEndpoints.categories);
    final list = response.data as List;
    return list
        .map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  // Get sessions list for a specific category
  Future<List<int>> getCategorySessions(String categoryName) async {
    final response = await apiClient.get(
      ApiEndpoints.questionSessions,
      queryParameters: {'category': categoryName},
    );
    final list = response.data as List;
    final Set<int> sessions = {};
    for (final item in list) {
      if (item is Map && item.containsKey('session')) {
        final val = int.tryParse(item['session'].toString());
        if (val != null) sessions.add(val);
      } else if (item is num) {
        sessions.add(item.toInt());
      }
    }
    final sorted = sessions.toList()..sort();
    return sorted.isEmpty ? [1] : sorted;
  }

  // Fetch questions for assessment
  Future<List<QuestionModel>> getQuestions({
    required String category,
    int? session,
  }) async {
    final Map<String, dynamic> params = {'category': category};
    if (session != null && session > 0) {
      params['session'] = session;
    }

    final response = await apiClient.get(
      ApiEndpoints.questions,
      queryParameters: params,
    );

    final list = response.data as List;
    return list
        .map((item) => QuestionModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  // Save quiz result
  Future<QuizResultModel> saveResult({
    required String category,
    required int session,
    required int score,
    required int total,
    required double percentage,
  }) async {
    final response = await apiClient.post(
      ApiEndpoints.saveResult,
      data: {
        'category': category,
        'session': session,
        'score': score,
        'total': total,
        'percentage': percentage,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final resultId = data['resultId']?.toString() ?? '';

    return QuizResultModel(
      id: resultId,
      category: category,
      session: session,
      score: score,
      total: total,
      percentage: percentage,
      createdAt: DateTime.now().toIso8601String(),
    );
  }

  // Fetch candidate's previous quiz results
  Future<List<QuizResultModel>> getMyResults() async {
    final response = await apiClient.get(ApiEndpoints.myResults);
    final list = response.data as List;
    return list
        .map((item) => QuizResultModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
