import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:student_app/staff_app/pages/home_dashboard_page.dart';
import 'package:student_app/staff_app/pages/login_page.dart';
import 'package:student_app/staff_app/pages/staff_auth_wrapper.dart';
import 'package:get_storage/get_storage.dart';
import 'package:student_app/staff_app/pages/splash_page.dart';
import 'package:student_app/staff_app/pages/verify_attendance_page.dart';
import 'package:student_app/student_app/dashboard_page.dart';

// Staff Controllers
import 'package:student_app/staff_app/controllers/theme_controller.dart'
    as staff;
import 'package:student_app/staff_app/controllers/auth_controller.dart';
import 'package:student_app/staff_app/controllers/main_controller.dart';
import 'package:student_app/staff_app/controllers/hostel_controller.dart';
import 'package:student_app/theme_controllers.dart';

// Staff Theme
import 'package:student_app/staff_app/theme/app_theme.dart';

// Staff Pages
import 'package:student_app/staff_app/pages/profile_page.dart';
import 'package:student_app/staff_app/pages/staff_list_page.dart';
import 'package:student_app/staff_app/pages/outing_list_page.dart';
import 'package:student_app/staff_app/pages/outing_pending_listPage.dart';
import 'package:student_app/staff_app/pages/subject_marks_upload_page.dart';
import 'package:student_app/staff_app/pages/Staff_Attendance_Page.dart';
import 'package:student_app/staff_app/pages/ClassAttendancePage.dart';
import 'package:student_app/staff_app/pages/exam_category_list_page.dart';
import 'package:student_app/staff_app/pages/exam_list_page.dart';
import 'package:student_app/staff_app/pages/student_attendance.dart';
import 'package:student_app/staff_app/pages/Room_page.dart';
import 'package:student_app/staff_app/pages/hostel_members_page.dart';
import 'package:student_app/staff_app/pages/floors_page.dart';
import 'package:student_app/staff_app/pages/add_hostel_page.dart';
import 'package:student_app/staff_app/pages/student_attendance_filter_page.dart';
import 'package:student_app/staff_app/pages/hostel_attendance_View_page.dart';
import 'package:student_app/staff_app/pages/hostel_attendance_result_page.dart';
import 'package:student_app/staff_app/pages/fee_head_page.dart';
import 'package:student_app/staff_app/pages/hostel_list_page.dart';
import 'package:student_app/staff_app/pages/non_hostel_page.dart';
import 'package:student_app/staff_app/pages/attendance_options_page.dart';
import 'package:student_app/staff_app/pages/chat_page.dart';
import 'package:student_app/staff_app/pages/communication_page.dart';
import 'package:student_app/staff_app/pages/add_staff_page.dart';
import 'package:student_app/staff_app/pages/staff_biometric_logs_page.dart';
import 'package:student_app/staff_app/pages/take_staff_attendance_page.dart';
import 'package:student_app/staff_app/pages/pro_admission_page.dart';
import 'package:student_app/staff_app/pages/hostel_attendance_mark_page.dart';
import 'package:student_app/staff_app/pages/hostel_attendance_status_page.dart';
import 'package:student_app/staff_app/pages/add_hostel_attendance_page.dart';
// Student Pages
import 'package:student_app/student_app/class_attendance_page.dart';
import 'package:student_app/student_app/hostel_attendence_page.dart';
import 'package:student_app/student_app/hostel_fee_page.dart';
import 'package:student_app/student_app/documents_page.dart';
import 'package:student_app/student_app/outings_permissions_page.dart';
import 'package:student_app/student_app/remarks_page.dart';
import 'package:student_app/student_app/marks_page.dart';
import 'package:student_app/student_app/upcoming_exams_page.dart';
import 'package:student_app/student_app/student_profile_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  // Initialize Student Theme Choice
  await StudentThemeController.init();

  // 🌗 Global controller (NOT user-specific) - Staff App
  Get.put(staff.ThemeController(), permanent: true);

  // 🔐 AuthControllers & Others - Staff App
  Get.put(HostelController(), permanent: true);
  Get.lazyPut<AuthController>(() => AuthController());
  Get.put(StaffMainController(), permanent: true);

  runApp(const SsJcApp());
}

class SsJcApp extends StatelessWidget {
  const SsJcApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<staff.ThemeController>();
    final initialTheme = themeController.isDark.value
        ? ThemeMode.dark
        : ThemeMode.light;

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SSJC',

      // 🌗 THEME (Staff App Theme)
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: initialTheme,

