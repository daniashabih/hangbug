class QuizResultModel {
  final String id;
  final String category;
  final int session;
  final int score;
  final int total;
  final double percentage;
  final String? createdAt;

  const QuizResultModel({
    required this.id,
    required this.category,
    this.session = 1,
    required this.score,
    required this.total,
    required this.percentage,
    this.createdAt,
  });

  bool get isPassed => percentage >= 70;
  bool get isCertified => percentage >= 80;

  factory QuizResultModel.fromJson(Map<String, dynamic> json) {
    return QuizResultModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      category: json['category']?.toString() ?? 'General',
      session: json['session'] is int
          ? json['session'] as int
          : (int.tryParse(json['session']?.toString() ?? '1') ?? 1),
      score: json['score'] is int
          ? json['score'] as int
          : (int.tryParse(json['score']?.toString() ?? '0') ?? 0),
      total: json['total'] is int
          ? json['total'] as int
          : (int.tryParse(json['total']?.toString() ?? '0') ?? 0),
      percentage: json['percentage'] is num
          ? (json['percentage'] as num).toDouble()
          : (double.tryParse(json['percentage']?.toString() ?? '0') ?? 0.0),
      createdAt: json['createdAt']?.toString() ?? json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'session': session,
      'score': score,
      'total': total,
      'percentage': percentage,
      'createdAt': createdAt,
    };
  }
}
