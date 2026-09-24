import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hangbug/core/constants/app_strings.dart';
import 'package:hangbug/core/theme/app_theme.dart';
import 'package:hangbug/models/certificate_model.dart';
import 'package:hangbug/models/quiz_result_model.dart';
import 'package:hangbug/widgets/app_button.dart';

void main() {
  testWidgets('AppButton widget renders and triggers callback', (WidgetTester tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: AppButton(
            text: 'Test Button',
            onPressed: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Test Button'), findsOneWidget);
    await tester.tap(find.text('Test Button'));
    expect(tapped, isTrue);
  });

  testWidgets('AppButton loading state shows CircularProgressIndicator', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: AppButton(
            text: 'Submit Quiz',
            isLoading: true,
          ),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  test('AppStrings constants verify app branding and tagline', () {
    expect(AppStrings.appName, equals('Hangbug'));
    expect(AppStrings.appTagline, equals('Learn. Quiz. Prove Your Skills.'));
  });

  test('CertificateModel computes verificationUrl, percentage and isPassed correctly', () {
    const cert = CertificateModel(
      id: 'cert_12345',
      category: 'Flutter',
      score: 85,
      date: '2026-09-23',
    );

    expect(cert.percentage, equals(85.0));
    expect(cert.issueDate, equals('2026-09-23'));
    expect(cert.isPassed, isTrue);
    expect(cert.verificationUrl, contains('cert_12345'));
  });

  test('QuizResultModel calculates pass and cert thresholds correctly', () {
    const passedResult = QuizResultModel(
      id: 'res_01',
      category: 'Dart',
      score: 16,
      total: 20,
      percentage: 80.0,
    );

    expect(passedResult.isPassed, isTrue);
    expect(passedResult.isCertified, isTrue);

    const failedResult = QuizResultModel(
      id: 'res_02',
      category: 'Dart',
      score: 10,
      total: 20,
      percentage: 50.0,
    );

    expect(failedResult.isPassed, isFalse);
    expect(failedResult.isCertified, isFalse);
  });
}
