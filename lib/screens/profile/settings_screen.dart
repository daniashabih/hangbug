import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.45),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (ctx, a1, a2) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim, secAnim, child) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
        return ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1.0).animate(curved),
          child: FadeTransition(
            opacity: anim,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Center(
                child: Container(
                  width: 360,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.14),
                        blurRadius: 32,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFFEF2F2),
                            border: Border.all(color: const Color(0xFFFEE2E2), width: 1.5),
                          ),
                          child: const Icon(Icons.restart_alt_rounded, color: Color(0xFFDC2626), size: 28),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Reset Guest Data?',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'This will clear your local quiz scores, streak, and unlocked guest certificates from this device.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 13.5,
                            color: AppColors.textSecondary,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 44,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF8FAFC),
                                    foregroundColor: AppColors.textPrimary,
                                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    elevation: 0,
                                    padding: EdgeInsets.zero,
                                  ),
                                  onPressed: () => Navigator.of(ctx).pop(),
                                  child: Text('Cancel', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SizedBox(
                                height: 44,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFDC2626),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    padding: EdgeInsets.zero,
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
                                  child: Text('Reset Data', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _confirmAccountDeletion() {
    final confirmationController = TextEditingController();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.45),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (ctx, a1, a2) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim, secAnim, child) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            final isConfirmed = confirmationController.text.trim().toUpperCase() == 'DELETE';

            return ScaleTransition(
              scale: Tween<double>(begin: 0.92, end: 1.0).animate(curved),
              child: FadeTransition(
                opacity: anim,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Center(
                    child: Container(
                      width: 360,
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.14),
                            blurRadius: 32,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFFEF2F2),
                                border: Border.all(color: const Color(0xFFFEE2E2), width: 1.5),
                              ),
                              child: const Icon(Icons.delete_forever_rounded, color: Color(0xFFDC2626), size: 28),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Delete Account?',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 19,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'All your quiz attempts, scores, and verified certificates will be permanently deleted from Hangbug.\n\nType DELETE to confirm:',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 14),
                            TextField(
                              controller: confirmationController,
                              autofocus: true,
                              decoration: InputDecoration(
                                hintText: 'Type DELETE',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                              ),
                              onChanged: (val) => setDialogState(() {}),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 44,
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: const Color(0xFFF8FAFC),
                                        foregroundColor: AppColors.textPrimary,
                                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        elevation: 0,
                                        padding: EdgeInsets.zero,
                                      ),
                                      onPressed: () => Navigator.of(dialogCtx).pop(),
                                      child: Text('Cancel', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: SizedBox(
                                    height: 44,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFDC2626),
                                        foregroundColor: Colors.white,
                                        disabledBackgroundColor: const Color(0xFFFCA5A5),
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        padding: EdgeInsets.zero,
                                      ),
                                      onPressed: isConfirmed
                                          ? () async {
                                              Navigator.of(dialogCtx).pop();
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
                                      child: Text('Delete', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
