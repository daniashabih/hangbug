import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category_model.dart';
import '../models/certificate_model.dart';
import '../models/dashboard_model.dart';
import '../models/question_model.dart';
import '../models/quiz_result_model.dart';
import '../models/user_model.dart';

class GuestStorageService {
  static const String _keyGuestResults = 'hb_guest_results_list';
  static const String _keyGuestCertificates = 'hb_guest_certificates_list';

  // In-memory caches for fast, synchronous, or fallback access
  final List<QuizResultModel> _memoryResults = [];
  final List<CertificateModel> _memoryCertificates = [];
  bool _isLoaded = false;

  Future<void> _ensureLoaded() async {
    if (_isLoaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final resultsRaw = prefs.getStringList(_keyGuestResults) ?? [];
      _memoryResults.clear();
      for (final raw in resultsRaw) {
        try {
          _memoryResults.add(QuizResultModel.fromJson(jsonDecode(raw)));
        } catch (_) {}
      }

      final certsRaw = prefs.getStringList(_keyGuestCertificates) ?? [];
      _memoryCertificates.clear();
      for (final raw in certsRaw) {
        try {
          _memoryCertificates.add(CertificateModel.fromJson(jsonDecode(raw)));
        } catch (_) {}
      }
      _isLoaded = true;
    } catch (_) {
      _isLoaded = true;
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final resultsJson = _memoryResults.map((r) => jsonEncode(r.toJson())).toList();
      final certsJson = _memoryCertificates.map((c) => jsonEncode(c.toJson())).toList();
      await prefs.setStringList(_keyGuestResults, resultsJson);
      await prefs.setStringList(_keyGuestCertificates, certsJson);
    } catch (_) {}
  }

  // Record a quiz result for guest testing
  Future<QuizResultModel> saveGuestResult({
    required String category,
    required int session,
    required int score,
    required int total,
    required double percentage,
  }) async {
    await _ensureLoaded();

    final result = QuizResultModel(
      id: 'HB-GUEST-${DateTime.now().millisecondsSinceEpoch}',
      category: category,
      session: session,
      score: score,
      total: total,
      percentage: percentage,
      createdAt: DateTime.now().toIso8601String(),
    );

    _memoryResults.add(result);

    // If candidate scored >= 80%, award a guest verification certificate
    if (result.isCertified) {
      final certId = 'HB-GUEST-CERT-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
      final today = DateTime.now().toIso8601String().split('T').first;
      final cert = CertificateModel(
        id: certId,
        category: category,
        score: percentage.round(),
        date: today,
        learnerName: 'Guest Tester',
      );
      _memoryCertificates.add(cert);
    }

    await _persist();
    return result;
  }

  // Get all guest certificates
  Future<List<CertificateModel>> getGuestCertificates() async {
    await _ensureLoaded();
    return List.unmodifiable(_memoryCertificates.reversed);
  }

  // Generate guest dashboard analytics from local test data
  Future<UserDashboardModel> getGuestDashboard() async {
    await _ensureLoaded();

    final total = _memoryResults.length;
    final passed = _memoryResults.where((r) => r.isPassed).length;
    final failed = total - passed;
    final avgScore = total == 0
        ? 0.0
        : (_memoryResults.map((r) => r.percentage).reduce((a, b) => a + b) / total)
            .roundToDouble();

    final xp = _memoryResults.fold<int>(
      0,
      (sum, r) => sum + (r.score * 10) + (r.isPassed ? 50 : 10),
    );
    final level = (xp / 100).floor() + 1;
    final streak = total > 0 ? 1 : 0;

    // Technology breakdown
    final Map<String, List<QuizResultModel>> byTech = {};
    for (final r in _memoryResults) {
      byTech.putIfAbsent(r.category, () => []).add(r);
    }

    final techProgress = byTech.entries.map((entry) {
      final attempts = entry.value.length;
      final best = entry.value.map((r) => r.percentage.round()).reduce((a, b) => a > b ? a : b);
      final avg = (entry.value.map((r) => r.percentage).reduce((a, b) => a + b) / attempts).round();
      final passCount = entry.value.where((r) => r.isPassed).length;
      final passRate = ((passCount / attempts) * 100).round();

      return TechProgressModel(
        category: entry.key,
        attempts: attempts,
        bestScore: best,
        averageScore: avg,
        passRate: passRate,
      );
    }).toList();

    return UserDashboardModel(
      user: UserModel.guestUser,
      stats: UserStatsModel(
        totalQuizzes: total,
        averageScore: avgScore,
        passedQuizzes: passed,
        failedQuizzes: failed,
        certificates: _memoryCertificates.length,
        xp: xp,
        level: level,
        streak: streak,
        rank: 1,
      ),
      recentAttempts: _memoryResults.reversed.take(10).toList(),
      technologyProgress: techProgress,
      certificates: _memoryCertificates.reversed.toList(),
    );
  }

