class AppStrings {
  static const String appName = 'Hangbug';
  static const String appTagline = 'Learn. Quiz. Prove Your Skills.';
  
  // Navigation
  static const String home = 'Home';
  static const String explore = 'Explore';
  static const String certificates = 'Certificates';
  static const String profile = 'Profile';
  static const String admin = 'Admin';

  // Common Errors
  static const String noInternetError = 'Unable to connect to Hangbug. Please check your internet connection and try again.';
  static const String timeoutError = 'Connection timed out. Please try again.';
  static const String unauthorizedError = 'Session expired. Please log in again.';
  static const String serverError = 'Something went wrong on our servers. Please try again shortly.';
  static const String unknownError = 'An unexpected error occurred. Please try again.';

  // Empty States
  static const String noCertificates = "You haven't earned any certificates yet.";
  static const String noCertificatesSubtitle = 'Complete a quiz with an 80%+ score to unlock your first verified certificate.';
  static const String noQuizzes = 'No quiz attempts found.';
  static const String noTechnologies = 'No technologies found.';

  // Confirmation Prompts
  static const String quitQuizTitle = 'Quit Assessment?';
  static const String quitQuizMessage = 'Your progress for this attempt will be discarded. Are you sure you want to exit?';
  static const String submitQuizTitle = 'Submit Assessment?';
  static const String deleteAccountTitle = 'Delete Account Permanently?';
  static const String deleteAccountMessage = 'This will permanently remove your profile, assessment history, and certificates from our database. This action cannot be undone.';
}
