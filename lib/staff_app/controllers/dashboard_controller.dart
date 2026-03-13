import 'package:get/get.dart';
import '../api/api_service.dart';

class DashboardController extends GetxController {
  var isLoading = false.obs;
  var dashboardData = {}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    try {
      isLoading(true);
      final data = await ApiService.getDashboardAttendance();
      dashboardData.value = data;
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
    }
  }

  String get staffCount =>
      (dashboardData['infodata']?['staff_count'] ?? 0).toString();
  String get studentAttendanceCount =>
      (dashboardData['infodata']?['student_attendance_count'] ?? 0).toString();
  String get totalTodaysOutingCount =>
      (dashboardData['infodata']?['total_todays_outing_count'] ?? 0).toString();
  String get staffAttendanceCount =>
      (dashboardData['infodata']?['staff_attendance_count'] ?? 0).toString();

  List<dynamic> get classAttendanceSummary =>
      dashboardData['infodata']?['class_attendance_summary'] ?? [];
}
