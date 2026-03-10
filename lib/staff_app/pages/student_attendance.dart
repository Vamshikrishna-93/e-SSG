import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:student_app/staff_app/controllers/monthly_attendance_controller.dart';
import 'package:student_app/staff_app/controllers/shift_controller.dart';
import 'package:student_app/staff_app/controllers/main_controller.dart';
import 'package:student_app/staff_app/pages/student_attendance_view_page.dart';

import '../controllers/branch_controller.dart';
import '../controllers/group_controller.dart';
import '../controllers/course_controller.dart';
import '../controllers/batch_controller.dart';
import '../widgets/staff_header.dart';

class StudentAttendancePage extends StatefulWidget {
  const StudentAttendancePage({super.key});

  @override
  State<StudentAttendancePage> createState() => _StudentAttendancePageState();
}

class _StudentAttendancePageState extends State<StudentAttendancePage> {
  // ================= CONTROLLERS =================
  final BranchController branchCtrl = Get.put(BranchController());
  final GroupController groupCtrl = Get.put(GroupController());
  final CourseController courseCtrl = Get.put(CourseController());
  final BatchController batchCtrl = Get.put(BatchController());
  final ShiftController shiftCtrl = Get.put(ShiftController());
  final MonthlyAttendanceController attendanceCtrl = Get.put(
    MonthlyAttendanceController(),
  );

  // ================= SELECTED VALUES =================
  String? branch;
  String? group;
  String? course;
  String? batch;
  String? shift;
  String? month;
  String? selectedMonthName;

  bool _showStudents = false;

  final Map<String, String> monthMap = {
    "January": "01",
    "February": "02",
    "March": "03",
    "April": "04",
    "May": "05",
    "June": "06",
    "July": "07",
    "August": "08",
    "September": "09",
    "October": "10",
    "November": "11",
    "December": "12",
  };

  @override
  void initState() {
    super.initState();

    branchCtrl.loadBranches();

    ever(branchCtrl.branches, (_) {
      if (branchCtrl.branches.isNotEmpty && branch == null) {
        final b = branchCtrl.branches.first;
        branch = b.branchName;
        groupCtrl.loadGroups(b.id);
        setState(() {});
      }
    });

    ever(groupCtrl.groups, (_) {
      if (groupCtrl.groups.isNotEmpty && group == null) {
        final g = groupCtrl.groups.first;
        group = g.name;
        courseCtrl.loadCourses(g.id);
        setState(() {});
      }
    });

    Get.put(StaffMainController(), permanent: true).changeIndex(1);
  }

  @override
  Widget build(BuildContext context) {
    const lavenderBg = Color(0xFFF3EBFF);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          StaffHeader(
            title: "Students Attendance",
            onBack: _showStudents
                ? () => setState(() => _showStudents = false)
                : null,
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!_showStudents) ...[
                    const Text(
                      "Select filters to view students attendance\nrecords",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ================= FILTER CARD =================
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: lavenderBg,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Column(
                        children: [
                          Obx(
                            () => _buildFilterField(
                              label: "Branch",
                              value: branch,
                              items: branchCtrl.branches
                                  .map((b) => b.branchName)
                                  .toList(),
                              onChanged: (v) {
                                final b = branchCtrl.branches.firstWhere(
                                  (e) => e.branchName == v,
                                );
                                setState(() {
                                  branch = v;
                                  group = course = batch = shift = month = null;
                                  selectedMonthName = null;
                                });
                                groupCtrl.loadGroups(b.id);
                                shiftCtrl.loadShifts(b.id);
                              },
                            ),
                          ),
                          Obx(
                            () => _buildFilterField(
                              label: "Group",
                              value: group,
                              items: groupCtrl.groups
                                  .map((g) => g.name)
                                  .toList(),
                              onChanged: (v) {
                                final g = groupCtrl.groups.firstWhere(
                                  (e) => e.name == v,
                                );
                                setState(() {
                                  group = v;
                                  course = batch = null;
                                });
                                courseCtrl.loadCourses(g.id);
                              },
                            ),
                          ),
                          Obx(
                            () => _buildFilterField(
                              label: "Course",
                              value: course,
                              items: courseCtrl.courses
                                  .map((c) => c.courseName)
                                  .toList(),
                              onChanged: (v) {
                                final c = courseCtrl.courses.firstWhere(
                                  (e) => e.courseName == v,
                                );
                                setState(() {
                                  course = v;
                                  batch = null;
                                });
                                batchCtrl.loadBatches(c.id);
                              },
                            ),
                          ),
                          Obx(
                            () => _buildFilterField(
                              label: "Batch",
                              value: batch,
                              items: batchCtrl.batches
                                  .map((b) => b.batchName)
                                  .toList(),
                              onChanged: (v) => setState(() => batch = v),
                            ),
                          ),
                          Obx(
                            () => _buildFilterField(
                              label: "Shift",
                              value: shift,
                              items: shiftCtrl.shifts
                                  .map((s) => s.shiftName)
                                  .toList(),
                              onChanged: (v) => setState(() => shift = v),
                            ),
                          ),
                          _buildFilterField(
                            label: "Month",
                            value: selectedMonthName,
                            items: monthMap.keys.toList(),
                            onChanged: (v) => setState(() {
                              selectedMonthName = v;
                              month = monthMap[v!];
                            }),
                          ),
                          const SizedBox(height: 10),

                          // ================= GET STUDENTS BUTTON =================
                          Obx(
                            () => Container(
                              width: double.infinity,
                              height: 55,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF7D74FC),
                                    Color(0xFFD08EF7),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ElevatedButton(
                                onPressed: (attendanceCtrl.isLoading.value)
                                    ? null
                                    : () {
                                        // Setting UI straight to students to show the layout per prompt
                                        setState(() => _showStudents = true);
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: attendanceCtrl.isLoading.value
                                    ? const Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: const [
                                          Text(
                                            "Get Students",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Icon(
                                            Icons.arrow_forward,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // ================= STUDENTS LIST CONTAINER =================
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: lavenderBg.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Column(
                        children: [
                          _buildStudentCard(0),
                          _buildStudentCard(1),
                          _buildStudentCard(2),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "S.NO: 1",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                "Adm No : 251288",
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(color: Colors.grey.shade200, height: 1.5),
          const SizedBox(height: 12),
          _infoRow("Student Name", "Pulagara Veera Vasatha\nRayudu"),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                width: 140,
                child: Text(
                  "Attendance Status :",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Get.to(() => const StudentAttendanceViewPage());
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7), // Light green background
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "View Attendance",
                        style: TextStyle(
                          color: Color(0xFF16A34A), // Strong green text
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Color(0xFF16A34A),
                        size: 10,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            "$label :",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterField({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                hint: Text(
                  "Select $label",
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.black54,
                ),
                items: items
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(
                          e,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
