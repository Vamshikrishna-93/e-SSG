import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:student_app/staff_app/pages/staff_auth_wrapper.dart';
import 'package:student_app/staff_app/utils/get_storage.dart';
import 'package:student_app/student_app/services/student_profile_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // 🕒 Minimum display time for Splash (to show off the logo/animation)
    final startTime = DateTime.now();

    // 🔄 Determine if we're a logged-in student to pre-fetch profile data
    // This ensures names, IDs, and avatars are ready before Dashboard appears.
    if (AppStorage.isLoggedIn() &&
        AppStorage.getUserRole()?.toLowerCase() == 'student') {
      try {
        await StudentProfileService.fetchAndSetProfileData();
      } catch (e) {
        debugPrint("Splash - Student Profile Prefetch Error: $e");
      }
    }

    // ⌛ Calculate remaining time to fulfill the 3-second minimum requirement
    final elapsed = DateTime.now().difference(startTime).inMilliseconds;
    final delay = (3000 - elapsed).clamp(
      500,
      3000,
    ); // Wait at least 500ms even if init was slow

    Future.delayed(Duration(milliseconds: delay), () {
      // StaffAuthWrapper determines final destination: Dashboard (if logged in) or Login (if not).
      Get.offAll(() => const StaffAuthWrapper(), transition: Transition.fadeIn);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [
              Color(0xFFF3F0FF), // Lighter, glowing center
              Color(0xFF9E92FF), // Transition color
              Color(0xFF7C3AED), // Vibrant outer purple (Primary brand color)
            ],
            center: Alignment.center,
            radius: 1.1,
          ),
        ),
        child: Center(
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1800),
            tween: Tween(begin: 0.0, end: 1.0),
            curve: Curves.easeOutExpo, // Elegant, high-end feel
            builder: (context, value, child) {
              return Opacity(
                opacity: value.clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: 0.8 + (0.2 * value), // Scale from 80% to 100%
                  child: Container(
                    padding: const EdgeInsets.all(
                      40,
                    ), // Increased padding for a larger circle
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7B6DFE).withOpacity(0.3),
                          blurRadius: 40,
                          spreadRadius: 2,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/logo gif.gif',
                      width: 150,
                      height: 150,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.school,
                        size: 80,
                        color: Color(0xFF7C3AED),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
