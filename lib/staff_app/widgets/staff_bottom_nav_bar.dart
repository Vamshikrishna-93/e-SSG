import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import '../utils/iconify_icons.dart';

class StaffBottomNavBar extends StatelessWidget {
  const StaffBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.put(
      ProfileController(),
      permanent: true,
    );

    return Obx(() {
      return Container(
        height: 80,
        padding: const EdgeInsets.only(bottom: 10),
        decoration: const BoxDecoration(
          color: Color(0xFF7C3FE3), // Persistent Purple
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(35),
            topRight: Radius.circular(35),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(0, IconifyIcons.clarityBuildingLine, "Home", controller),
            _buildNavItem(
              1,
              IconifyIcons.clarityFormLine,
              "Attendance",
              controller,
            ),
            _buildNavItem(2, IconifyIcons.phStudent, "Fees", controller),
            _buildNavItem(3, IconifyIcons.fluentPeopleSettings20Regular, "Profile", controller),
          ],
        ),
      );
    });
  }

  Widget _buildNavItem(
    int index,
    String icon,
    String label,
    ProfileController controller,
  ) {
    bool isSelected = controller.currentIndex.value == index;
    return GestureDetector(
      onTap: () {
        if (isSelected) return;
        controller.changeIndex(index);

        switch (index) {
          case 0:
            Get.offAllNamed('/dashboard');
            break;
          case 1:
            Get.offAllNamed('/attendanceOptions');
            break;
          case 2:
            Get.offAllNamed('/feeHeads');
            break;
          case 3:
            Get.offAllNamed('/profile');
            break;
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Iconify(
              icon,
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : Colors.white.withOpacity(0.7),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
