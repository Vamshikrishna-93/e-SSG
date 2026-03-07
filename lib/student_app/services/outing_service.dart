import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OutingService {
  static const String _baseUrl =
      'https://stage.srisaraswathigroups.in/api/student/outings';

  static Future<Map<String, dynamic>> getOutings({
    bool forceRefresh = false,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final String? token = prefs.getString('access_token');
      final String? studentId = prefs.getString('student_id');

      if (token == null || studentId == null) {
        throw Exception('User and Student ID not found. Please log in again.');
      }

      final String cacheKey = 'student_outings_$studentId';

      // 🚀 1. Check Cache first (for instant loading and preventing re-fetches)
      if (!forceRefresh) {
        final String? cachedData = prefs.getString(cacheKey);
        if (cachedData != null) {
          try {
            final decoded = jsonDecode(cachedData);
            if (decoded is Map<String, dynamic>) {
              return decoded;
            }
          } catch (e) {
            // If cache is corrupted, proceed to fetch
          }
        }
      }

      // 🌐 2. Fetch from Network
      final response = await http
          .get(
            Uri.parse('$_baseUrl/$studentId'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'User-Agent':
                  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        // 💾 3. Save to Cache
        await prefs.setString(cacheKey, response.body);

        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
        return {'data': []};
      } else {
        throw Exception('Failed to load outings: ${response.statusCode}');
      }
    } catch (e) {
      // 🔄 Fallback to cache on error if available
      final prefs = await SharedPreferences.getInstance();
      final studentId = prefs.getString('student_id');
      if (studentId != null) {
        final cached = prefs.getString('student_outings_$studentId');
        if (cached != null) {
          return jsonDecode(cached);
        }
      }
      throw Exception('Error fetching outings: $e');
    }
  }
}
