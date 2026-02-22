import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OutingService {
  static const String _baseUrl =
      'https://stage.srisaraswathigroups.in/api/student/outings';

  static Future<Map<String, dynamic>> getOutings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Retrieve token or use the one provided in the request
      final String token =
          prefs.getString('access_token') ??
          'MjA1OTl8aTdYQWNCQndzUlF5SDUxbTFhclZWU3hkRnRPbXlpcmh4UnBjWlR6ZXwxNzY5NzU0Njc5fGEyODBmOTk3MGQxOWZiOGY2ZjU0ZjJjMWQwZDAwNTMzMWNjOGE2YmVhOWIzZDczNTE2Zjk4NWJhMjcwOGY0MWE=';

      // Retrieve student ID or use the one provided in the request
      final String studentId = prefs.getString('student_id') ?? '20599';

      final response = await http.get(
        Uri.parse('$_baseUrl/$studentId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Cookie': 'laravel_session=srMI9JoQ2JIcbyOidZayjSDPBWME4lweBFaTOuui',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
        return {'data': []};
      } else {
        throw Exception('Failed to load outings: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching outings: $e');
    }
  }
}
