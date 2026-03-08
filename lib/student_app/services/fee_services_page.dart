import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_app/student_app/config/api_config.dart';

class HostelFeeService {
  static const String _tabDataEndpoint = '/studentfeetabData';
  static const String _saveDataEndpoint = '/studentfeesaveData';

  static Future<dynamic> getHostelFeeData({bool forceRefresh = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final String? token = prefs.getString('access_token');
      final String? studentId = prefs.getString('student_id');

      if (token == null || studentId == null) {
        throw Exception('User or Student ID not found. Please log in again.');
      }

      final String cacheKey = 'hostel_fee_data_$studentId';

      if (!forceRefresh) {
        final String? cachedData = prefs.getString(cacheKey);
        if (cachedData != null) {
          return json.decode(cachedData);
        }
      }

      final Uri url = Uri.parse('${ApiConfig.studentApiBaseUrl}$_tabDataEndpoint/$studentId');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        // Cache the response
        await prefs.setString(cacheKey, response.body);
        return decoded;
      } else {
        throw Exception(
          'Failed to load hostel fee data. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('HostelFeeService Exception: $e');
      rethrow;
    }
  }

  static Future<dynamic> saveHostelFeePayment(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final String? token = prefs.getString('access_token');
      final String? studentId = prefs.getString('student_id');

      if (token == null || studentId == null) {
        throw Exception('User or Student ID not found. Please log in again.');
      }

      final Uri url = Uri.parse('${ApiConfig.studentApiBaseUrl}$_saveDataEndpoint/$studentId');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Failed to save hostel fee payment. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('HostelFeeService Save Exception: $e');
      rethrow;
    }
  }
}
