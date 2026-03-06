import 'package:flutter/material.dart';
import 'package:student_app/staff_app/pages/home_dashboard_page.dart';
import 'package:student_app/staff_app/pages/login_page.dart';
import 'package:student_app/staff_app/utils/get_storage.dart';
import 'package:student_app/student_app/dashboard_page.dart';

/// Auth guard for the SSJC app.
/// Shows the correct Dashboard when the user is already logged in,
/// otherwise shows [LoginPage].
class StaffAuthWrapper extends StatelessWidget {
  const StaffAuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final bool loggedIn = AppStorage.isLoggedIn();
    if (!loggedIn) {
      return const LoginPage();
    }

    final String? role = AppStorage.getUserRole()?.toLowerCase();

    // Check role and return appropriate dashboard
    if (role == 'student') {
      return const DashboardPage();
    } else {
      // Default to HomeDashboardPage for staff or other roles
      return const HomeDashboardPage();
    }
  }
}
