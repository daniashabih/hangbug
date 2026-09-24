import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/date_formatter.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/error_state_widget.dart';
import '../../widgets/loading_state_widget.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(adminDashboardProvider);
    final currentPeriod = ref.watch(adminDashboardPeriodProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Metrics',
            onPressed: () => ref.invalidate(adminDashboardProvider),
          ),
        ],
      ),
      body: dashboardAsync.when(
        loading: () => const LoadingStateWidget(message: 'Loading administrative analytics...'),
        error: (err, stack) => ErrorStateWidget(
          message: 'Failed to load admin metrics: ${err.toString()}',
          onRetry: () => ref.invalidate(adminDashboardProvider),
        ),
        data: (data) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(adminDashboardProvider),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Period Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Overview Metrics',
                      style: AppTextStyles.displaySmall.copyWith(fontSize: 18),
                    ),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: '7d', label: Text('7d')),
                        ButtonSegment(value: '30d', label: Text('30d')),
                        ButtonSegment(value: 'year', label: Text('1y')),
                      ],
                      selected: {currentPeriod},
                      onSelectionChanged: (newSelection) {
                        ref.read(adminDashboardPeriodProvider.notifier).state =
                            newSelection.first;
                      },
                      style: ButtonStyle(
                        visualDensity: VisualDensity.compact,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Primary KPI Cards Grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.45,
                  children: [
                    _buildKpiCard(
                      label: 'Total Users',
                      value: '${data.stats.totalUsers}',
                      icon: Icons.people_alt_rounded,
                      color: AppColors.primary,
                    ),
                    _buildKpiCard(
                      label: 'Questions in Bank',
                      value: '${data.stats.totalQuestions}',
                      icon: Icons.quiz_rounded,
                      color: AppColors.accent,
                    ),
                    _buildKpiCard(
                      label: 'Quiz Attempts',
                      value: '${data.stats.totalAttempts}',
                      icon: Icons.play_lesson_rounded,
                      color: AppColors.success,
                    ),
                    _buildKpiCard(
                      label: 'Certificates',
                      value: '${data.stats.totalCertificates}',
                      icon: Icons.workspace_premium_rounded,
                      color: AppColors.warning,
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Pass rate and average score banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundAlt,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetricItem(
                        'Pass Rate',
                        '${data.stats.totalAttempts > 0 ? ((data.stats.passedAttempts / data.stats.totalAttempts) * 100).toStringAsFixed(1) : 0}%',
                        AppColors.success,
                      ),
                      Container(width: 1, height: 32, color: AppColors.border),
                      _buildMetricItem(
                        'Average Score',
                        '${data.stats.averageScore.toStringAsFixed(1)}%',
                        AppColors.primary,
                      ),
                      Container(width: 1, height: 32, color: AppColors.border),
                      _buildMetricItem(
                        'Categories',
                        '${data.stats.totalTechnologies}',
                        AppColors.textPrimary,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Management Tools
                Text(
                  'Management Tools',
                  style: AppTextStyles.displaySmall.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 12),
                _buildToolTile(
                  icon: Icons.format_list_bulleted_rounded,
                  title: 'Manage Questions',
                  subtitle: 'Create, inspect, filter, and delete quiz questions',
                  color: AppColors.primary,
                  onTap: () => context.push('/admin/questions'),
                ),
                const SizedBox(height: 8),
                _buildToolTile(
                  icon: Icons.category_rounded,
                  title: 'Manage Categories',
                  subtitle: 'Add new technology tracks or remove obsolete ones',
                  color: AppColors.accent,
                  onTap: () => context.push('/admin/categories'),
                ),
                const SizedBox(height: 8),
                _buildToolTile(
                  icon: Icons.people_outline_rounded,
                  title: 'Manage Users',
                  subtitle: 'Inspect registered accounts and manage permissions',
                  color: AppColors.success,
                  onTap: () => context.push('/admin/users'),
                ),
                const SizedBox(height: 8),
                _buildToolTile(
                  icon: Icons.auto_awesome_rounded,
                  title: 'AI Question Generator',
                  subtitle: 'Generate tailored questions using Gemini / AI engine',
                  color: const Color(0xFF673AB7),
                  onTap: () => context.push('/admin/ai-generator'),
                ),

                const SizedBox(height: 28),

                // Recent Attempts Section
                Text(
                  'Recent Attempts',
                  style: AppTextStyles.displaySmall.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 12),
                if (data.recentAttempts.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      'No recent quiz attempts found.',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    ),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: data.recentAttempts.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final attempt = data.recentAttempts[index];
                        return ListTile(
                          title: Text(
                            attempt.userName,
                            style: AppTextStyles.labelBold,
                          ),
                          subtitle: Text(
                            '${attempt.category} • ${attempt.percentage}% • ${DateFormatter.formatDate(attempt.createdAt)}',
                            style: AppTextStyles.bodySmall,
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: attempt.passed
                                  ? AppColors.success.withValues(alpha: 0.12)
                                  : AppColors.error.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              attempt.passed ? 'PASSED' : 'FAILED',
                              style: AppTextStyles.mono.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: attempt.passed ? AppColors.success : AppColors.error,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKpiCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(icon, size: 20, color: color),
            ],
          ),
          Text(
            value,
            style: AppTextStyles.displaySmall.copyWith(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.displaySmall.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildToolTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(title, style: AppTextStyles.labelBold),
        subtitle: Text(subtitle, style: AppTextStyles.bodySmall),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        onTap: onTap,
      ),
    );
  }
}
