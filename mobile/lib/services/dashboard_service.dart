import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../models/certificate_model.dart';
import '../models/dashboard_model.dart';

class DashboardService {
  final ApiClient apiClient;

  DashboardService({required this.apiClient});

  // Fetch full user dashboard
  Future<UserDashboardModel> getUserDashboard() async {
    final response = await apiClient.get(ApiEndpoints.userDashboard);
    final data = response.data as Map<String, dynamic>;
    final payload = data['data'] as Map<String, dynamic>? ?? data;
    return UserDashboardModel.fromJson(payload);
  }

  // Fetch earned certificates
  Future<List<CertificateModel>> getCertificates() async {
    final response = await apiClient.get(ApiEndpoints.certificates);
    final data = response.data as Map<String, dynamic>;
    final list = data['certificates'] as List? ?? [];
    return list
        .map((c) => CertificateModel.fromJson(c as Map<String, dynamic>))
        .toList();
  }
}
