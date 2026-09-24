import 'user_model.dart';
import 'quiz_result_model.dart';
import 'certificate_model.dart';

class UserStatsModel {
  final int totalQuizzes;
  final double averageScore;
  final int passedQuizzes;
  final int failedQuizzes;
  final int certificates;
  final int xp;
  final int level;
  final int streak;
  final int rank;

  const UserStatsModel({
    this.totalQuizzes = 0,
    this.averageScore = 0.0,
    this.passedQuizzes = 0,
    this.failedQuizzes = 0,
    this.certificates = 0,
    this.xp = 0,
    this.level = 1,
    this.streak = 0,
    this.rank = 1,
  });

  factory UserStatsModel.fromJson(Map<String, dynamic> json) {
    return UserStatsModel(
      totalQuizzes: int.tryParse(json['totalQuizzes']?.toString() ?? '0') ?? 0,
      averageScore: double.tryParse(json['averageScore']?.toString() ?? '0') ?? 0.0,
      passedQuizzes: int.tryParse(json['passedQuizzes']?.toString() ?? '0') ?? 0,
      failedQuizzes: int.tryParse(json['failedQuizzes']?.toString() ?? '0') ?? 0,
      certificates: int.tryParse(json['certificates']?.toString() ?? '0') ?? 0,
      xp: int.tryParse(json['xp']?.toString() ?? '0') ?? 0,
      level: int.tryParse(json['level']?.toString() ?? '1') ?? 1,
      streak: int.tryParse(json['streak']?.toString() ?? '0') ?? 0,
      rank: int.tryParse(json['rank']?.toString() ?? '1') ?? 1,
    );
  }
}

class TechProgressModel {
  final String category;
  final int attempts;
  final int bestScore;
  final int averageScore;
  final int passRate;

  const TechProgressModel({
    required this.category,
    this.attempts = 0,
    this.bestScore = 0,
    this.averageScore = 0,
    this.passRate = 0,
  });

  factory TechProgressModel.fromJson(Map<String, dynamic> json) {
    return TechProgressModel(
      category: json['category']?.toString() ?? 'General',
      attempts: int.tryParse(json['attempts']?.toString() ?? '0') ?? 0,
      bestScore: int.tryParse(json['bestScore']?.toString() ?? '0') ?? 0,
      averageScore: int.tryParse(json['averageScore']?.toString() ?? '0') ?? 0,
      passRate: int.tryParse(json['passRate']?.toString() ?? '0') ?? 0,
    );
  }
}

class UserDashboardModel {
  final UserModel? user;
  final UserStatsModel stats;
  final List<QuizResultModel> recentAttempts;
  final List<TechProgressModel> technologyProgress;
  final List<CertificateModel> certificates;

  const UserDashboardModel({
    this.user,
    this.stats = const UserStatsModel(),
    this.recentAttempts = const [],
    this.technologyProgress = const [],
    this.certificates = const [],
  });

  int get totalQuizzesTaken => stats.totalQuizzes;
  int get certificatesCount => certificates.isNotEmpty ? certificates.length : stats.certificates;
  double get averageScore => stats.averageScore;

  factory UserDashboardModel.fromJson(Map<String, dynamic> json) {
    final rawStats = json['stats'] as Map<String, dynamic>? ?? {};
    final rawUser = json['user'] as Map<String, dynamic>?;
    final rawRecent = json['recentAttempts'] as List? ?? [];
    final rawTech = json['technologyProgress'] as List? ?? [];
    final rawCerts = json['certificates'] as List? ?? [];

    return UserDashboardModel(
      user: rawUser != null ? UserModel.fromJson(rawUser) : null,
      stats: UserStatsModel.fromJson(rawStats),
      recentAttempts: rawRecent
          .map((r) => QuizResultModel.fromJson(r as Map<String, dynamic>))
          .toList(),
      technologyProgress: rawTech
          .map((t) => TechProgressModel.fromJson(t as Map<String, dynamic>))
          .toList(),
      certificates: rawCerts
          .map((c) => CertificateModel.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }
}
