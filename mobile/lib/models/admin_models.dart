import 'user_model.dart';

class AdminStatsModel {
  final int totalUsers;
  final int totalTechnologies;
  final int totalQuestions;
  final int totalAttempts;
  final int totalCertificates;
  final int passedAttempts;
  final int failedAttempts;
  final double averageScore;

  const AdminStatsModel({
    this.totalUsers = 0,
    this.totalTechnologies = 0,
    this.totalQuestions = 0,
    this.totalAttempts = 0,
    this.totalCertificates = 0,
    this.passedAttempts = 0,
    this.failedAttempts = 0,
    this.averageScore = 0.0,
  });

  factory AdminStatsModel.fromJson(Map<String, dynamic> json) {
    return AdminStatsModel(
      totalUsers: int.tryParse(json['totalUsers']?.toString() ?? '0') ?? 0,
      totalTechnologies: int.tryParse(json['totalTechnologies']?.toString() ?? '0') ?? 0,
      totalQuestions: int.tryParse(json['totalQuestions']?.toString() ?? '0') ?? 0,
      totalAttempts: int.tryParse(json['totalAttempts']?.toString() ?? '0') ?? 0,
      totalCertificates: int.tryParse(json['totalCertificates']?.toString() ?? '0') ?? 0,
      passedAttempts: int.tryParse(json['passedAttempts']?.toString() ?? '0') ?? 0,
      failedAttempts: int.tryParse(json['failedAttempts']?.toString() ?? '0') ?? 0,
      averageScore: double.tryParse(json['averageScore']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class AdminRecentAttemptModel {
  final String id;
  final String userName;
  final String userEmail;
  final String category;
  final int session;
  final int score;
  final int total;
  final int percentage;
  final bool passed;
  final String createdAt;

  const AdminRecentAttemptModel({
    required this.id,
    required this.userName,
    required this.userEmail,
    required this.category,
    this.session = 1,
    required this.score,
    required this.total,
    required this.percentage,
    required this.passed,
    required this.createdAt,
  });

  factory AdminRecentAttemptModel.fromJson(Map<String, dynamic> json) {
    return AdminRecentAttemptModel(
      id: json['id']?.toString() ?? '',
      userName: json['userName']?.toString() ?? 'Anonymous Learner',
      userEmail: json['userEmail']?.toString() ?? '',
      category: json['category']?.toString() ?? 'General',
      session: int.tryParse(json['session']?.toString() ?? '1') ?? 1,
      score: int.tryParse(json['score']?.toString() ?? '0') ?? 0,
      total: int.tryParse(json['total']?.toString() ?? '0') ?? 0,
      percentage: int.tryParse(json['percentage']?.toString() ?? '0') ?? 0,
      passed: json['passed'] == true,
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }
}

class AdminDashboardModel {
  final AdminStatsModel stats;
  final List<AdminRecentAttemptModel> recentAttempts;
  final List<UserModel> recentUsers;

  const AdminDashboardModel({
    this.stats = const AdminStatsModel(),
    this.recentAttempts = const [],
    this.recentUsers = const [],
  });

  factory AdminDashboardModel.fromJson(Map<String, dynamic> json) {
    final rawStats = json['stats'] as Map<String, dynamic>? ?? {};
    final rawAttempts = json['recentAttempts'] as List? ?? [];
    final rawUsers = json['recentUsers'] as List? ?? [];

    return AdminDashboardModel(
      stats: AdminStatsModel.fromJson(rawStats),
      recentAttempts: rawAttempts
          .map((a) => AdminRecentAttemptModel.fromJson(a as Map<String, dynamic>))
          .toList(),
      recentUsers: rawUsers
          .map((u) => UserModel.fromJson(u as Map<String, dynamic>))
          .toList(),
    );
  }
}
