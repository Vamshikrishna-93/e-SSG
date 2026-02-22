import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:student_app/staff_app/pages/login_page.dart';
import 'package:student_app/student_app/dashboard_page.dart';
import 'package:student_app/student_app/services/session_service.dart';
import 'package:student_app/student_app/signIn_page.dart';
import 'package:student_app/theme_controllers.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F2027),
              Color(0xFF203A43),
              Color(0xFF2C5364),
              Color(0xFF533483),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 🔷 LOGO
                Image.asset(
                  'assets/ssjc.jpg',
                  height: 110,
                  width: 110,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 30),

                // 🔷 CENTERED TITLE
                const Text(
                  'Welcome to SSJC',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 40),

                // 🧑‍🏫 STAFF BUTTON
                _roleButton(
                  icon: Icons.badge_outlined,
                  text: 'I am Staff',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // 🎓 STUDENT BUTTON
                _roleButton(
                  icon: Icons.school_outlined,
                  text: 'I am Student',
                  onTap: () async {
                    // Initialize Student Theme Controller
                    final studentTheme = Get.put(StudentThemeController());
                    studentTheme.loadTheme();

                    // Check if student is already logged in
                    final bool isLoggedIn = await SessionService.isLoggedIn();

                    if (mounted) {
                      if (isLoggedIn) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ThemeControllerWrapper(
                              themeController: StudentThemeController.themeMode,
                              child: const DashboardPage(),
                            ),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ThemeControllerWrapper(
                              themeController: StudentThemeController.themeMode,
                              child: SignInPage(),
                            ),
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🔹 MODERN PILL BUTTON
  static Widget _roleButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF533483), size: 26),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
