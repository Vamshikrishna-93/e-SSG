import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/branch_controller.dart';
import '../controllers/group_controller.dart';
import '../controllers/course_controller.dart';

class SubjectMarksUploadPage extends StatefulWidget {
  const SubjectMarksUploadPage({super.key});

  @override
  State<SubjectMarksUploadPage> createState() => _SubjectMarksUploadPageState();
}

class _SubjectMarksUploadPageState extends State<SubjectMarksUploadPage> {
  // ================= UI Constants =================
  static const Color primaryPurple = Color(0xFF7E49FF);
  static const Color lavenderBg = Color(0xFFF1F4FF);

  // ---------------- CONTROLLERS ----------------
  final BranchController branchCtrl = Get.put(BranchController());
  final GroupController groupCtrl = Get.put(GroupController());
  final CourseController courseCtrl = Get.put(CourseController());

  // ---------------- SELECTED VALUES ----------------
  String? branch;
  String? group;
  String? course;
  String? batch;
  String? exam;
  String? subject;

  int? selectedBranchId;
  int? selectedGroupId;
  int? selectedCourseId;

  // ---------------- STATIC DATA ----------------
  final List<String> batches = ["2023–25", "2024–26", "2025–27"];
  final List<String> exams = [
    "Unit Test–1",
    "Unit Test–2",
    "Quarterly",
    "Half-Yearly",
    "Pre-Final",
    "Final Exam",
  ];
  final List<String> subjects = [
    "Mathematics",
    "Physics",
    "Chemistry",
    "Biology",
    "English",
  ];

  bool _showStudents = false;

  @override
  void initState() {
    super.initState();
    branchCtrl.loadBranches();

    ever(branchCtrl.branches, (_) {
      if (branchCtrl.branches.isNotEmpty && branch == null) {
        final b = branchCtrl.branches.first;
        branch = b.branchName;
        selectedBranchId = b.id;
        groupCtrl.loadGroups(b.id);
        setState(() {});
      }
    });

    ever(groupCtrl.groups, (_) {
      if (groupCtrl.groups.isNotEmpty && group == null) {
        final g = groupCtrl.groups.first;
        group = g.name;
        selectedGroupId = g.id;
        courseCtrl.loadCourses(g.id);
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ================= CUSTOM HEADER =================
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 10,
              bottom: 25,
              left: 20,
              right: 20,
            ),
            decoration: const BoxDecoration(
              color: primaryPurple,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(35),
                bottomRight: Radius.circular(35),
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (_showStudents) {
                      setState(() => _showStudents = false);
                    } else {
                      Get.back();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                const Text(
                  "Subject Marks",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  if (!_showStudents)
                    // ================= FILTER CONTAINER =================
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: lavenderBg.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// -------- BRANCH --------
                          _buildLabel("Branch"),
                          Obx(
                            () => _buildDropdown(
                              hint: "Select Branch",
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
                                  group = null;
                                  course = null;
                                });
                                groupCtrl.loadGroups(b.id);
                              },
                            ),
                          ),

                          /// -------- GROUP --------
                          _buildLabel("Group"),
                          Obx(
                            () => _buildDropdown(
                              hint: groupCtrl.groups.isEmpty
                                  ? "Select Branch First"
                                  : "Select Group",
                              value: group,
                              items: groupCtrl.groups
                                  .map((g) => g.name)
                                  .toList(),
                              onChanged: groupCtrl.groups.isEmpty
                                  ? null
                                  : (v) {
                                      final g = groupCtrl.groups.firstWhere(
                                        (e) => e.name == v,
                                      );
                                      setState(() {
                                        group = v;
                                        course = null;
                                      });
                                      courseCtrl.loadCourses(g.id);
                                    },
                            ),
                          ),

                          /// -------- COURSE --------
                          _buildLabel("Course"),
                          Obx(
                            () => _buildDropdown(
                              hint: courseCtrl.courses.isEmpty
                                  ? "Select Group First"
                                  : "Select Course",
                              value: course,
                              items: courseCtrl.courses
                                  .map((c) => c.courseName)
                                  .toList(),
                              onChanged: courseCtrl.courses.isEmpty
                                  ? null
                                  : (v) {
                                      final c = courseCtrl.courses.firstWhere(
                                        (e) => e.courseName == v,
                                      );
                                      setState(() {
                                        course = v;
                                        selectedCourseId = c.id;
                                      });
                                    },
                            ),
                          ),

                          _buildLabel("Batch"),
                          _buildDropdown(
                            hint: "Select Batch",
                            value: batch,
                            items: batches,
                            onChanged: (v) => setState(() => batch = v),
                          ),

                          _buildLabel("Exam"),
                          _buildDropdown(
                            hint: "Select Exam",
                            value: exam,
                            items: exams,
                            onChanged: (v) => setState(() => exam = v),
                          ),

                          _buildLabel("Subject"),
                          _buildDropdown(
                            hint: "Select Subject",
                            value: subject,
                            items: subjects,
                            onChanged: (v) => setState(() => subject = v),
                          ),

                          const SizedBox(height: 25),

                          // ================= GET STUDENTS BUTTON =================
                          Container(
                            width: double.infinity,
                            height: 55,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF7C69FF), Color(0xFFD38DFA)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _showStudents = true;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Get Students",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    // ================= STUDENTS LIST CONTAINER =================
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: lavenderBg.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Column(
                        children: [
                          _buildStudentMarkCard(0),
                          _buildStudentMarkCard(1),
                          _buildStudentMarkCard(2),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ================= BOTTOM BAR =================
          if (!_showStudents)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF7E49FF), Color(0xFFD199FF)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.file_download_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                        label: const Text(
                          "Download Format",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4ACBC9), Color(0xFFA5E68C)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.file_upload_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                        label: const Text(
                          "Mark Bulk Upload",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStudentMarkCard(int index) {
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
          _badgeRow(
            "Marks",
            "28",
            const Color(0xFFE0E7FF), // Light blue background
            const Color(0xFF3B82F6), // Strong blue text
          ),
          const SizedBox(height: 12),
          _badgeRow(
            "Rank",
            "357",
            const Color(0xFFDCFCE7), // Light green background
            const Color(0xFF22C55E), // Strong green text
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
          width: 105,
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

  Widget _badgeRow(String label, String value, Color bgColor, Color textColor) {
    return Row(
      children: [
        SizedBox(
          width: 105,
          child: Text(
            "$label :",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required void Function(String?)? onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          hint: Text(
            hint,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
          items: items.map((e) {
            return DropdownMenuItem(
              value: e,
              child: Text(
                e,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
