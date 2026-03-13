import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_app/student_app/config/api_config.dart';
import 'package:student_app/student_app/services/cache_manager.dart';

class RemarksService {
  static const String _endpoint = '/remarks';

  static Future<List<dynamic>> getRemarks({bool forceRefresh = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final String? token = prefs.getString('access_token');
      final String? studentId = prefs.getString('student_id');

      if (token == null || studentId == null) {
        throw Exception('User and Student ID not found. Please log in again.');
      }

      final String cacheKey = 'student_remarks_$studentId';

      if (!forceRefresh) {
        final String? cachedData = prefs.getString(cacheKey);
        final bool fresh = await CacheManager.isFresh(cacheKey);
        if (cachedData != null && fresh) {
          final decoded = jsonDecode(cachedData);
          if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
            return decoded['data'] as List<dynamic>;
          } else if (decoded is List) {
            return decoded;
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
        final decoded = jsonDecode(response.body);

        // Cache the response
        await prefs.setString(cacheKey, response.body);
        await CacheManager.touch(cacheKey);

        if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
          return decoded['data'] as List<dynamic>;
        } else if (decoded is List) {
          return decoded;
        }

        return [];
      } else {
        throw Exception('Failed to load remarks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching remarks: $e');
    }
  }
}
