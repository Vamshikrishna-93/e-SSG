import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_app/staff_app/utils/get_storage.dart';
import 'package:student_app/student_app/services/student_profile_service.dart'
    as student_profile;
import 'package:student_app/student_app/services/auth_service.dart'
    as student_auth;
import '../api/api_service.dart';
import 'profile_controller.dart';

class AuthController extends GetxController {
  final isLoading = false.obs;

  // ================= LOGIN =================
  Future<void> login(String username, String password) async {
    try {
      isLoading.value = true;

      // 🔍 Decide which login service to call based on the username length
      final Map<String, dynamic> response;
      if (username.length == 10) {
        debugPrint("Calling Student AuthService (10-digit)...");
        response = await student_auth.AuthService.login(
          mobile: username,
          password: password,
        );
      } else if (username.length == 6) {
        debugPrint("Calling Staff ApiService (6-digit)...");
        response = await ApiService.login(
          username: username,
          password: password,
        );
      } else {
        throw Exception(
          "Username must be 6 digits (Staff) or 10 digits (Student)",
        );
      }

      // ✅ SUCCESS CHECK - Handle different success formats
      final isSuccess =
          response["success"] == true ||
          response["success"] == "true" ||
          response["success"] == 1;

      if (isSuccess && response["access_token"] != null) {
        // 🔥 CLEAR PREVIOUS USER'S PROFILE DATA (MULTI-USER SUPPORT)
        _clearProfileController();

        // 🔐 SAVE SESSION (Tokens and IDs are handled in the API calls, but we ensure it here too)
        AppStorage.saveToken(response["access_token"]);
        AppStorage.saveUserId(
          response["userid"] is int
              ? response["userid"]
              : int.tryParse(response["userid"].toString()) ?? 0,
        );
        AppStorage.setLoggedIn(true);

        // 🔥 Save Role & Type for routing (Persistence)
        final String role = (response['role'] ?? '').toString().toLowerCase();
        AppStorage.saveUserRole(role);
        if (response['login_type'] != null) {
          AppStorage.saveLoginType(response['login_type'].toString());
        }

        // 🔥 SAVE MULTI-USER SESSION
        AppStorage.saveUserSession({
          'user_login': username,
          'userid': response['userid'],
          'login_type': response['login_type'],
          'role':
              response['role'] ?? (username.length == 10 ? 'student' : 'staff'),
          'permissions': response['permissions'] ?? [],
        }, response["access_token"]);

        // 🔥 FETCH PROFILE (Staff app only, for student we rely on dashboard)
        if (role != 'student') {
          final profileController = Get.isRegistered<ProfileController>()
              ? Get.find<ProfileController>()
              : Get.put(ProfileController());

          profileController.fetchProfile().catchError((e) {
            debugPrint("PROFILE FETCH FAILED AFTER LOGIN: $e");
          });
        }

        // 🚀 GO TO THE CORRECT DASHBOARD
        if (role == 'student') {
          Get.offAllNamed('/studentDashboard', arguments: {'isLogin': true});
        } else {
          Get.offAllNamed('/dashboard');
        }
      } else {
        // Extract error message
        final errorMsg =
            response["message"] ??
            response["error"] ??
            response["msg"] ??
            "Invalid credentials";

        Get.snackbar(
          "Login Failed",
          errorMsg,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint("LOGIN ERROR => $e");

      // Extract error message from exception
      String errorMessage = "Server connection failed";
      final errorString = e.toString();

      if (errorString.contains("Invalid") ||
          errorString.contains("credentials") ||
          errorString.contains("Invalid credentials")) {
        errorMessage = "Invalid credentials";
      } else if (errorString.contains("Network") ||
          errorString.contains("connection")) {
        errorMessage = "Network error: Please check your internet connection";
      } else if (errorString.contains("timeout") ||
          errorString.contains("Timeout")) {
        errorMessage = "Connection timeout: Please try again";
      } else if (errorString.contains("Server error")) {
        errorMessage = "Server error: Please try again later";
      } else {
        // Try to extract the actual error message from the exception
        // Remove "Exception: " prefix if present
        errorMessage = errorString.replaceFirst("Exception: ", "").trim();
        if (errorMessage.isEmpty) {
          errorMessage = "Login failed: Please try again";
        }
      }

      Get.snackbar(
        "Error",
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ================= CLEAR PROFILE CONTROLLER =================
  void _clearProfileController() {
    if (Get.isRegistered<ProfileController>()) {
      final profileController = Get.find<ProfileController>();
      // Clear profile data
      profileController.profile.value = null;
      profileController.isLoading.value = true;
    }
  }

  // ================= LOGOUT =================
  Future<void> logout() async {
    // 🚀 1. Clear Session (GetStorage)
    AppStorage.clear();

    // 🚀 2. Clear SharedPreferences (for student app)
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    student_profile.StudentProfileService.resetProfileData();

    // 🧹 3. Clear related controllers
    if (Get.isRegistered<ProfileController>()) {
      Get.delete<ProfileController>(force: true);
    }

    // 🚪 4. GO BACK TO LOGIN (via auth wrapper — session is cleared so it shows LoginPage)
    Get.offAllNamed('/authWrapper');
  }
}
