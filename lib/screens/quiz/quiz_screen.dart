import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/quiz_provider.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_state_widget.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final String category;
  final int session;

  const QuizScreen({
    super.key,
    required this.category,
    required this.session,
  });

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(quizProvider.notifier).startQuiz(
            category: widget.category,
            session: widget.session,
          );
    });
  }

  void _showQuitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(AppStrings.quitQuizTitle),
        content: const Text(AppStrings.quitQuizMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Resume Quiz'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(quizProvider.notifier).resetQuiz();
              context.pop();
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  void _showSubmitConfirmation(int answered, int total) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(AppStrings.submitQuizTitle),
        content: Text(
          'You answered $answered of $total questions.\n\n'
          '${total - answered > 0 ? "⚠️ ${total - answered} question(s) are still unanswered." : "All questions have been answered."}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Review Answers'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(100, 40),
            ),
            onPressed: () async {
              Navigator.of(context).pop();
              final result = await ref.read(quizProvider.notifier).submitQuiz();
              if (result != null && mounted) {
                context.go('/quiz/results', extra: result);
              }
            },
            child: const Text('Submit Now'),
          ),
        ],
      ),
    );
  }

  void _showQuestionNavigator(QuizState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question Navigator',
                  style: AppTextStyles.displaySmall.copyWith(fontSize: 18),
                ),
                Text(
                  '${state.answeredCount}/${state.totalQuestions} Answered',
                  style: AppTextStyles.mono.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.1,
                ),
                itemCount: state.questions.length,
                itemBuilder: (context, index) {
                  final q = state.questions[index];
                  final isCurrent = state.currentIndex == index;
                  final isAnswered = state.selectedAnswers.containsKey(q.id);
                  final isFlagged = state.flaggedQuestions.contains(q.id);

                  Color bg = AppColors.mutedBg;
                  Color fg = AppColors.textPrimary;
                  BorderSide side = const BorderSide(color: AppColors.border);

                  if (isCurrent) {
                    bg = AppColors.primary;
                    fg = Colors.white;
                    side = const BorderSide(color: AppColors.primary, width: 2);
                  } else if (isAnswered) {
                    bg = AppColors.accentLight;
                    fg = AppColors.primary;
                    side = const BorderSide(color: AppColors.accentBorder);
                  }

                  return Stack(
                    children: [
                      Positioned.fill(
                        child: Material(
                          color: bg,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: side,
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              ref.read(quizProvider.notifier).jumpToQuestion(index);
                              Navigator.of(context).pop();
                            },
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: AppTextStyles.mono.copyWith(
                                  color: fg,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (isFlagged)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(quizProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _showQuitConfirmation();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: _showQuitConfirmation,
            tooltip: 'Exit Quiz',
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                state.category.isNotEmpty ? state.category : widget.category,
                style: AppTextStyles.displaySmall.copyWith(fontSize: 16),
              ),
              Text(
                state.session == 0 ? 'All Sessions' : 'Session ${state.session}',
                style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
              ),
            ],
          ),
          actions: [
            if (!state.isLoading && state.questions.isNotEmpty) ...[
              // Question Matrix Grid button
              IconButton(
                icon: const Icon(Icons.grid_view_rounded, size: 20),
                onPressed: () => _showQuestionNavigator(state),
                tooltip: 'Question Map',
              ),
            ],
            const SizedBox(width: 6),
          ],
        ),
        body: state.isLoading
            ? const LoadingStateWidget(message: 'Preparing your assessment...')
            : state.questions.isEmpty
                ? EmptyStateWidget(
                    title: 'No questions available',
                    subtitle: 'There are no questions in this track and session.',
                    buttonText: 'Back to Explore',
                    onButtonPressed: () => context.pop(),
                  )
                : SafeArea(
                    child: Column(
                      children: [
                        // Progress bar across questions
                        LinearProgressIndicator(
                          value: (state.currentIndex + 1) / state.totalQuestions,
                          backgroundColor: AppColors.border,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                          minHeight: 4,
                        ),

                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Question Header & Flag Toggle
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.mutedBg,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Question ${state.currentIndex + 1} of ${state.totalQuestions}',
                                        style: AppTextStyles.labelBold.copyWith(
                                          color: AppColors.textSecondary,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        state.isCurrentFlagged
                                            ? Icons.bookmark_rounded
                                            : Icons.bookmark_border_rounded,
                                        color: state.isCurrentFlagged
                                            ? AppColors.accent
                                            : AppColors.textSecondary,
                                        size: 22,
                                      ),
                                      onPressed: () {
                                        if (state.currentQuestion != null) {
                                          ref
                                              .read(quizProvider.notifier)
                                              .toggleFlag(state.currentQuestion!.id);
                                        }
                                      },
                                      tooltip: 'Flag for review',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // Question Card
                                Container(
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Text(
                                    state.currentQuestion?.questionText ?? '',
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      height: 1.45,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // Options Deck
                                if (state.currentQuestion != null)
                                  ...state.currentQuestion!.options.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final optionText = entry.value;
                                    final questionId = state.currentQuestion!.id;
                                    final isSelected =
                                        state.selectedAnswers[questionId] == index;
                                    final optionLetter =
                                        String.fromCharCode(65 + index); // A, B, C, D

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      decoration: BoxDecoration(
                                        color: isSelected ? AppColors.accentLight : Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: isSelected
                                              ? AppColors.primary
                                              : AppColors.border,
                                          width: isSelected ? 2 : 1,
                                        ),
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.circular(16),
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(16),
                                          onTap: () {
                                            ref
                                                .read(quizProvider.notifier)
                                                .selectAnswer(questionId, index);
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0,
                                              vertical: 14.0,
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 32,
                                                  height: 32,
                                                  decoration: BoxDecoration(
                                                    color: isSelected
                                                        ? AppColors.primary
                                                        : AppColors.mutedBg,
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      optionLetter,
                                                      style: AppTextStyles.mono.copyWith(
                                                        color: isSelected
                                                            ? Colors.white
                                                            : AppColors.textPrimary,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 14),
                                                Expanded(
                                                  child: Text(
                                                    optionText,
                                                    style: AppTextStyles.bodyMedium.copyWith(
                                                      fontWeight: isSelected
                                                          ? FontWeight.w700
                                                          : FontWeight.normal,
                                                      color: isSelected
                                                          ? AppColors.primary
                                                          : AppColors.textPrimary,
                                                    ),
                                                  ),
                                                ),
                                                if (isSelected)
                                                  const Icon(
                                                    Icons.check_circle_rounded,
                                                    color: AppColors.primary,
                                                    size: 20,
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                              ],
                            ),
                          ),
                        ),

                        // Bottom Navigation Action Dock
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            border: Border(
                              top: BorderSide(color: AppColors.border, width: 1),
                            ),
                          ),
                          child: Row(
                            children: [
                              OutlinedButton(
                                onPressed: state.currentIndex > 0
                                    ? () => ref.read(quizProvider.notifier).prevQuestion()
                                    : null,
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(80, 44),
                                  padding: const EdgeInsets.symmetric(horizontal: 14),
                                ),
                                child: const Text('Prev'),
                              ),
                              const Spacer(),
                              Text(
                                '${state.currentIndex + 1} / ${state.totalQuestions}',
                                style: AppTextStyles.mono.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const Spacer(),
                              if (state.isLastQuestion)
                                ElevatedButton(
                                  onPressed: () => _showSubmitConfirmation(
                                    state.answeredCount,
                                    state.totalQuestions,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(100, 44),
                                  ),
                                  child: const Text('Submit'),
                                )
                              else
                                ElevatedButton(
                                  onPressed: () =>
                                      ref.read(quizProvider.notifier).nextQuestion(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(80, 44),
                                    padding: const EdgeInsets.symmetric(horizontal: 14),
                                  ),
                                  child: const Text('Next'),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
