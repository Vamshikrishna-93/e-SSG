import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/main_controller.dart';
import '../widgets/staff_bottom_nav_bar.dart';
import '../widgets/staff_header.dart';

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
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const StaffHeader(
            title: "Students Attendance",
            showBack: false,
          ),

          // ================= GRID MENU =================
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 25),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 173 / 146, // Exact Figma specs
                children: [
                  _buildGridCard(
                    title: "Student\nAttendance",
                    icon: Icons.how_to_reg_rounded,
                    color1: const Color(0xFF2BDB9A), // Light green
                    color2: const Color(0xFF07BE81), // Dark green
                    iconColor: const Color(0xFF07BE81),
                    onTap: () => Get.toNamed('/studentAttendance'),
                  ),
                  _buildGridCard(
                    title: "Verify\nAttendance",
                    icon: Icons.verified_user_rounded, // Shield check
                    color1: const Color(0xFFF17C99), // Pink
                    color2: const Color(0xFFD5295B), // Deep Pink
                    iconColor: const Color(0xFFD5295B),
                    onTap: () => Get.toNamed('/verifyAttendance'),
                  ),
                  _buildGridCard(
                    title: "Hostel\nAttendance",
                    icon: Icons.domain_rounded, // Building
                    color1: const Color(0xFFD572FE), // Light Purple
                    color2: const Color(0xFF9F1BD8), // Dark Purple
                    iconColor: const Color(0xFF9F1BD8),
                    onTap: () => Get.toNamed('/hostelAttendanceFilter'),
                  ),
                  _buildGridCard(
                    title: "Outings",
                    icon: Icons.route_rounded, // Path map trace
                    color1: const Color(0xFF5AB1FF), // Light Blue
                    color2: const Color(0xFF2386F9), // Deep Blue
                    iconColor: const Color(0xFF2386F9),
                    onTap: () => Get.toNamed('/outingList'),
                  ),
                  _buildGridCard(
                    title: "Outings\nPending",
                    icon: Icons.pending_actions_rounded, // Clipboard with clock
                    color1: const Color(0xFFFFC061), // Light Orange
                    color2: const Color(0xFFF9942A), // Deep Orange
                    iconColor: const Color(0xFFF9942A),
                    onTap: () => Get.toNamed('/outingPending'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const StaffBottomNavBar(),
    );
  }

  Widget _buildGridCard({
    required String title,
    required IconData icon,
    required Color color1,
    required Color color2,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12), // Exact Figma: 12px
          gradient: LinearGradient(
            colors: [color1, color2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: color2.withOpacity(0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // ── Bubble 1: Large top-left (overflowing corner) ──
            Positioned(
              top: -40,
              left: -40,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.20),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // ── Bubble 2: Smaller, bottom-left ──
            Positioned(
              bottom: -30,
              left: -20,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // ── Centered content: white circle icon + text ──
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 12), // Figma gap: 12px
                // Solid white circle with colored icon
                Center(
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: iconColor, size: 36),
                  ),
                ),
                const SizedBox(height: 12), // Figma gap: 12px
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12), // Figma padding: 12px
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

