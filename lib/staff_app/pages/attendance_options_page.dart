import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/main_controller.dart';
import '../widgets/staff_bottom_nav_bar.dart';
import '../widgets/staff_header.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import '../utils/iconify_icons.dart';

class AttendanceOptionsPage extends StatefulWidget {
  const AttendanceOptionsPage({super.key});

  @override
  State<AttendanceOptionsPage> createState() => _AttendanceOptionsPageState();
}

class _AttendanceOptionsPageState extends State<AttendanceOptionsPage> {
  @override
  void initState() {
    super.initState();
    // Ensure the bottom nav is synced
    if (Get.isRegistered<StaffMainController>()) {
      Get.find<StaffMainController>().changeIndex(1);
    } else {
      Get.put(StaffMainController(), permanent: true).changeIndex(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      body: Column(
        children: [
          const StaffHeader(title: "Students Attendance", showBack: false),

          // ================= GRID MENU =================
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double cardWidth = (constraints.maxWidth - 14) / 2;
                  final double cardHeight = cardWidth * 0.88;
                  return Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: [
                      _buildGridCard(
                        width: cardWidth,
                        height: cardHeight,
                        title: "Student\nAttendance",
                        icon: IconifyIcons.usersCheck,
                        gradientColors: const [
                          Color(0xFF2CDB99),
                          Color(0xFF19B2A1),
                        ],
                        onTap: () => Get.toNamed('/studentAttendance'),
                      ),
                      _buildGridCard(
                        width: cardWidth,
                        height: cardHeight,
                        title: "Verify\nAttendance",
                        icon: IconifyIcons.verifiedUser,
                        gradientColors: const [
                          Color(0xFFEF7998),
                          Color(0xFFD32A5B),
                        ],
                        onTap: () => Get.toNamed('/verifyAttendance'),
                      ),
                      _buildGridCard(
                        width: cardWidth,
                        height: cardHeight,
                        title: "Hostel\nAttendance",
                        icon: IconifyIcons.clarityBuildingLine,
                        gradientColors: const [
                          Color(0xFFD170FD),
                          Color(0xFFA11BD9),
                        ],
                        onTap: () => Get.toNamed('/hostelAttendanceFilter'),
                      ),
                      _buildGridCard(
                        width: cardWidth,
                        height: cardHeight,
                        title: "Outings",
                        icon: IconifyIcons.route,
                        gradientColors: const [
                          Color(0xFF5AB1FF),
                          Color(0xFF2386F9),
                        ],
                        onTap: () => Get.toNamed('/outingList'),
                      ),
                      _buildGridCard(
                        width: cardWidth,
                        height: cardHeight,
                        title: "Outings\nPending",
                        icon: IconifyIcons.pendingActions,
                        gradientColors: const [
                          Color(0xFFFFBF61),
                          Color(0xFFF9942A),
                        ],
                        onTap: () => Get.toNamed('/outingPending'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const StaffBottomNavBar(),
    );
  }

  Widget _buildGridCard({
    required double width,
    required double height,
    required String title,
    required dynamic
    icon, // Changed to dynamic to support both IconData and String (Iconify)
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: gradientColors[1].withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative bubbles - Exact placement based on image
            Positioned(
              top: -40,
              left: -40,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 2,
                  ),
                ),
              ),
            ),
            Positioned(
              top: -20,
              right: width * 0.2,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 2,
                  ),
                ),
              ),
            ),

            // Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // White circle with icon
                  Container(
                    width: 76,
                    height: 76,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: icon is IconData
                        ? Icon(icon, color: gradientColors[1], size: 36)
                        : Padding(
                            padding: const EdgeInsets.all(16),
                            child: Iconify(
                              icon,
                              color: gradientColors[1],
                              size: 36,
                            ),
                          ),
                  ),
                  const SizedBox(height: 12),
                  // Title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
