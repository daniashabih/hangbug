import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../models/admin_models.dart';
import '../models/question_model.dart';
import '../models/user_model.dart';

class AdminService {
  final ApiClient apiClient;

  AdminService({required this.apiClient});

  // Get Admin Dashboard Overview
  Future<AdminDashboardModel> getAdminDashboard({String period = '30d'}) async {
    final response = await apiClient.get(
      ApiEndpoints.adminDashboard,
      queryParameters: {'period': period},
    );
    final data = response.data as Map<String, dynamic>;
    final payload = data['data'] as Map<String, dynamic>? ?? data;
    return AdminDashboardModel.fromJson(payload);
  }

  // Get All Users (Admin Only)
  Future<List<UserModel>> getAllUsers() async {
    final response = await apiClient.get(ApiEndpoints.adminUsers);
    final data = response.data;
    List list = [];
    if (data is Map && data.containsKey('users')) {
      list = data['users'] as List;
    } else if (data is List) {
      list = data;
    }
    return list
        .map((u) => UserModel.fromJson(u as Map<String, dynamic>))
        .toList();
  }

  // Delete User
  Future<void> deleteUser(String userId) async {
    await apiClient.delete('${ApiEndpoints.adminUsers}/$userId');
  }

  // Get All Questions
  Future<List<QuestionModel>> getAllQuestions({String? category, int? session}) async {
    final Map<String, dynamic> params = {};
    if (category != null && category.isNotEmpty && category != 'all') {
      params['category'] = category;
    }
    if (session != null && session > 0) {
      params['session'] = session;
    }

    final response = await apiClient.get(
      ApiEndpoints.adminQuestions,
      queryParameters: params,
    );
    final list = response.data as List;
    return list
        .map((q) => QuestionModel.fromJson(q as Map<String, dynamic>))
        .toList();
  }

  // Create Question
  Future<void> createQuestion({
    required String category,
    required int session,
    required String questionText,
    required List<String> options,
    required String correctAnswer,
    String difficulty = 'beginner',
  }) async {
    await apiClient.post(
      ApiEndpoints.adminQuestions,
      data: {
        'category': category,
        'session': session,
        'question_text': questionText,
        'options': options,
        'correct_answer': correctAnswer,
        'difficulty': difficulty,
      },
    );
  }

  // Delete Question
  Future<void> deleteQuestion(String questionId) async {
    await apiClient.delete('${ApiEndpoints.adminQuestions}/$questionId');
  }

  // Create Category
  Future<void> createCategory(String name) async {
    await apiClient.post(
      ApiEndpoints.adminTechnologies,
      data: {'name': name.trim()},
    );
  }

  // Delete Category
  Future<void> deleteCategory(String categoryId) async {
    await apiClient.delete('${ApiEndpoints.adminTechnologies}/$categoryId');
  }

  // Generate Questions with AI
  Future<void> generateAiQuestions({
    required String topic,
    required int session,
    String difficulty = 'beginner',
    int count = 5,
  }) async {
    await apiClient.post(
      ApiEndpoints.generateQuestions,
      data: {
        'topic': topic,
        'session': session,
        'difficulty': difficulty,
        'count': count,
      },
    );
  }
}
