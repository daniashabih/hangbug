class AppConfig {
  static const String appName = 'Hangbug';
  static const String appVersion = '1.0.0';
  static const int appBuildNumber = 1;

  // Production API Base URL (Vercel Live Deployment)
  static const String defaultProductionApiUrl = 'https://hangbug.vercel.app/api';

  // Configurable at compile time via: --dart-define=API_URL=https://...
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: defaultProductionApiUrl,
  );

  static const String apiBaseUrl = baseUrl;

  // Legal and Documentation URLs
  static const String privacyPolicyUrl = 'https://hangbug.vercel.app/privacy';
  static const String termsOfServiceUrl = 'https://hangbug.vercel.app/terms';
  static const String supportEmail = 'support@hangbug.com';
  static const String websiteUrl = 'https://hangbug.vercel.app';
}