      // 🚀 ALWAYS start with SplashPage.
      // SplashPage → StaffAuthWrapper → Dashboard (if logged in) or LoginPage (if not).
      home: const SplashPage(),

      getPages: [
        // 🔑 AUTH FLOW
        GetPage(name: '/authWrapper', page: () => const StaffAuthWrapper()),
        GetPage(name: '/login', page: () => const LoginPage()),
        GetPage(name: '/dashboard', page: () => const HomeDashboardPage()),
        GetPage(name: '/studentDashboard', page: () => const DashboardPage()),
        GetPage(name: '/profile', page: () => const ProfilePage()),

        // 👨🏫 STAFF
        GetPage(name: '/staff', page: () => const StaffListPage()),
        GetPage(name: '/addStaff', page: () => const AddStaffPage()),
        GetPage(
          name: '/staffBiometricLogs',
          page: () => const StaffBiometricLogsPage(),
        ),
        GetPage(
          name: '/takeStaffAttendance',
          page: () => const TakeStaffAttendancePage(),
        ),
        GetPage(
          name: '/staffAttendance',
          page: () => const StaffAttendancePage(),
        ),
        GetPage(name: '/classAttendance', page: () => ClassAttendancePage()),

        // 🚶 OUTING
        GetPage(name: '/outingList', page: () => const OutingListPage()),
        GetPage(
          name: '/outingPending',
          page: () => const OutingPendingListPage(),
        ),

        // 📝 ATTENDANCE
        GetPage(
          name: '/verifyAttendance',
          page: () => const VerifyAttendancePage(),
        ),
        GetPage(
          name: '/studentAttendance',
          page: () => const StudentAttendancePage(),
        ),
        GetPage(
          name: '/studentAttendanceFilter',
          page: () => const StudentAttendanceFilterPage(),
        ),
        GetPage(
          name: '/attendanceOptions',
          page: () => const AttendanceOptionsPage(),
        ),

        // 📚 EXAMS
        GetPage(
          name: '/examCategoryList',
          page: () => const ExamCategoryListPage(),
        ),
        GetPage(name: '/examsList', page: () => const ExamsListPage()),
        GetPage(
          name: '/subjectMarksUploadPage',
          page: () => const SubjectMarksUploadPage(),
        ),

        // 💰 FEES
        GetPage(name: '/feeHeads', page: () => const FeeHeadPage()),

        // 🏨 HOSTEL / ROOMS
        GetPage(name: '/rooms', page: () => const RoomsPage()),
        GetPage(name: '/hostelMembers', page: () => const HostelMembersPage()),
        GetPage(name: '/floors', page: () => const FloorsPage()),
        GetPage(name: '/addHostel', page: () => const AddHostelPage()),
        GetPage(
          name: '/hostelAttendanceFilter',
          page: () => const HostelAttendanceFilterPage(),
        ),
        GetPage(
          name: '/hostelAttendanceResult',
          page: () => const HostelAttendanceResultPage(),
        ),
        GetPage(name: '/hostelList', page: () => const HostelListPage()),
        GetPage(name: '/nonHostel', page: () => const NonHostelPage()),
        GetPage(name: '/chat', page: () => const ChatPage()),
        GetPage(name: '/communication', page: () => const CommunicationPage()),
        GetPage(
          name: '/hostelAttendanceMark',
          page: () => const HostelAttendanceMarkPage(),
        ),
        GetPage(
          name: '/hostelAttendanceStatus',
          page: () => const HostelAttendanceStatusPage(),
        ),
        GetPage(
          name: '/addHostelAttendance',
          page: () => const AddHostelAttendancePage(),
        ),
        GetPage(name: '/proAdmission', page: () => const ProAdmissionPage()),

        // 🎓 STUDENT APP ROUTES
        GetPage(
          name: '/studentClassAttendance',
          page: () => const AttendancePage(),
        ),
        GetPage(
          name: '/studentHostelAttendance',
          page: () => const HostelAttendancePage(),
        ),
        GetPage(name: '/studentHostelFee', page: () => const HostelFeesPage()),
        GetPage(name: '/studentDocuments', page: () => const DocumentsPage()),
        GetPage(
          name: '/studentOutings',
          page: () => const OutingsPermissionsPage(),
        ),
        GetPage(name: '/studentRemarks', page: () => const RemarksPage()),
        GetPage(name: '/studentMarks', page: () => const MarksPage()),
        GetPage(name: '/studentExams', page: () => const UpcomingExams()),
        GetPage(
          name: '/studentProfile',
          page: () => const StudentProfilePage(),
        ),
      ],
    );
  }
}
