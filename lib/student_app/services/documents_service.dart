import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_app/student_app/config/api_config.dart';

class DocumentsService {
  // Documents endpoint
  static const String _endpoint = '/documents';

  static Future<Map<String, dynamic>> getDocuments({bool forceRefresh = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('access_token');
      final String? studentId = prefs.getString('student_id');

      if (token == null || studentId == null) {
        throw Exception('User or Student ID not found. Please log in again.');
      }

      final String cacheKey = 'student_documents_$studentId';

      // Cache-first approach
      if (!forceRefresh) {
        final String? cachedData = prefs.getString(cacheKey);
        if (cachedData != null) {
          try {
            return jsonDecode(cachedData);
          } catch (_) {
            // If decoding fails, proceed to fetch fresh data
          }
        }
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.studentApiBaseUrl}$_endpoint/$studentId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Save to cache
        await prefs.setString(cacheKey, response.body);
        return data;
      } else {
        throw Exception(
          'Failed to load documents. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching documents: $e');
    }
  }
}
