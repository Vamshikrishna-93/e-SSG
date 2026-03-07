import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/class_attendance_controller.dart';
import '../controllers/branch_controller.dart';
import '../controllers/group_controller.dart';
import '../controllers/course_controller.dart';
import '../controllers/batch_controller.dart';
import '../controllers/shift_controller.dart';

class StudentAttendanceFilterPage extends StatefulWidget {
  const StudentAttendanceFilterPage({super.key});

  @override
  State<StudentAttendanceFilterPage> createState() =>
      _StudentAttendanceFilterPageState();
}

class _StudentAttendanceFilterPageState
    extends State<StudentAttendanceFilterPage> {
  // ================= CONTROLLERS =================
  final BranchController branchCtrl = Get.put(BranchController());
  final GroupController groupCtrl = Get.put(GroupController());
  final CourseController courseCtrl = Get.put(CourseController());
  final BatchController batchCtrl = Get.put(BatchController());
  final ShiftController shiftCtrl = Get.put(ShiftController());
  final ClassAttendanceController controller = Get.put(
    ClassAttendanceController(),
  );

  @override
  void initState() {
    super.initState();
    branchCtrl.loadBranches();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        final hasData = controller.attendanceList.isNotEmpty;
        final isLoading = controller.isLoading.value;

        return Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 25),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildFilterContainer(context),
                    ),
                    const SizedBox(height: 30),
                    if (isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40.0),
                          child: CircularProgressIndicator(
                            color: Color(0xFF7E49FF),
                          ),
                        ),
                      )
                    else if (hasData)
                      _buildAttendanceList(context)
                    else
                      _buildNoDataState(context),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
            if (hasData) _buildSubmitBottomBar(),
          ],
        );
      }),
    );
  }

  // ================= HEADER =================

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 25,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF7E49FF),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
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
            "Class Attendance",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ================= FILTER CONTAINER =================

  Widget _buildFilterContainer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3FF),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDropdownField(
            label: "Branch",
            hint: "Select Branch",
            itemsCtrl: branchCtrl.branches,
            value: branchCtrl.selectedBranch.value?.branchName,
            onChanged: (v) {
              final model = branchCtrl.branches.firstWhereOrNull(
                (e) => e.branchName == v,
              );
              if (model != null) {
                branchCtrl.selectedBranch.value = model;
                groupCtrl.loadGroups(model.id);
                shiftCtrl.loadShifts(model.id);
                groupCtrl.selectedGroup.value = null;
                courseCtrl.selectedCourse.value = null;
                batchCtrl.selectedBatch.value = null;
                shiftCtrl.selectedShift.value = null;
              }
            },
          ),
          _buildDropdownField(
            label: "Group",
            hint: "Select Group",
            itemsCtrl: groupCtrl.groups,
            labelGetter: (e) => e.name,
            value: groupCtrl.selectedGroup.value?.name,
            onChanged: (v) {
              final model = groupCtrl.groups.firstWhereOrNull(
                (e) => e.name == v,
              );
              if (model != null) {
                groupCtrl.selectedGroup.value = model;
                courseCtrl.loadCourses(model.id);
                courseCtrl.selectedCourse.value = null;
                batchCtrl.selectedBatch.value = null;
              }
            },
          ),
          _buildDropdownField(
            label: "Course",
            hint: "Select Course",
            itemsCtrl: courseCtrl.courses,
            labelGetter: (e) => e.courseName,
            value: courseCtrl.selectedCourse.value?.courseName,
            onChanged: (v) {
              final model = courseCtrl.courses.firstWhereOrNull(
                (e) => e.courseName == v,
              );
              if (model != null) {
                courseCtrl.selectedCourse.value = model;
                batchCtrl.loadBatches(model.id);
                batchCtrl.selectedBatch.value = null;
              }
            },
          ),
          _buildDropdownField(
            label: "Batch",
            hint: "Select Batch",
            itemsCtrl: batchCtrl.batches,
            labelGetter: (e) => e.batchName,
            value: batchCtrl.selectedBatch.value?.batchName,
            onChanged: (v) {
              final model = batchCtrl.batches.firstWhereOrNull(
                (e) => e.batchName == v,
              );
              if (model != null) batchCtrl.selectedBatch.value = model;
            },
          ),
          _buildDropdownField(
            label: "Shift",
            hint: "Select Shift",
            itemsCtrl: shiftCtrl.shifts,
            labelGetter: (e) => (e as dynamic).shiftName,
            value: shiftCtrl.selectedShift.value != null
                ? (shiftCtrl.selectedShift.value as dynamic).shiftName
                : null,
            onChanged: (v) {
              final model = shiftCtrl.shifts.firstWhereOrNull(
                (e) => (e as dynamic).shiftName == v,
              );
              if (model != null) shiftCtrl.selectedShift.value = model;
            },
          ),
          const SizedBox(height: 15),
          _buildActionButton(),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String hint,
    required RxList itemsCtrl,
    String Function(dynamic)? labelGetter,
    String? value,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        Obx(
          () => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                hint: Text(
                  hint,
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                ),
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.black54,
                  size: 20,
                ),
                items: itemsCtrl.map((item) {
                  final text = labelGetter != null
                      ? labelGetter(item)
                      : (item is String ? item : (item as dynamic).branchName);
                  return DropdownMenuItem<String>(
                    value: text,
                    child: Text(
                      text,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    return GestureDetector(
      onTap: () {
        if (controller.isReady) {
          controller.loadClassAttendance();
        } else {
          Get.snackbar(
            "Selection Required",
            "Please select all filters to continue",
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            margin: const Offset(0, 20).distance > 0
                ? const EdgeInsets.all(20)
                : null,
          );
        }
      },
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8B5CF6), Color(0xFFC084FC)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8B5CF6).withOpacity(0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Get Students",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  // ================= ATTENDANCE LIST (3rd Pic) =================

  Widget _buildAttendanceList(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Row(
            children: [
              Expanded(
                child: _buildBulkActionBtn(
                  "All Present",
                  const Color(0xFF036423),
                  Icons.check_circle_outline,
                  controller.markAllPresent,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildBulkActionBtn(
                  "All Absent",
                  Colors.white,
                  Icons.cancel_outlined,
                  controller.markAllAbsent,
                  isBordered: true,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              _buildStatSummaryCard(
                "Total",
                "${controller.attendanceList.length}",
                const Color(0xFFF5F3FF),
                const Color(0xFF7E49FF),
              ),
              const SizedBox(width: 10),
              _buildStatSummaryCard(
                "Total",
                "${controller.presentCount}",
                const Color(0xFFECFDF5),
                const Color(0xFF10B981),
              ),
              const SizedBox(width: 10),
              _buildStatSummaryCard(
                "Absent",
                "${controller.absentCount}",
                const Color(0xFFFEF2F2),
                const Color(0xFFEF4444),
              ),
            ],
          ),
        ),
        const SizedBox(height: 25),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F3FF),
            borderRadius: BorderRadius.circular(30),
          ),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.attendanceList.length,
            itemBuilder: (context, index) {
              final student = controller.attendanceList[index];
              final isPresent = controller.attendanceStatus[index] ?? true;
              return _buildStudentCard(student, isPresent, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBulkActionBtn(
    String label,
    Color color,
    IconData icon,
    VoidCallback onTap, {
    bool isBordered = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: isBordered
              ? Border.all(color: const Color(0xFFEF4444))
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isBordered ? const Color(0xFFEF4444) : Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isBordered ? const Color(0xFFEF4444) : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatSummaryCard(
    String label,
    String value,
    Color bgColor,
    Color textColor,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: bgColor, width: 2),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: textColor.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentCard(dynamic student, bool isPresent, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: const BoxDecoration(
              color: Color(0xFFBCADF8),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                "${index + 1}",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.fullName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  "Adm No : ${student.admno}",
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => controller.toggleAttendance(index),
            child: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: isPresent
                    ? const Color(0xFF67B56B)
                    : const Color(0xFFEF4444),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  isPresent ? "P" : "A",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitBottomBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Obx(
        () => Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF818CFF), Color(0xFFCE93F9)],
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: ElevatedButton(
            onPressed: controller.isSubmitting.value
                ? null
                : controller.submitAttendance,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: controller.isSubmitting.value
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    "Submit Attendance",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoDataState(BuildContext context) {
    return Column(
      children: [
        const Icon(
          Icons.folder_open_rounded,
          size: 80,
          color: Color(0xFFBCADF8),
        ),
        const SizedBox(height: 20),
        const Text(
          "No Attendance Data",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            "Select filters and click 'Get Students' to view attendance",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ),
      ],
    );
  }
}
