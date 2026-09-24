import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../models/user_model.dart';

class AuthService {
  final ApiClient apiClient;

  AuthService({required this.apiClient});

  // Login
  Future<({UserModel user, String token})> login({
    required String email,
    required String password,
  }) async {
    final response = await apiClient.post(
      ApiEndpoints.login,
      data: {
        'email': email.trim().toLowerCase(),
        'password': password,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final userJson = data['user'] as Map<String, dynamic>;
    final token = data['token']?.toString() ?? '';

    return (
      user: UserModel.fromJson(userJson),
      token: token,
    );
  }

  // Signup
  Future<({UserModel user, String token})> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await apiClient.post(
      ApiEndpoints.signup,
      data: {
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'password': password,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final userJson = data['user'] as Map<String, dynamic>;
    final token = data['token']?.toString() ?? '';

    return (
      user: UserModel.fromJson(userJson),
      token: token,
    );
  }

  // Get current user profile (using stored token)
  Future<UserModel> getMe() async {
    final response = await apiClient.get(ApiEndpoints.getMe);
    final data = response.data as Map<String, dynamic>;
    final userJson = data['user'] as Map<String, dynamic>;
    return UserModel.fromJson(userJson);
  }

  // Update profile
  Future<UserModel> updateProfile({
    String? name,
    String? email,
  }) async {
    final response = await apiClient.put(
      ApiEndpoints.updateProfile,
      data: {
        if (name != null) 'name': name.trim(),
        if (email != null) 'email': email.trim().toLowerCase(),
      },
    );

    final data = response.data as Map<String, dynamic>;
    final userJson = data['user'] as Map<String, dynamic>;
    return UserModel.fromJson(userJson);
  }

  // Delete account (Google Play requirement)
  Future<void> deleteAccount() async {
    await apiClient.delete(ApiEndpoints.deleteAccount);
  }

  // Logout
  Future<void> logout() async {
    try {
      await apiClient.post(ApiEndpoints.logout);
    } catch (_) {
      // Ignore network errors on logout to ensure local wipe always proceeds
    }
  }

  // Forgot Password
  Future<String> forgotPassword(String email) async {
    final response = await apiClient.post(
      ApiEndpoints.forgotPassword,
      data: {'email': email.trim().toLowerCase()},
    );
    final data = response.data as Map<String, dynamic>;
    return data['message']?.toString() ?? 'Password reset link sent.';
  }
}
