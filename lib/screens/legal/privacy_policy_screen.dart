import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'HangBug Privacy Policy',
              style: AppTextStyles.displaySmall.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Last Updated: September 2026',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: '1. Introduction',
              body:
                  'Welcome to HangBug ("we," "our," or "us"). HangBug is a web and mobile technology quiz and certification platform. We are committed to protecting your personal information and your right to privacy. This Privacy Policy explains how we collect, use, and protect your information when you use our Android application.',
            ),
            _buildSection(
              title: '2. Information We Collect',
              body:
                  'We only collect information necessary to provide our educational and certification services:\n\n'
                  '• Personal Information: Your name and email address provided during account creation.\n'
                  '• Quiz Performance Data: Technologies attempted, question responses, time spent, completion scores, and issued certificates.\n'
                  '• Authentication Data: Securely salted and hashed credentials and cryptographically signed session tokens (JWT). We never store plain-text passwords.',
            ),
            _buildSection(
              title: '3. How We Use Your Data',
              body:
                  'We use the collected information exclusively to:\n\n'
                  '• Authenticate your identity and maintain your active learning session.\n'
                  '• Track your learning progress, quiz history, and skill assessment levels.\n'
                  '• Generate, issue, and cryptographically verify your completion certificates.\n'
                  '• Provide administrative oversight and maintain platform integrity.',
            ),
            _buildSection(
              title: '4. Data Sharing & Third Parties',
              body:
                  'HangBug does NOT sell, rent, trade, or monetize your personal data. Your data is never shared with third-party advertisers. All network transmissions are strictly encrypted in transit using industry-standard TLS 1.3 HTTPS protocols.',
            ),
            _buildSection(
              title: '5. Account & Data Deletion Rights',
              body:
                  'In compliance with Google Play Store User Data policies, you have complete control over your data:\n\n'
                  '• In-App Deletion: You can permanently delete your HangBug account and all associated records (quiz histories, scores, certificates) directly inside the app under Profile → Settings → Delete Account & Data.\n'
                  '• Web / Support Request: You can also request complete account deletion at any time by contacting support@hangbug.com or visiting https://hangbug.vercel.app.\n\n'
                  'Upon confirmation, all personal identifiers and quiz records are permanently erased from our databases.',
            ),
            _buildSection(
              title: '6. Children\'s Privacy',
              body:
                  'HangBug is designed for software developers, students, and technology learners. We do not knowingly collect personal identifiable information from children under the age of 13.',
            ),
            _buildSection(
              title: '7. Contact Us',
              body:
                  'If you have questions, comments, or concerns regarding this policy or our data practices, please reach out to us at:\n\n'
                  'Email: privacy@hangbug.com\n'
                  'Website: https://hangbug.vercel.app',
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String body}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.labelBold.copyWith(
              fontSize: 16,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
