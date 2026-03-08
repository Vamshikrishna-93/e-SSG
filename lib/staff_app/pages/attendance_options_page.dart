import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/main_controller.dart';
import '../widgets/staff_bottom_nav_bar.dart';

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
    const primaryPurple = Color(0xFF7E49FF);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ================= CUSTOM HEADER =================
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 10,
              bottom: 25,
              left: 20,
              right: 20,
            ),
            decoration: const BoxDecoration(
              color: primaryPurple,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Row(
              children: const [
                Icon(
                  Icons.event_available_rounded,
                  color: Colors.white,
                  size: 26,
                ),
                SizedBox(width: 15),
                Text(
                  "Students Attendance",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // ================= GRID MENU =================
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 25),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 0.95, // Balances width/height nicely
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
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [color1, color2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: color2.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background overlapping circles for glass texture visual
            Positioned(
              top: -20,
              left: 20,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.12),
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              right: -10,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.12),
                ),
              ),
            ),

            // Foreground content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 65,
                    height: 65,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
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
