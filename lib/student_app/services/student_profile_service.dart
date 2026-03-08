import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_app/student_app/config/api_config.dart';

class StudentProfileService {
  static final ValueNotifier<String?> profileImageUrl = ValueNotifier<String?>(
    null,
  );
  static final ValueNotifier<String?> displayName = ValueNotifier<String?>(
    null,
  );
  static final ValueNotifier<String?> displayId = ValueNotifier<String?>(null);

  static String get baseUrl => ApiConfig.studentApiBaseUrl;

  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? "";
    return {
      "Authorization": "Bearer $token",
      "Accept": "application/json",
      "Content-Type": "application/json",
    };
  }

  static Map<String, dynamic>? cachedProfileData;

  /// GET PROFILE
  static Future<Map<String, dynamic>> getProfile({bool forceRefresh = false}) async {
    if (!forceRefresh && cachedProfileData != null) {
      return cachedProfileData!;
    }
    final prefs = await SharedPreferences.getInstance();
    final studentId = prefs.getString('student_id') ?? "";
    final headers = await _getHeaders();
    final res = await http.get(
      Uri.parse("$baseUrl/studentprofile/$studentId"),
      headers: headers,
    );

    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      cachedProfileData = decoded;
      return decoded;
    }
    throw Exception("Failed to load profile");
  }

  /// UPDATE PROFILE (PERSONAL / CONTACT / ACADEMIC)
  static Future<bool> updateProfile(Map<String, String> data) async {
    try {
      final headers = await _getHeaders();
      await http.put(
        Uri.parse("$baseUrl/profile/update"),
        headers: headers,
        body: jsonEncode(data),
      );
    } catch (e) {
      debugPrint("Error updating profile API: $e");
    }

    // Update locally so it reflects immediately
    if (cachedProfileData != null && cachedProfileData!['data'] != null) {
      final currentData = cachedProfileData!['data'] as Map<String, dynamic>;
      data.forEach((key, value) {
        currentData[key] = value;
      });
    }

    return true;
  }

  /// CHANGE PASSWORD
  static Future<bool> changePassword(
    String current,
    String newPassword,
    String confirm,
  ) async {
    final headers = await _getHeaders();
    final res = await http.post(
      Uri.parse("$baseUrl/change-password"),
      headers: headers,
      body: jsonEncode({
        "current_password": current,
        "new_password": newPassword,
        "confirm_password": confirm,
      }),
    );

    return res.statusCode == 200;
  }

  /// UPLOAD PROFILE IMAGE
  static Future<bool> uploadProfileImage(File image) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? "";

    final request = http.MultipartRequest(
      'POST',
      Uri.parse("$baseUrl/profile/upload-image"),
    );

    request.headers['Authorization'] = "Bearer $token";
    request.files.add(await http.MultipartFile.fromPath('image', image.path));

    final response = await request.send();
    return response.statusCode == 200;
  }

  /// FETCH AND SET PROFILE DATA GLOBALLY
  static Future<void> fetchAndSetProfileData() async {
    try {
      final response = await getProfile();
      if (response['status'] == true && response['data'] != null) {
        final data = response['data'];

        // Update Photo
        final photo = data['photo'];
        profileImageUrl.value = (photo != null && photo.toString().isNotEmpty)
            ? photo.toString()
            : null;

        // Update Name
        final fname = data['sfname'] ?? "";
        final lname = data['slname'] ?? "";
        final name = "$fname $lname".trim();
        displayName.value = name.isNotEmpty ? name : "Student";

        // Update ID (e.g., Admission No or SID)
        final id = data['adm_no'] ?? data['id']?.toString() ?? "";
        displayId.value = id.isNotEmpty ? id : null;
      } else {
        profileImageUrl.value = null;
        displayName.value = null;
      }
    } catch (e) {
      debugPrint("Error initializing profile data: $e");
      profileImageUrl.value = null;
      displayName.value = null;
    }
  }

  /// RESET PROFILE DATA (e.g., on logout)
  static void resetProfileData() {
    profileImageUrl.value = null;
    displayName.value = null;
    displayId.value = null;
    cachedProfileData = null;
  }
}
