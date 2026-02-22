import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FeesService {
  static const String _baseUrl =
      'https://stage.srisaraswathigroups.in/api/student/studentfeetabData';

  static Future<Map<String, dynamic>> getFeeDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Use the token from the prompt as default/fallback
      final String token =
          prefs.getString('access_token') ??
          'MjA1OTl8aTdYQWNCQndzUlF5SDUxbTFhclZWU3hkRnRPbXlpcmh4UnBjWlR6ZXwxNzY5NzU0Njc5fGEyODBmOTk3MGQxOWZiOGY2ZjU0ZjJjMWQwZDAwNTMzMWNjOGE2YmVhOWIzZDczNTE2Zjk4NWJhMjcwOGY0MWE=';

      final String studentId = prefs.getString('student_id') ?? '16264';

      final response = await http.get(
        Uri.parse('$_baseUrl/$studentId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Cookie': 'laravel_session=vNgDSDvBelCsYDFkv8CzxuyP43FboXQPlExZNgpv',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded['status'] == true) {
          return decoded['data'] as Map<String, dynamic>;
        }
        throw Exception('Failed to parse fee data');
      } else {
        throw Exception('Failed to load fee details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching fee details: $e');
    }
  }
}
