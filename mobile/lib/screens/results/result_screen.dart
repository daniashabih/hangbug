import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../models/quiz_result_model.dart';
import '../../widgets/app_button.dart';

class ResultScreen extends StatelessWidget {
  final QuizResultModel result;

  const ResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final isPassed = result.isPassed;
    final isCertified = result.isCertified;
    final incorrectCount = result.total - result.score;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, dResult) {
        if (!didPop) {
          context.go('/home');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quiz Completed'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.go('/home'),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.share_outlined),
              tooltip: 'Share Result',
              onPressed: () => _shareScore(),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              // Hero Icon / Badge
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isPassed
                      ? AppColors.success.withValues(alpha: 0.15)
                      : AppColors.error.withValues(alpha: 0.15),
                  border: Border.all(
                    color: isPassed ? AppColors.success : AppColors.error,
                    width: 3,
                  ),
                ),
                child: Icon(
                  isPassed ? Icons.emoji_events_rounded : Icons.replay_rounded,
                  size: 56,
                  color: isPassed ? AppColors.success : AppColors.error,
                ),
              ),
              const SizedBox(height: 20),

              // Title and Feedback
              Text(
                isCertified
                    ? 'Outstanding! Certified! 🏆'
                    : isPassed
                        ? 'Great Job! You Passed! 🎉'
                        : 'Keep Practicing! 💪',
                style: AppTextStyles.displaySmall.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                isCertified
                    ? 'You scored ${result.percentage.toStringAsFixed(0)}% in ${result.category}. You qualify for a verified certificate!'
                    : isPassed
                        ? 'You passed ${result.category} Session ${result.session} with a solid score.'
                        : 'You need at least 70% to pass this quiz. Review your materials and try again!',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 28),

              // Score Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isPassed
                        ? [
                            AppColors.primary.withValues(alpha: 0.08),
                            AppColors.accent.withValues(alpha: 0.05),
                          ]
                        : [
                            AppColors.error.withValues(alpha: 0.08),
                            AppColors.warning.withValues(alpha: 0.05),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isPassed
                        ? AppColors.primary.withValues(alpha: 0.3)
                        : AppColors.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'YOUR SCORE',
                      style: AppTextStyles.mono.copyWith(
                        fontSize: 12,
                        letterSpacing: 2,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          result.percentage.toStringAsFixed(0),
                          style: AppTextStyles.displayLarge.copyWith(
                            fontSize: 64,
                            fontWeight: FontWeight.w900,
                            color: isPassed ? AppColors.primary : AppColors.error,
                          ),
                        ),
                        Text(
                          '%',
                          style: AppTextStyles.displaySmall.copyWith(
                            fontSize: 32,
                            color: isPassed ? AppColors.primary : AppColors.error,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatCol('Correct', '${result.score}', AppColors.success),
                        Container(width: 1, height: 36, color: AppColors.border),
                        _buildStatCol('Incorrect', '$incorrectCount', AppColors.error),
                        Container(width: 1, height: 36, color: AppColors.border),
                        _buildStatCol('Total', '${result.total}', AppColors.primary),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Certification Callout Banner
              if (isCertified)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.verified_rounded,
                          color: AppColors.accent,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Certificate Unlocked!',
                              style: AppTextStyles.displaySmall.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'View and share your official HangBug verified certificate.',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 32),

              // Action Buttons
              if (isCertified) ...[
                AppButton(
                  text: 'View Certificates',
                  icon: Icons.workspace_premium_rounded,
                  onPressed: () => context.go('/certificates'),
                ),
                const SizedBox(height: 12),
              ],

              AppButton(
                text: 'Try Another Quiz',
                type: isCertified ? AppButtonType.secondary : AppButtonType.primary,
                icon: Icons.explore_rounded,
                onPressed: () => context.go('/explore'),
              ),
              const SizedBox(height: 12),

              AppButton(
                text: 'Back to Dashboard',
                type: AppButtonType.outline,
                icon: Icons.home_rounded,
                onPressed: () => context.go('/home'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCol(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.displaySmall.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _shareScore() {
    Share.share(
      '🎯 I just scored ${result.percentage.toStringAsFixed(0)}% (${result.score}/${result.total}) '
      'on the ${result.category} quiz on HangBug!\n\n'
      'Test your web development and programming skills at: https://hangbug.vercel.app',
      subject: 'My HangBug Quiz Result for ${result.category}',
    );
  }
}
