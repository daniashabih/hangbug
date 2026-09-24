import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/question_model.dart';
import '../models/quiz_result_model.dart';
import 'core_providers.dart';

class QuizState {
  final String category;
  final int session;
  final List<QuestionModel> questions;
  final int currentIndex;
  final Map<String, int> selectedAnswers;
  final Set<String> flaggedQuestions;
  final int timeLeft;
  final int timePerQuestion;
  final bool isLoading;
  final bool isSubmitted;
  final QuizResultModel? lastResult;
  final int timeTakenSeconds;
  final String? error;

  const QuizState({
    this.category = '',
    this.session = 1,
    this.questions = const [],
    this.currentIndex = 0,
    this.selectedAnswers = const {},
    this.flaggedQuestions = const {},
    this.timeLeft = 60,
    this.timePerQuestion = 60,
    this.isLoading = false,
    this.isSubmitted = false,
    this.lastResult,
    this.timeTakenSeconds = 0,
    this.error,
  });

  QuestionModel? get currentQuestion {
    if (questions.isEmpty || currentIndex >= questions.length) return null;
    return questions[currentIndex];
  }

  int get totalQuestions => questions.length;
  int get answeredCount => selectedAnswers.length;
  bool get isLastQuestion => currentIndex == questions.length - 1;
  bool get isCurrentFlagged =>
      currentQuestion != null && flaggedQuestions.contains(currentQuestion!.id);

  QuizState copyWith({
    String? category,
    int? session,
    List<QuestionModel>? questions,
    int? currentIndex,
    Map<String, int>? selectedAnswers,
    Set<String>? flaggedQuestions,
    int? timeLeft,
    int? timePerQuestion,
    bool? isLoading,
    bool? isSubmitted,
    QuizResultModel? lastResult,
    int? timeTakenSeconds,
    String? error,
    bool clearError = false,
  }) {
    return QuizState(
      category: category ?? this.category,
      session: session ?? this.session,
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      flaggedQuestions: flaggedQuestions ?? this.flaggedQuestions,
      timeLeft: timeLeft ?? this.timeLeft,
      timePerQuestion: timePerQuestion ?? this.timePerQuestion,
      isLoading: isLoading ?? this.isLoading,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      lastResult: lastResult ?? this.lastResult,
      timeTakenSeconds: timeTakenSeconds ?? this.timeTakenSeconds,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class QuizNotifier extends StateNotifier<QuizState> {
  final Ref _ref;
  Timer? _timer;
  DateTime? _quizStartTime;

  QuizNotifier(this._ref) : super(const QuizState());

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Start new assessment session
  Future<void> startQuiz({
    required String category,
    required int session,
    int timePerQuestion = 60,
  }) async {
    _timer?.cancel();
    state = QuizState(
      category: category,
      session: session,
      isLoading: true,
      timePerQuestion: timePerQuestion,
      timeLeft: timePerQuestion,
    );

    try {
      final repository = _ref.read(quizRepositoryProvider);
      final fetchedQuestions = await repository.getQuestions(
        category: category,
        session: session > 0 ? session : null,
      );

      // Randomize questions for fairness
      final questions = [...fetchedQuestions]..shuffle();

      _quizStartTime = DateTime.now();
      state = state.copyWith(
        questions: questions,
        isLoading: false,
        timeLeft: timePerQuestion,
      );

      _startTimer();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.timeLeft <= 1) {
        // Auto-advance on timeout
        if (!state.isLastQuestion) {
          nextQuestion();
        } else {
          submitQuiz();
        }
      } else {
        state = state.copyWith(timeLeft: state.timeLeft - 1);
      }
    });
  }

  void selectAnswer(String questionId, int optionIndex) {
    final updated = Map<String, int>.from(state.selectedAnswers);
    updated[questionId] = optionIndex;
    state = state.copyWith(selectedAnswers: updated);
  }

  void toggleFlag(String questionId) {
    final updated = Set<String>.from(state.flaggedQuestions);
    if (updated.contains(questionId)) {
      updated.remove(questionId);
    } else {
      updated.add(questionId);
    }
    state = state.copyWith(flaggedQuestions: updated);
  }

  void nextQuestion() {
    if (state.currentIndex < state.questions.length - 1) {
      state = state.copyWith(
        currentIndex: state.currentIndex + 1,
        timeLeft: state.timePerQuestion,
      );
    }
  }

  void prevQuestion() {
    if (state.currentIndex > 0) {
      state = state.copyWith(
        currentIndex: state.currentIndex - 1,
        timeLeft: state.timePerQuestion,
      );
    }
  }

  void jumpToQuestion(int index) {
    if (index >= 0 && index < state.questions.length) {
      state = state.copyWith(
        currentIndex: index,
        timeLeft: state.timePerQuestion,
      );
    }
  }

  // Calculate score and submit assessment to MongoDB Atlas via backend
  Future<QuizResultModel?> submitQuiz() async {
    _timer?.cancel();
    int score = 0;

    for (final q in state.questions) {
      final selectedIdx = state.selectedAnswers[q.id];
      if (selectedIdx != null && selectedIdx < q.options.length) {
        final chosenText = q.options[selectedIdx].trim().toLowerCase();
        final correctText = q.correctAnswer.trim().toLowerCase();
        if (chosenText == correctText) {
          score++;
        }
      }
    }

    final total = state.questions.length;
    final percentage = total > 0 ? ((score / total) * 100).roundToDouble() : 0.0;
    final durationSeconds = _quizStartTime != null
        ? DateTime.now().difference(_quizStartTime!).inSeconds
        : 0;

    state = state.copyWith(
      isLoading: true,
      timeTakenSeconds: durationSeconds,
    );

    try {
      final repository = _ref.read(quizRepositoryProvider);
      final result = await repository.saveResult(
        category: state.category,
        session: state.session,
        score: score,
        total: total,
        percentage: percentage,
      );

      state = state.copyWith(
        isLoading: false,
        isSubmitted: true,
        lastResult: result,
      );
      return result;
    } catch (e) {
      // Create local fallback result if network error occurs while submitting
      final fallbackResult = QuizResultModel(
        id: 'HB-OFFLINE-${DateTime.now().millisecondsSinceEpoch}',
        category: state.category,
        session: state.session,
        score: score,
        total: total,
        percentage: percentage,
        createdAt: DateTime.now().toIso8601String(),
      );

      state = state.copyWith(
        isLoading: false,
        isSubmitted: true,
        lastResult: fallbackResult,
      );
      return fallbackResult;
    }
  }

  void resetQuiz() {
    _timer?.cancel();
    state = const QuizState();
  }
}

final quizProvider = StateNotifierProvider<QuizNotifier, QuizState>((ref) {
  return QuizNotifier(ref);
});
