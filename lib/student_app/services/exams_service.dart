import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_app/student_app/config/api_config.dart';

class ExamsService {
  static const String _examsEndpoint = '/online-exams-by-student';
  static const String _writeExamEndpoint = '/exam/write';
  static const String _saveAnswerEndpoint = '/exam/save-answer';
  static const String _submitEndpoint = '/exam/submit-test';
  static const String _summaryEndpoint = '/exam/summary';

  static Future<Map<String, dynamic>> getOnlineExams() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final String? token = prefs.getString('access_token');
      final String? studentId = prefs.getString('student_id');

      if (token == null || studentId == null) {
        throw Exception('User or Student ID not found. Please log in again.');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.studentApiBaseUrl}$_examsEndpoint/$studentId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        } else if (decoded is List) {
          return {'data': decoded};
        }
        return {'data': []};
      } else {
        throw Exception('Failed to load exams: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching exams: $e');
    }
  }

  static Future<Map<String, dynamic>> getExamQuestions(String examId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('access_token');

      if (token == null) {
        throw Exception('User not logged in.');
      }

      // Pattern from Postman: .../api/student/exam/write/{exam_id}
      final url = '${ApiConfig.studentApiBaseUrl}$_writeExamEndpoint/$examId';

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded is Map<String, dynamic> ? decoded : {'data': decoded};
      } else {
        throw Exception(
          'Failed to load exam questions: ${response.statusCode} (URL: $url)',
        );
      }
    } catch (e) {
      if (e is TimeoutException) {
        throw Exception('Request timed out. Please check your connection.');
      }
      throw Exception('Error fetching exam questions: $e');
    }
  }

  static Future<bool> saveAnswer(Map<String, dynamic> payload) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('access_token');

      if (token == null) {
        throw Exception('User not logged in.');
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.studentApiBaseUrl}$_saveAnswerEndpoint'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(payload),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> submitExam(String examId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('access_token');

      if (token == null) {
        throw Exception('User not logged in.');
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.studentApiBaseUrl}$_submitEndpoint'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({"exam_id": examId}),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>> getExamSummary(String examId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('access_token');

      if (token == null) {
        throw Exception('User not logged in.');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.studentApiBaseUrl}$_summaryEndpoint/$examId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded is Map<String, dynamic> ? decoded : {'data': decoded};
      } else {
        throw Exception('Failed to load summary: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching summary: $e');
    }
  }

  static Future<Map<String, dynamic>> getExamReportData(String examId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('access_token');
      final String? studentId = prefs.getString('student_id');

      if (token == null || studentId == null) {
        throw Exception('User or Student ID not found. Please log in again.');
      }

      final url = Uri.parse(
        '${ApiConfig.studentApiBaseUrl}/exam/$examId/download-report',
      );

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          'Failed to fetch report data (Status: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception('Error fetching report data: $e');
    }
  }

  static Future<List<int>> downloadExamReport(String examId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('access_token');
      final String? studentId = prefs.getString('student_id');

      if (token == null || studentId == null) {
        throw Exception('User or Student ID not found. Please log in again.');
      }

      final url = Uri.parse(
        '${ApiConfig.studentApiBaseUrl}/exam/$examId/download-report',
      );

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': '*/*',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception(
          'Failed to download report (Status: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception('Error downloading report: $e');
    }
  }

  static Future<Map<String, dynamic>> getExamDetails(String examId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('access_token');
      final String? studentId = prefs.getString('student_id');

      if (token == null || studentId == null) {
        throw Exception('User or Student ID not found. Please log in again.');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.studentApiBaseUrl}/exam/write/$examId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Failed to load exam details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching exam details: $e');
    }
  }

  static Future<Map<String, dynamic>> getExamStats({bool forceRefresh = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('access_token');
      final String? studentId = prefs.getString('student_id');

      if (token == null || studentId == null) {
        throw Exception('User or Student ID not found. Please log in again.');
      }

      final String cacheKey = 'exam_stats_$studentId';

      if (!forceRefresh) {
        final String? cachedData = prefs.getString(cacheKey);
        if (cachedData != null) {
          final decoded = jsonDecode(cachedData);
          return decoded is Map<String, dynamic> ? decoded : {'data': decoded};
        }
      }

      final url = '${ApiConfig.studentApiBaseUrl}/exam/examstats';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        // Cache the response
        await prefs.setString(cacheKey, response.body);
        return decoded is Map<String, dynamic> ? decoded : {'data': decoded};
      } else {
        throw Exception('Failed to load exam stats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching exam stats: $e');
    }
  }
}
