import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:student_app/staff_app/model/attendance_model.dart';

import 'branch_controller.dart';
import 'group_controller.dart';
import 'course_controller.dart';
import 'batch_controller.dart';
import 'shift_controller.dart';
import '../api/api_service.dart';
import '../api/api_collection.dart';
import '../widgets/success_dialog.dart';

class ClassAttendanceController extends GetxController {
  // ================= DEPENDENT CONTROLLERS (LAZY & SAFE) =================
  BranchController? get branchCtrl {
    try {
      return Get.find<BranchController>();
    } catch (e) {
      return null;
    }
  }

  GroupController? get groupCtrl {
    try {
      return Get.find<GroupController>();
    } catch (e) {
      return null;
    }
  }

  CourseController? get courseCtrl {
    try {
      return Get.find<CourseController>();
    } catch (e) {
      return null;
    }
  }

  BatchController? get batchCtrl {
    try {
      return Get.find<BatchController>();
    } catch (e) {
      return null;
    }
  }

  ShiftController? get shiftCtrl {
    try {
      return Get.find<ShiftController>();
    } catch (e) {
      return null;
    }
  }

  // ================= MONTH =================
  final RxString selectedMonth = ''.obs; // format: YYYY-MM
  final Rx<DateTime> selectedDate = DateTime.now().obs;

  // ================= ATTENDANCE STATE =================
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxList<StudentAttendance> attendanceList = <StudentAttendance>[].obs;
  final RxString errorMessage = ''.obs;
  final RxBool isSubmitted = false.obs;
  final RxBool hasExistingAttendance = false.obs;

  // ================= MARK ATTENDANCE STATE =================
  // Map<sid, isPresent> — true = Present, false = Absent
  final RxMap<int, bool> attendanceStatus = <int, bool>{}.obs;

  // ================= VALIDATION =================
  bool get isReady {
    return branchCtrl?.selectedBranch.value != null &&
        groupCtrl?.selectedGroup.value != null &&
        courseCtrl?.selectedCourse.value != null &&
        batchCtrl?.selectedBatch.value != null &&
        shiftCtrl?.selectedShift.value != null;
  }