  // Clear guest testing progress
  Future<void> resetGuestData() async {
    _memoryResults.clear();
    _memoryCertificates.clear();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyGuestResults);
      await prefs.remove(_keyGuestCertificates);
    } catch (_) {}
  }

  // ==================== OFFLINE FALLBACK CONTENT ====================

  static List<CategoryModel> get fallbackCategories => const [
        CategoryModel(
          id: 'cat_js',
          name: 'JavaScript',
          questionCount: 3,
          sessions: [1, 2, 3],
        ),
        CategoryModel(
          id: 'cat_py',
          name: 'Python',
          questionCount: 3,
          sessions: [1, 2, 3],
        ),
        CategoryModel(
          id: 'cat_flutter',
          name: 'Flutter',
          questionCount: 3,
          sessions: [1, 2],
        ),
        CategoryModel(
          id: 'cat_devops',
          name: 'Agile & DevOps',
          questionCount: 3,
          sessions: [1],
        ),
      ];

  static List<QuestionModel> getFallbackQuestions(String category, [int? session]) {
    final lower = category.toLowerCase();
    if (lower.contains('python')) {
      return const [
        QuestionModel(
          id: 'offline_py_1',
          category: 'Python',
          session: 1,
          questionText: 'Which Python data type is immutable?',
          options: ['List', 'Dictionary', 'Tuple', 'Set'],
          correctAnswer: 'Tuple',
        ),
        QuestionModel(
          id: 'offline_py_2',
          category: 'Python',
          session: 1,
          questionText: 'What is the correct syntax to define a function in Python?',
          options: ['def myFunction():', 'function myFunction()', 'func myFunction():', 'define myFunction()'],
          correctAnswer: 'def myFunction():',
        ),
        QuestionModel(
          id: 'offline_py_3',
          category: 'Python',
          session: 1,
          questionText: 'Which operator is used for exponentiation in Python?',
          options: ['^', '**', 'exp()', '^^'],
          correctAnswer: '**',
        ),
      ];
    } else if (lower.contains('flutter') || lower.contains('dart')) {
      return const [
        QuestionModel(
          id: 'offline_fl_1',
          category: 'Flutter',
          session: 1,
          questionText: 'Which widget is used as the root of most Material Design Flutter apps?',
          options: ['MaterialApp', 'WidgetApp', 'Scaffold', 'Container'],
          correctAnswer: 'MaterialApp',
        ),
        QuestionModel(
          id: 'offline_fl_2',
          category: 'Flutter',
          session: 1,
          questionText: 'In Flutter, what kind of widget can maintain state that changes over time?',
          options: ['StatelessWidget', 'StatefulWidget', 'InheritedWidget', 'ImmutableWidget'],
          correctAnswer: 'StatefulWidget',
        ),
        QuestionModel(
          id: 'offline_fl_3',
          category: 'Flutter',
          session: 1,
          questionText: 'Which command compiles and runs a Flutter application on an attached device?',
          options: ['flutter run', 'flutter start', 'flutter test', 'flutter build'],
          correctAnswer: 'flutter run',
        ),
      ];
    } else if (lower.contains('agile') || lower.contains('devops')) {
      return const [
        QuestionModel(
          id: 'offline_ag_1',
          category: 'Agile & DevOps',
          session: 1,
          questionText: 'What does CI stand for in modern DevOps practice?',
          options: ['Continuous Integration', 'Code Inspection', 'Continuous Iteration', 'Centralized Infrastructure'],
          correctAnswer: 'Continuous Integration',
        ),
        QuestionModel(
          id: 'offline_ag_2',
          category: 'Agile & DevOps',
          session: 1,
          questionText: 'Which ceremony is held at the end of a sprint to inspect the sprint and adapt for the next one?',
          options: ['Sprint Retrospective', 'Daily Standup', 'Sprint Planning', 'Backlog Refinement'],
          correctAnswer: 'Sprint Retrospective',
        ),
        QuestionModel(
          id: 'offline_ag_3',
          category: 'Agile & DevOps',
          session: 1,
          questionText: 'In Git, what command creates a new branch and switches to it in one step?',
          options: ['git checkout -b <name>', 'git branch -new <name>', 'git switch --all <name>', 'git create <name>'],
          correctAnswer: 'git checkout -b <name>',
        ),
      ];
    }

    // Default / JavaScript questions
    return const [
      QuestionModel(
        id: 'offline_js_1',
        category: 'JavaScript',
        session: 1,
        questionText: 'What method converts a JavaScript object into a JSON string?',
        options: ['JSON.parse()', 'JSON.stringify()', 'Object.toString()', 'JSON.encode()'],
        correctAnswer: 'JSON.stringify()',
      ),
      QuestionModel(
        id: 'offline_js_2',
        category: 'JavaScript',
        session: 1,
        questionText: 'Which keyword declares a block-scoped variable that can be reassigned?',
        options: ['const', 'var', 'let', 'static'],
        correctAnswer: 'let',
      ),
      QuestionModel(
        id: 'offline_js_3',
        category: 'JavaScript',
        session: 1,
        questionText: 'What will typeof NaN evaluate to in JavaScript?',
        options: ['undefined', 'number', 'nan', 'object'],
        correctAnswer: 'number',
      ),
    ];
  }
}
