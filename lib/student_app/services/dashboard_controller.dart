import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:student_app/student_app/model/class_attendance.dart';
import 'package:student_app/student_app/model/hostel_attendance.dart';
import 'package:student_app/student_app/services/attendance_service.dart';
import 'package:student_app/student_app/services/exams_service.dart';
import 'package:student_app/student_app/services/hostel_attendance_service.dart';
import 'package:student_app/student_app/services/remarks_service.dart';

class DashboardController extends GetxController {
  var isLoading = true.obs;
  var isInitialLoadDone = false.obs;

  var classChartData = <Map<String, dynamic>>[].obs;
  var hostelChartData = <Map<String, dynamic>>[].obs;
  var classChartMonths = <String>[].obs;
  var hostelChartMonths = <String>[].obs;
  var remarks = <dynamic>[].obs;
  var announcements = <dynamic>[].obs;
  var exams = <dynamic>[].obs;
  var examStats = <String, dynamic>{}.obs;

  var classRange = "Academic Year".obs;
  var hostelRange = "Academic Year".obs;

  // Cached raw attendance objects for fast local reprocessing on range change
  ClassAttendance? _cachedClassAttendance;
  HostelAttendance? _cachedHostelAttendance;

  @override
  void onInit() {
    super.onInit();
    _refreshFlow();
  }

  Future<void> _refreshFlow() async {
    // 1. Load from disk cache instantly (no force refresh)
    await loadAllData(forceRefresh: false);

    // 2. If we just loaded from cache, we're not technically "done" with the session refresh
    // but the UI is now populated. Now fetch from server to be sure.
    await loadAllData(forceRefresh: true);
  }

  Future<void> loadAllData({bool forceRefresh = false}) async {
    // If we are navigating back and already did a server refresh this session, skip.
    if (!forceRefresh && isInitialLoadDone.value) return;

    // Only show full-screen skeleton if we have absolutely no data yet
    if (classChartData.isEmpty && remarks.isEmpty) {
      isLoading.value = true;
    }

    try {
      final results = await Future.wait([
        AttendanceService.getAttendance(forceRefresh: forceRefresh),
        HostelAttendanceService.getHostelAttendance(forceRefresh: forceRefresh),
        RemarksService.getRemarks(
          forceRefresh: forceRefresh,
        ).catchError((_) => []),
        ExamsService.getExamStats(
          forceRefresh: forceRefresh,
        ).catchError((_) => <String, dynamic>{}),
      ]);

      final classAttendance = results[0] as ClassAttendance;
      final hostelAttendance = results[1] as HostelAttendance;
      remarks.value = results[2] as List<dynamic>;
      examStats.value = results[3] as Map<String, dynamic>;

      // Cache for use when range changes without re-fetching
      _cachedClassAttendance = classAttendance;
      _cachedHostelAttendance = hostelAttendance;

      processAttendanceData(classAttendance, hostelAttendance);

      announcements.value = [
        {
          "message":
              "Unit Test-2 will be conducted from 22nd July. Students are advised to prepare accordingly",
          "department": "Academic Office",
          "color": const Color(0xFF3B82F6),
        },
        {
          "message":
              "Hostel students must return to campus before 8:00 PM during weekdays",
          "department": "Hostel Warden",
          "color": const Color(0xFF06B6D4),
        },
      ];

      exams.value = [
        {
          "title": "Mathematics Unit Test",
          "subtitle": "5th August, 2024",
          "color": const Color(0xFF3B82F6),
        },
        {
          "title": "Physics Monthly Assessment",
          "subtitle": "5th August, 2024",
          "color": const Color(0xFF06B6D4),
        },
      ];

      if (forceRefresh) {
        isInitialLoadDone.value = true;
      }
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      debugPrint("Error loading dashboard data: $e");
    }
  }

  void processAttendanceData(
    ClassAttendance classData,
    HostelAttendance hostelData,
  ) {
    classChartData.clear();
    classChartMonths.clear();
    hostelChartData.clear();
    hostelChartMonths.clear();

    // Map Class Attendance
    List<MonthlyClassAttendance> classMonths = classData.attendance;
    if (classRange.value == "This Month") {
      classMonths = classMonths.isNotEmpty ? [classMonths.last] : [];
    } else if (classRange.value == "3 Months") {
      classMonths = classMonths.length >= 3
          ? classMonths.sublist(classMonths.length - 3)
          : classMonths;
    } else if (classRange.value == "6 Months") {
      classMonths = classMonths.length >= 6
          ? classMonths.sublist(classMonths.length - 6)
          : classMonths;
    }

    for (var m in classMonths) {
      final String mName = m.monthName;
      classChartMonths.add(mName.length >= 3 ? mName.substring(0, 3) : mName);
      classChartData.add({
        'present': m.present,
        'absent': m.absent,
        'outings': m.outings,
        'holidays': m.holidays,
        'total': m.total,
      });
    }

    // Map Hostel Attendance
    List<MonthlyAttendance> hostelMonths = hostelData.attendance;
    if (hostelRange.value == "This Month") {
      hostelMonths = hostelMonths.isNotEmpty ? [hostelMonths.last] : [];
    } else if (hostelRange.value == "3 Months") {
      hostelMonths = hostelMonths.length >= 3
          ? hostelMonths.sublist(hostelMonths.length - 3)
          : hostelMonths;
    } else if (hostelRange.value == "6 Months") {
      hostelMonths = hostelMonths.length >= 6
          ? hostelMonths.sublist(hostelMonths.length - 6)
          : hostelMonths;
    }

    for (var m in hostelMonths) {
      final String mName = m.monthName;
      hostelChartMonths.add(mName.length >= 3 ? mName.substring(0, 3) : mName);
      hostelChartData.add({'present': m.present, 'absent': m.absent});
    }
  }

  void updateClassRange(String range) {
    classRange.value = range;
    // Reprocess locally with cached data; only fall back to network if nothing is cached
    if (_cachedClassAttendance != null && _cachedHostelAttendance != null) {
      processAttendanceData(_cachedClassAttendance!, _cachedHostelAttendance!);
    } else {
      loadAllData(forceRefresh: true);
    }
  }

  void updateHostelRange(String range) {
    hostelRange.value = range;
    // Reprocess locally with cached data; only fall back to network if nothing is cached
    if (_cachedClassAttendance != null && _cachedHostelAttendance != null) {
      processAttendanceData(_cachedClassAttendance!, _cachedHostelAttendance!);
    } else {
      loadAllData(forceRefresh: true);
    }
  }
}
