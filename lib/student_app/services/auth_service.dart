import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_app/student_app/config/api_config.dart';
import 'package:student_app/student_app/services/student_profile_service.dart';

class AuthService {
  static Future<Map<String, dynamic>> login({
    required String mobile,
    required String password,
  }) async {
    try {
      final url = Uri.parse("${ApiConfig.baseUrl}${ApiConfig.login}");

      final response = await http
          .post(
            url,
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
              "User-Agent":
                  "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
            },
            body: jsonEncode({'mobile': mobile, 'password': password}),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        if (body['success'] == true) {
          final Map<String, dynamic> innerData =
              (body["data"] ?? {}) as Map<String, dynamic>;
          final Map<String, dynamic> normalizedData = {
            "success": true,
            "access_token": innerData["token"],
            "userid": innerData["sid"],
            "role": "student",
            "login_type": "student",
            "permissions": [],
            ...innerData,
          };

          // 1. Save to SharedPreferences for student_app services compatibility
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(
            "access_token",
            normalizedData["access_token"].toString(),
          );
          await prefs.setString(
            "student_id",
            normalizedData["userid"].toString(),
          );

          // 2. Save to GetStorage for AuthWrapper & AuthController
          // We'll return the normalized data to the controller so it can handle app-wide storage

          // Fetch student profile data to ensure it's ready immediately
          await StudentProfileService.fetchAndSetProfileData();

          return normalizedData;
        } else {
          return {
            'success': false,
            'message': body['message'] ?? 'Invalid credentials',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Server Error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }
}
