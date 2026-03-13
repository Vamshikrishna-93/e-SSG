import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_app/student_app/config/api_config.dart';
import 'package:student_app/student_app/model/hostel_attendance.dart';
import 'package:student_app/student_app/services/cache_manager.dart';

class HostelAttendanceService {
  static const String _hostelAttendanceEndpoint =
      '/student-hostel-attendance-grid';

  static Future<HostelAttendance> getHostelAttendance({
    String? year,
    bool forceRefresh = false,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('access_token');
      final String? studentId = prefs.getString('student_id');

      if (token == null || studentId == null) {
        return HostelAttendance(success: false, attendance: []);
      }

      final String cacheKey = year != null && year.isNotEmpty
          ? 'hostel_attendance_${studentId}_$year'
          : 'hostel_attendance_$studentId';

      if (!forceRefresh) {
        final String? cachedData = prefs.getString(cacheKey);
        final bool fresh = await CacheManager.isFresh(cacheKey);
        if (cachedData != null && fresh) {
          return HostelAttendance.fromJson(jsonDecode(cachedData));
        }
      }

      String url =
          '${ApiConfig.studentApiBaseUrl}$_hostelAttendanceEndpoint/$studentId';
      if (year != null && year.isNotEmpty) {
        url += '?year=$year';
      }

      print('Fetching Hostel Attendance for student $studentId from: $url');
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'token': token,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        // Cache the response
        await prefs.setString(cacheKey, response.body);
        await CacheManager.touch(cacheKey);
        return HostelAttendance.fromJson(decoded);
      } else {
        throw Exception(
          'Failed to load hostel attendance: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching hostel attendance: $e');
    }
  }

  static Future<List<int>> downloadHostelAttendanceReport({
    String? year,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('access_token');
      final String? studentId = prefs.getString('student_id');

      if (token == null || studentId == null) {
        throw Exception('User or Student ID not found. Please log in again.');
      }

      String url =
          '${ApiConfig.studentApiBaseUrl}/student-hostel-attendance-download/$studentId';
      if (year != null && year.isNotEmpty) {
        url += '?year=$year';
      }

      print(
        'Downloading Hostel Attendance Report for student $studentId from: $url',
      );
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': '*application/json',
          'Content-Type': 'application/json',
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        },
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Failed to download report: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error downloading report: $e');
    }
  }
}
