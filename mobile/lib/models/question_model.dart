import 'dart:convert';

class QuestionModel {
  final String id;
  final String category;
  final int session;
  final String questionText;
  final List<String> options;
  final String correctAnswer;
  final String difficulty;
  final String? explanation;

  const QuestionModel({
    required this.id,
    required this.category,
    this.session = 1,
    required this.questionText,
    required this.options,
    required this.correctAnswer,
    this.difficulty = 'beginner',
    this.explanation,
  });

  String get question => questionText;

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    // Parse options list whether it is JSON array, string, or comma-separated
    List<String> parsedOptions = [];
    final rawOptions = json['options'];
    if (rawOptions is List) {
      parsedOptions = rawOptions.map((o) => o.toString().trim()).toList();
    } else if (rawOptions is String) {
      try {
        final decoded = jsonDecode(rawOptions);
        if (decoded is List) {
          parsedOptions = decoded.map((o) => o.toString().trim()).toList();
        }
      } catch (_) {
        parsedOptions = rawOptions
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
      }
    }

    final rawSession = json['session'];
    final sessionNum = rawSession is int
        ? rawSession
        : (int.tryParse(rawSession?.toString() ?? '1') ?? 1);

    return QuestionModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      session: sessionNum,
      questionText: json['question_text']?.toString() ??
          json['questionText']?.toString() ??
          '',
      options: parsedOptions,
      correctAnswer: json['correct_answer']?.toString() ??
          json['correctAnswer']?.toString() ??
          '',
      difficulty: json['difficulty']?.toString() ?? 'beginner',
      explanation: json['explanation']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'session': session,
      'question_text': questionText,
      'options': options,
      'correct_answer': correctAnswer,
      'difficulty': difficulty,
      'explanation': explanation,
    };
  }
}
