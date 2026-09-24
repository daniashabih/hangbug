class ApiEndpoints {
  // Health
  static const String health = '/health';

  // Authentication
  static const String signup = '/auth/signup';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String getMe = '/auth/me';
  static const String updateProfile = '/auth/update-profile';
  static const String deleteAccount = '/auth/delete-account';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String allUsers = '/auth/users';

  // Dashboard & Analytics
  static const String userDashboard = '/dashboard/user';
  static const String adminDashboard = '/dashboard/admin';
  static const String leaderboard = '/dashboard/leaderboard';
  static const String certificates = '/dashboard/certificates';

  // Questions & Assessment
  static const String questions = '/questions';
  static const String questionSessions = '/questions/sessions';
  static const String generateQuestions = '/questions/generate';

  // Technologies / Categories
  static const String categories = '/categories';

  // Results
  static const String saveResult = '/results/save';
  static const String myResults = '/results/my-results';
  static const String resultStats = '/results/stats';

  // Admin Specific
  static const String adminUsers = '/admin/users';
  static const String adminTechnologies = '/admin/technologies';
  static const String adminQuestions = '/admin/questions';
  static const String adminCertificates = '/admin/certificates';
  static const String adminResults = '/admin/results';
}
