import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/config/app_config.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/core_providers.dart';
import '../../providers/dashboard_provider.dart';
import '../../widgets/app_button.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _pushNotifications = true;
  bool _quizReminders = true;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final isGuest = authState.isGuest;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Information Section
            _buildSectionHeader('Account Details'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _buildDetailRow('Name', user?.name ?? 'Learner'),
                  const Divider(height: 20),
                  _buildDetailRow('Email', isGuest ? 'Local Guest Session' : (user?.email ?? 'N/A')),
                  const Divider(height: 20),
                  _buildDetailRow(
                    'Account Type',
                    isGuest
                        ? 'Guest Mode (Testing)'
                        : user?.isAdmin == true
                            ? 'Administrator'
                            : 'Learner',
                  ),
                  const Divider(height: 20),
                  _buildDetailRow('API Server', AppConfig.apiBaseUrl),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Preferences Section
            _buildSectionHeader('Preferences'),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text('Learning Reminders', style: AppTextStyles.labelBold),
                    subtitle: Text('Get daily notifications to test your tech skills', style: AppTextStyles.bodySmall),
                    value: _quizReminders,
                    activeTrackColor: AppColors.primary,
                    onChanged: (val) => setState(() => _quizReminders = val),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: Text('System Announcements', style: AppTextStyles.labelBold),
                    subtitle: Text('News on new quiz categories and certifications', style: AppTextStyles.bodySmall),
                    value: _pushNotifications,
                    activeTrackColor: AppColors.primary,
                    onChanged: (val) => setState(() => _pushNotifications = val),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Legal & Compliance Section
            _buildSectionHeader('Compliance & Policies'),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.primary),
                    title: Text('Privacy Policy', style: AppTextStyles.labelBold),
                    subtitle: Text('Data safety and collection practices', style: AppTextStyles.bodySmall),
                    trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                    onTap: () => context.push('/legal/privacy'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.description_outlined, color: AppColors.primary),
                    title: Text('Terms of Service', style: AppTextStyles.labelBold),
                    subtitle: Text('Platform guidelines and certificate validity', style: AppTextStyles.bodySmall),
                    trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                    onTap: () => context.push('/legal/terms'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Danger Zone - Account Deletion / Reset Guest Data
            _buildSectionHeader('Danger Zone', color: AppColors.error),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isGuest ? Icons.restart_alt_rounded : Icons.warning_amber_rounded,
                        color: AppColors.error,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isGuest ? 'Reset Guest Test Data' : 'Delete Account & Data',
                        style: AppTextStyles.labelBold.copyWith(
                          color: AppColors.error,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isGuest
                        ? 'Clear all locally stored guest quiz scores, streaks, and generated test certificates from this device.'
                        : 'Permanently delete your HangBug account, along with all your quiz attempt histories, scores, earned certificates, and credentials. This action is irreversible and cannot be undone.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    text: isGuest ? 'Reset Guest Data' : 'Delete My Account',
                    type: AppButtonType.outline,
                    icon: isGuest ? Icons.restart_alt_rounded : Icons.delete_forever_rounded,
                    onPressed: () => isGuest ? _confirmResetGuestData() : _confirmAccountDeletion(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.mono.copyWith(
          fontSize: 11,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w600,
          color: color ?? AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: AppTextStyles.labelBold,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  void _confirmResetGuestData() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.restart_alt_rounded, color: AppColors.error),
            SizedBox(width: 8),
            Text('Reset Guest Data?'),
          ],
        ),
        content: Text(
          'This will clear your local quiz scores, streak, and unlocked guest certificates.\n\nAre you sure you want to proceed?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(dashboardRepositoryProvider).resetGuestData();
              ref.invalidate(userDashboardProvider);
              ref.invalidate(certificatesProvider);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Guest test data has been reset.'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            child: const Text('Reset Data'),
          ),
        ],
      ),
    );
  }

  void _confirmAccountDeletion() {
    final confirmationController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) {
          final isConfirmed = confirmationController.text.trim().toUpperCase() == 'DELETE';

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.delete_forever_rounded, color: AppColors.error),
                SizedBox(width: 8),
                Text('Delete Account?'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Are you absolutely sure? All your data, quiz scores, and verified certificates will be permanently removed from HangBug servers.\n\n'
                  'To confirm, type DELETE below:',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmationController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Type DELETE',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  onChanged: (val) {
                    setDialogState(() {});
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                ),
                onPressed: isConfirmed
                    ? () async {
                        Navigator.of(ctx).pop();
                        final success = await ref.read(authProvider.notifier).deleteAccount();
                        if (!mounted) return;
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Your account and associated data have been permanently deleted.'),
                              backgroundColor: AppColors.primary,
                            ),
                          );
                          context.go('/login');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                ref.read(authProvider).error ?? 'Failed to delete account. Please try again.',
                              ),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      }
                    : null,
                child: const Text('Permanently Delete'),
              ),
            ],
          );
        },
      ),
    );
  }
}
