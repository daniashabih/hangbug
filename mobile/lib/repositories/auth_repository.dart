import '../core/storage/secure_storage_service.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthRepository {
  final AuthService authService;
  final SecureStorageService secureStorage;

  AuthRepository({
    required this.authService,
    required this.secureStorage,
  });

  // Restore authenticated session on app cold-start
  Future<UserModel?> restoreSession() async {
    final token = await secureStorage.getToken();
    if (token == null || token.isEmpty) return null;

    try {
      final user = await authService.getMe();
      await secureStorage.saveUserData(user.toJson());
      return user;
    } catch (_) {
      // Fallback to cached profile if offline
      final cachedJson = await secureStorage.getUserData();
      if (cachedJson != null) {
        return UserModel.fromJson(cachedJson);
      }
      return null;
    }
  }

  // Login
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final result = await authService.login(email: email, password: password);
    await secureStorage.saveToken(result.token);
    await secureStorage.saveUserData(result.user.toJson());
    return result.user;
  }

  // Signup
  Future<UserModel> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    final result = await authService.signup(name: name, email: email, password: password);
    await secureStorage.saveToken(result.token);
    await secureStorage.saveUserData(result.user.toJson());
    return result.user;
  }

  // Update Profile
  Future<UserModel> updateProfile({String? name, String? email}) async {
    final updatedUser = await authService.updateProfile(name: name, email: email);
    await secureStorage.saveUserData(updatedUser.toJson());
    return updatedUser;
  }

  // Delete Account
  Future<void> deleteAccount() async {
    await authService.deleteAccount();
    await secureStorage.clearAll();
  }

  // Logout
  Future<void> logout() async {
    await authService.logout();
    await secureStorage.clearAll();
  }

  // Forgot password
  Future<String> forgotPassword(String email) async {
    return await authService.forgotPassword(email);
  }
}
