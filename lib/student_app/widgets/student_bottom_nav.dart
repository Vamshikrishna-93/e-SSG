import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StudentBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const StudentBottomNav({super.key, required this.currentIndex, this.onTap});

  void _onTap(int index) {
    if (currentIndex == index) return;
    if (onTap != null) {
      onTap!(index);
    } else {
      switch (index) {
        case 0:
          Get.offNamed('/studentDashboard');
          break;
        case 1:
          Get.offNamed('/studentMarks');
          break;
        case 2:
          Get.offNamed('/studentExams');
          break;
        case 3:
          Get.offNamed('/studentProfile');
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'student_bottom_nav',
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF7C3AED),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home, "Home", 0),
                _buildNavItem(Icons.bar_chart, "Marks", 1),
                _buildNavItem(Icons.assignment_outlined, "Exams", 2),
                _buildNavItem(Icons.person, "Profile", 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool active = currentIndex == index;
    return GestureDetector(
      onTap: () => _onTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: active ? Colors.white.withOpacity(0.25) : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
