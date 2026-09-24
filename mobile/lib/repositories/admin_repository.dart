import '../models/admin_models.dart';
import '../models/question_model.dart';
import '../models/user_model.dart';
import '../services/admin_service.dart';

class AdminRepository {
  final AdminService adminService;

  AdminRepository({required this.adminService});

  Future<AdminDashboardModel> getAdminDashboard({String period = '30d'}) async {
    return await adminService.getAdminDashboard(period: period);
  }

  Future<List<UserModel>> getAllUsers() async {
    return await adminService.getAllUsers();
  }

  Future<void> deleteUser(String userId) async {
    await adminService.deleteUser(userId);
  }

  Future<List<QuestionModel>> getAllQuestions({String? category, int? session}) async {
    return await adminService.getAllQuestions(category: category, session: session);
  }

  Future<void> createQuestion({
    required String category,
    required int session,
    required String questionText,
    required List<String> options,
    required String correctAnswer,
    String difficulty = 'beginner',
  }) async {
    await adminService.createQuestion(
      category: category,
      session: session,
      questionText: questionText,
      options: options,
      correctAnswer: correctAnswer,
      difficulty: difficulty,
    );
  }

  Future<void> deleteQuestion(String questionId) async {
    await adminService.deleteQuestion(questionId);
  }

  Future<void> createCategory(String name) async {
    await adminService.createCategory(name);
  }

  Future<void> deleteCategory(String categoryId) async {
    await adminService.deleteCategory(categoryId);
  }

  Future<void> generateAiQuestions({
    required String topic,
    required int session,
    String difficulty = 'beginner',
    int count = 5,
  }) async {
    await adminService.generateAiQuestions(
      topic: topic,
      session: session,
      difficulty: difficulty,
      count: count,
    );
  }
}
