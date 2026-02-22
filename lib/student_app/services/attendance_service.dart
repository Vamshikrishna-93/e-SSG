import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_app/student_app/config/api_config.dart';
import 'package:student_app/student_app/model/class_attendance.dart';

class AttendanceService {
  static const String _attendanceGridEndpoint = '/student-attendance-grid';
  static const String _summaryEndpoint = '/getattendanceSummary';

  static Future<ClassAttendance> getAttendance({
    bool forceRefresh = false,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final String? token = prefs.getString('access_token');
      final String? studentId = prefs.getString('student_id');

      if (token == null || studentId == null) {
        throw Exception('User or Student ID not found. Please log in again.');
      }

      final String cacheKey = 'class_attendance_grid_$studentId';

      if (!forceRefresh) {
        final String? cachedData = prefs.getString(cacheKey);
        if (cachedData != null) {
          final decoded = jsonDecode(cachedData);
          if (decoded is List) {
            return ClassAttendance.fromJson({'data': decoded});
          }
          return ClassAttendance.fromJson(decoded);
        }
      }

      print(
        'Fetching Class Attendance for student $studentId from: ${ApiConfig.studentApiBaseUrl}$_attendanceGridEndpoint/$studentId',
      );
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.studentApiBaseUrl}$_attendanceGridEndpoint/$studentId',
        ),
        headers: {
          'Authorization': 'Bearer $token',
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

        if (decoded is List) {
          return ClassAttendance.fromJson({'data': decoded});
        }
        return ClassAttendance.fromJson(decoded);
      } else {
        throw Exception('Failed to load attendance: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching attendance: $e');
    }
  }

  static Future<Map<String, dynamic>> getAttendanceSummary({
    bool forceRefresh = false,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final String? token = prefs.getString('access_token');
      final String? studentId = prefs.getString('student_id');

      if (token == null || studentId == null) {
        throw Exception('User or Student ID not found. Please log in again.');
      }

      final String cacheKey = 'class_attendance_summary_$studentId';

      if (!forceRefresh) {
        final String? cachedData = prefs.getString(cacheKey);
        if (cachedData != null) {
          return Map<String, dynamic>.from(
            jsonDecode(cachedData)['data'] ?? {},
          );
        }
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.studentApiBaseUrl}$_summaryEndpoint/$studentId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          // Cache the response
          await prefs.setString(cacheKey, response.body);
          return Map<String, dynamic>.from(decoded['data']);
        }
        return {};
      } else {
        throw Exception(
          'Failed to load attendance summary: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching attendance summary: $e');
    }
  }

  static Future<List<int>> downloadAttendanceReport({String? year}) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final String? token = prefs.getString('access_token');
      final String? studentId = prefs.getString('student_id');

      if (token == null || studentId == null) {
        throw Exception('User or Student ID not found. Please log in again.');
      }

      String url =
          '${ApiConfig.studentApiBaseUrl}/student-attendance-download/$studentId';
      if (year != null && year.isNotEmpty) {
        url += '?year=$year';
      }

      print(
        'Downloading Class Attendance Report for student $studentId from: $url',
      );
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': '*/*',
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
