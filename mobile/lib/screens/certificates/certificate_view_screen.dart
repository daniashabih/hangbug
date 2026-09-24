import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../models/certificate_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/certificate_card.dart';

class CertificateViewScreen extends ConsumerWidget {
  final CertificateModel certificate;

  const CertificateViewScreen({super.key, required this.certificate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final learnerName = certificate.learnerName ?? user?.name ?? 'Learner';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verified Certificate'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share Certificate',
            onPressed: () => _shareCertificate(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            // The Certificate Card widget with QR code
            CertificateCard(
              certificate: certificate,
              learnerName: learnerName,
            ),
            const SizedBox(height: 28),

            // Verification Info Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.backgroundAlt,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.security_rounded,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This credential is authenticated and permanently verified on the HangBug platform.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Share Button
            AppButton(
              text: 'Share Certificate Link',
              icon: Icons.share_rounded,
              onPressed: () => _shareCertificate(),
            ),
            const SizedBox(height: 12),

            // Copy Link Button
            AppButton(
              text: 'Copy Verification URL',
              type: AppButtonType.outline,
              icon: Icons.copy_rounded,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: certificate.verificationUrl));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Verification link copied to clipboard!'),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _shareCertificate() {
    Share.share(
      '🎓 View my official verified certificate in ${certificate.category} (Score: ${certificate.score}%) '
      'issued by HangBug: ${certificate.verificationUrl}',
      subject: 'My HangBug ${certificate.category} Certificate',
    );
  }
}
