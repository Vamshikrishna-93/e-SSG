import 'dart:convert';
import 'package:student_app/student_app/model/hostel_attendance.dart';

void main() {
  var jsonStr = '''
  {
    "success": true,
    "attendance": [
      {
        "month_name": "Jun 25",
        "Day_01": null,
        "Day_02": "P",
        "Day_03": "A"
      }
    ]
  }
  ''';
  
  var parsed = HostelAttendance.fromJson(jsonDecode(jsonStr));
  print(parsed.attendance.first.monthName);
  print(parsed.attendance.first.total);
}
