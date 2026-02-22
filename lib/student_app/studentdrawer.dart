import 'package:flutter/material.dart';
import 'package:student_app/student_app/class_attendance_page.dart';
import 'package:student_app/student_app/documents_page.dart';
import 'package:student_app/student_app/exams_page.dart';
import 'package:student_app/student_app/dashboard_page.dart';
import 'package:student_app/student_app/hostel_attendence_page.dart';
import 'package:student_app/student_app/hostel_fee_page.dart';
import 'package:student_app/student_app/outings_permissions_page.dart';
import 'package:student_app/student_app/remarks_page.dart';
import 'package:student_app/student_app/marks_page.dart';
import 'package:student_app/theme_controllers.dart';

class StudentDrawerPage extends StatelessWidget {
  const StudentDrawerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade800
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Image.asset('assets/logo.png', fit: BoxFit.contain),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sri Saraswathi College',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.9,
                  children: [
                    _DashboardCard(
                      title: "Dashboard",
                      icon: Icons.home,
                      color: const Color(0xFF2196F3),
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ThemeControllerWrapper(
                              themeController: StudentThemeController.themeMode,
                              child: const DashboardPage(),
                            ),
                          ),
                        );
                      },
                    ),
                    _DashboardCard(
                      title: "Marks",
                      icon: Icons.bar_chart,
                      color: const Color(0xFFFFC107),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ThemeControllerWrapper(
                              themeController: StudentThemeController.themeMode,
                              child: const MarksPage(),
                            ),
                          ),
                        );
                      },
                    ),
                    _DashboardCard(
                      title: "Exams",
                      icon: Icons.edit_note,
                      color: const Color(0xFF4CAF50),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ThemeControllerWrapper(
                              themeController: StudentThemeController.themeMode,
                              child: const ExamsPage(),
                            ),
                          ),
                        );
                      },
                    ),
                    _DashboardCard(
                      title: "Class Attendance",
                      icon: Icons.groups,
                      color: const Color(0xFFF44336),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ThemeControllerWrapper(
                              themeController: StudentThemeController.themeMode,
                              child: const AttendancePage(),
                            ),
                          ),
                        );
                      },
                    ),
                    _DashboardCard(
                      title: "Hostel Attendance",
                      icon: Icons.bed,
                      color: const Color(0xFF9C27B0),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ThemeControllerWrapper(
                              themeController: StudentThemeController.themeMode,
                              child: const HostelAttendancePage(),
                            ),
                          ),
                        );
                      },
                    ),
                    _DashboardCard(
                      title: "Hostel Fee",
                      icon: Icons.currency_rupee,
                      color: const Color(0xFF009688),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ThemeControllerWrapper(
                              themeController: StudentThemeController.themeMode,
                              child: const HostelFeesPage(),
                            ),
                          ),
                        );
                      },
                    ),
                    _DashboardCard(
                      title: "Documents",
                      icon: Icons.folder,
                      color: const Color(0xFF3F51B5),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ThemeControllerWrapper(
                              themeController: StudentThemeController.themeMode,
                              child: const DocumentsPage(),
                            ),
                          ),
                        );
                      },
                    ),
                    _DashboardCard(
                      title: "Outings",
                      icon: Icons.directions_walk,
                      color: const Color(0xFF8BC34A),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ThemeControllerWrapper(
                              themeController: StudentThemeController.themeMode,
                              child: const OutingsPermissionsPage(),
                            ),
                          ),
                        );
                      },
                    ),
                    _DashboardCard(
                      title: "Remarks",
                      icon: Icons.chat_bubble_outline,
                      color: const Color(0xFFFF5722),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ThemeControllerWrapper(
                              themeController: StudentThemeController.themeMode,
                              child: const RemarksPage(),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.45),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 46, color: Colors.white),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