  // ================= LOAD STUDENTS =================
  Future<void> loadClassAttendance() async {
    if (!isReady) {
      Get.snackbar(
        "Error",
        "Please select all fields (Branch, Group, Course, Batch, Shift)",
      );
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';
      isSubmitted.value = false;
      hasExistingAttendance.value = false;
      attendanceList.clear();
      attendanceStatus.clear();

      final String dateStr = selectedDate.value
          .toString()
          .split(' ')
          .first; // YYYY-MM-DD

      final res = await ApiService.getRequest(
        ApiCollection.getStudentsAttendanceList(
          shiftId: shiftCtrl?.selectedShift.value?.id ?? 0,
          date: dateStr,
          batchId: batchCtrl?.selectedBatch.value?.id ?? 0,
        ),
      );

      final success = res['success'] == true || res['success'] == "true";
      final hasData = res['indexdata'] != null || res['attendanceData'] != null;

      if (success || hasData) {
        // 🔍 HIGH-VISIBILITY DEBUG
        print("#######################################################");
        print("### CLASS ATTENDANCE RAW DATA START ###");
        print("### FULL RESPONSE: $res");

        final rawList = (res['indexdata'] ?? res['attendanceData']) as List?;
        if (rawList != null && rawList.isNotEmpty) {
          final first = rawList.first;
          print("### FIRST STUDENT: $first");
          if (first is Map) {
            print("### KEYS DETECTED: ${first.keys.toList()}");
          }
        }
        print("### CLASS ATTENDANCE RAW DATA END ###");
        print("#######################################################");

        final attendanceResponse = AttendanceResponse.fromJson(res);
        attendanceList.assignAll(attendanceResponse.indexdata);

        // ✅ Set initial status based on the selected day
        final int currentDay = selectedDate.value.day;
        bool anyFound = false;

        for (int i = 0; i < attendanceResponse.indexdata.length; i++) {
          final student = attendanceResponse.indexdata[i];
          final String statusForToday = student.getAttendanceForDay(currentDay);

          if (statusForToday == 'P') {
            attendanceStatus[i] = true;
            anyFound = true;
          } else if (statusForToday == 'A') {
            attendanceStatus[i] = false;
            anyFound = true;
          } else {
            // Default to Present if no record exists
            attendanceStatus[i] = true;
          }
        }

        hasExistingAttendance.value = anyFound;

        // If it was an "Already Taken" case, we still set the error message for the UI badge
        if (!success) {
          errorMessage.value =
              (res['message'] ?? res['msg'] ?? "Attendance Already Taken")
                  .toString();
        }
      } else {
        errorMessage.value =
            (res['message'] ?? res['msg'] ?? "No students found").toString();
      }
    } catch (e) {
      errorMessage.value = "Failed to load students: ${e.toString()}";
      Get.snackbar("Error", errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  // ================= TOGGLE ATTENDANCE =================
  void toggleAttendance(int index) {
    attendanceStatus[index] = !(attendanceStatus[index] ?? true);
  }

  void markAllPresent() {
    for (int i = 0; i < attendanceList.length; i++) {
      attendanceStatus[i] = true;
    }
  }

  void markAllAbsent() {
    for (int i = 0; i < attendanceList.length; i++) {
      attendanceStatus[i] = false;
    }
  }

  // ================= SUBMIT ATTENDANCE =================
  Future<void> submitAttendance() async {
    if (attendanceList.isEmpty) {
      Get.snackbar("Error", "No students loaded. Please fetch students first.");
      return;
    }

    // 🔍 VALIDATION: Ensure no student IDs are 0 or missing
    final invalidStudents = attendanceList.where((s) => s.sid == 0).toList();
    if (invalidStudents.isNotEmpty) {
      Get.snackbar(
        "Critical Error",
        "Found ${invalidStudents.length} students with missing IDs. Cannot submit.",
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        duration: const Duration(seconds: 5),
      );
      return;
    }

    // Collect SIDs and Statuses for ALL students
    final sidList = <int>[];
    final statusList = <String>[];
    for (int i = 0; i < attendanceList.length; i++) {
      sidList.add(attendanceList[i].sid);
      statusList.add((attendanceStatus[i] == true) ? 'P' : 'A');
    }

    try {
      isSubmitting.value = true;

      final res = await ApiService.storeStudentAttendance(
        branchId: branchCtrl?.selectedBranch.value?.id ?? 0,
        groupId: groupCtrl?.selectedGroup.value?.id ?? 0,
        courseId: courseCtrl?.selectedCourse.value?.id ?? 0,
        batchId: batchCtrl?.selectedBatch.value?.id ?? 0,
        shiftId: shiftCtrl?.selectedShift.value?.id ?? 0,
        sidList: sidList,
        statusList: statusList,
      );

      final bool success = res['success'] == true || res['success'] == "true";

      if (success) {
        // ✅ NEW: FINAL VERIFICATION STORAGE
        // This sends the summary totals to the verification endpoint
        // (Optional: You can skip this if the backend already handles summaries)
        try {
          await ApiService.storeVerifyAttendance(
            branchIds: [branchCtrl?.selectedBranch.value?.id ?? 0],
            groupIds: [groupCtrl?.selectedGroup.value?.id ?? 0],
            courseIds: [courseCtrl?.selectedCourse.value?.id ?? 0],
            batchIds: [batchCtrl?.selectedBatch.value?.id ?? 0],
            totalStrengths: [attendanceList.length],
            totalPresents: [presentCount],
            totalAbsents: [absentCount],
          );
        } catch (e) {
          debugPrint(
            "Summary verification failed but attendance was stored: $e",
          );
        }

        // Show custom success dialog
        Get.dialog(
          SuccessDialog(
            title: "Success",
            message: "Attendance has been submitted successfully!",
            total: attendanceList.length,
            present: presentCount,
            absent: absentCount,
            onConfirm: () {
              Get.back(); // close dialog
              isSubmitted.value = true;
            },
          ),
          barrierDismissible: false,
        );
      } else {
        Get.snackbar(
          "Submission Failed",
          res['message'] ?? res['msg'] ?? "Server rejected the submission",
          backgroundColor: Colors.orange.withOpacity(0.1),
        );
      }
    } catch (e) {
      // 🔍 Better Error Extraction
      String message = e.toString();
      if (message.contains("{")) {
        try {
          // 🔍 SAFER JSON ERROR EXTRACTION
          final int start = message.indexOf("{");
          final String jsonPart = message.substring(start);
          final Map<String, dynamic> errorBody = json.decode(
            Uri.decodeComponent(jsonPart),
          );

          message = errorBody['error'] ?? errorBody['message'] ?? message;
        } catch (_) {}
      }

      Get.snackbar(
        "Error",
        message.replaceFirst("Exception: API Error 422: ", ""),
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  // ================= HELPERS =================

  int get presentCount => attendanceStatus.values.where((v) => v).length;

  int get absentCount => attendanceStatus.values.where((v) => !v).length;

  // ================= CLEAR =================
  void clear() {
    attendanceList.clear();
    attendanceStatus.clear();
    errorMessage.value = '';
    isSubmitted.value = false;
  }
}
