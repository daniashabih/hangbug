import '../models/certificate_model.dart';
import '../models/dashboard_model.dart';
import '../services/dashboard_service.dart';
import '../services/guest_storage_service.dart';

class DashboardRepository {
  final DashboardService dashboardService;
  final GuestStorageService guestStorage;

  DashboardRepository({
    required this.dashboardService,
    required this.guestStorage,
  });

  Future<UserDashboardModel> getUserDashboard({bool isGuest = false}) async {
    if (isGuest) {
      return await guestStorage.getGuestDashboard();
    }
    return await dashboardService.getUserDashboard();
  }

  Future<List<CertificateModel>> getCertificates({bool isGuest = false}) async {
    if (isGuest) {
      return await guestStorage.getGuestCertificates();
    }
    return await dashboardService.getCertificates();
  }

  Future<void> resetGuestData() async {
    await guestStorage.resetGuestData();
  }
}
