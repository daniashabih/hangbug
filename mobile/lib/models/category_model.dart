class CategoryModel {
  final String id;
  final String name;
  final int questionCount;
  final List<int> sessions;

  const CategoryModel({
    required this.id,
    required this.name,
    this.questionCount = 0,
    this.sessions = const [],
  });

  int get totalQuestions => questionCount;

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    var rawSessions = json['sessions'];
    List<int> parsedSessions = [];
    if (rawSessions is List) {
      parsedSessions = rawSessions
          .map((s) => int.tryParse(s.toString()) ?? 1)
          .toSet()
          .toList()
        ..sort();
    }

    return CategoryModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'General',
      questionCount: json['questionCount'] is int
          ? json['questionCount'] as int
          : (int.tryParse(json['questionCount']?.toString() ?? '0') ?? 0),
      sessions: parsedSessions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'questionCount': questionCount,
      'sessions': sessions,
    };
  }
}
