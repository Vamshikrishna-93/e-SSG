import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/class_attendance_controller.dart';
import '../controllers/branch_controller.dart';
import '../controllers/group_controller.dart';
import '../controllers/course_controller.dart';
import '../controllers/batch_controller.dart';
import '../controllers/shift_controller.dart';
import '../widgets/staff_header.dart';

class ClassAttendancePage extends StatefulWidget {
  const ClassAttendancePage({super.key});

  @override
  State<ClassAttendancePage> createState() => _ClassAttendancePageState();
}

class _ClassAttendancePageState extends State<ClassAttendancePage> {
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
    _loadInitialData();
  }

  void _loadInitialData() {
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
            const StaffHeader(title: "Class Attendance"),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 25),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
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

  // ================= ATTENDANCE LIST =================

  Widget _buildAttendanceList(BuildContext context) {
    final bool isAllPresent =
        controller.attendanceList.isNotEmpty &&
        controller.presentCount == controller.attendanceList.length;
    final bool isAllAbsent =
        controller.attendanceList.isNotEmpty &&
        controller.absentCount == controller.attendanceList.length;

    return Column(
      children: [
        // ================= TOP ACTION BUTTONS =================
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: controller.markAllPresent,
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: isAllPresent
                          ? const Color(0xFF036423) // Darker Green from image
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: isAllPresent
                          ? null
                          : Border.all(color: const Color(0xFF036423)),
                      boxShadow: [
                        if (!isAllPresent)
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 4,
                            offset: const Offset(0, 0),
                          ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: isAllPresent
                              ? Colors.white
                              : const Color(0xFF036423),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "All Present",
                          style: TextStyle(
                            color: isAllPresent
                                ? Colors.white
                                : const Color(0xFF036423),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: GestureDetector(
                  onTap: controller.markAllAbsent,
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: isAllAbsent
                          ? const Color(0xFFEF4444)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: isAllAbsent
                          ? null
                          : Border.all(color: const Color(0xFFEF4444)),
                      boxShadow: [
                        if (!isAllAbsent)
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 4,
                            offset: const Offset(0, 0),
                          ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cancel_outlined,
                          color: isAllAbsent
                              ? Colors.white
                              : const Color(0xFFEF4444),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "All Absent",
                          style: TextStyle(
                            color: isAllAbsent
                                ? Colors.white
                                : const Color(0xFFEF4444),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ================= STAT SUMMARY CARDS =================
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
                "Total", // Present count in image shows 'Total' label but green value
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

        // ================= STUDENT LIST IN LAVENDER BOX =================
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(
              0xFFF5F3FF,
            ), // Specific lavender background from image
            borderRadius: BorderRadius.circular(30),
          ),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.attendanceList.length,
            itemBuilder: (context, index) {
              final student = controller.attendanceList[index];
              final isPresent = controller.attendanceStatus[index] ?? true;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 4,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Purple Index Circle
                    Container(
                      width: 45,
                      height: 45,
                      decoration: const BoxDecoration(
                        color: Color(0xFFBCADF8), // Lighter purple from image
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          "${index + 1}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
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
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Adm No : ${student.admno}",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Square P/A Toggle
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
            },
          ),
        ),
      ],
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 4,
              offset: const Offset(0, 0),
            ),
          ],
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
              colors: [Color(0xFF7D74FC), Color(0xFFD08EF7)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF818CFF).withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
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

  // ================= HEADER =================

  // Removed local _buildHeader as it is replaced by StaffHeader widget

  // ================= FILTER CONTAINER =================

  Widget _buildFilterContainer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3FF), // Light Lavender
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Branch
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
                // Reset dependent selections
                groupCtrl.selectedGroup.value = null;
                courseCtrl.selectedCourse.value = null;
                batchCtrl.selectedBatch.value = null;
                shiftCtrl.selectedShift.value = null;
              }
            },
          ),
          const SizedBox(height: 15),

          // Group
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
                // Reset dependent
                courseCtrl.selectedCourse.value = null;
                batchCtrl.selectedBatch.value = null;
              }
            },
          ),
          const SizedBox(height: 15),

          // Course
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
                // Reset dependent
                batchCtrl.selectedBatch.value = null;
              }
            },
          ),
          const SizedBox(height: 15),

          // Batch
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
              if (model != null) {
                batchCtrl.selectedBatch.value = model;
              }
            },
          ),
          const SizedBox(height: 15),

          // Shift
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
              if (model != null) {
                shiftCtrl.selectedShift.value = model;
              }
            },
          ),
          const SizedBox(height: 25),

          // GET STUDENTS BUTTON
          _buildGradientButton(),
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
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A4A4A),
            ),
          ),
        ),
        Obx(
          () => Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 4,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                hint: Text(
                  hint,
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                ),
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.black54,
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
                        fontSize: 14,
                        color: Colors.black87,
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

  Widget _buildGradientButton() {
    return GestureDetector(
      onTap: () {
        if (controller.isReady) {
          controller.loadClassAttendance();
        } else {
          Get.snackbar(
            "Selection Required",
            "Please select all filters to fetch attendance",
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(20),
          );
        }
      },
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7D74FC), Color(0xFFD08EF7)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8B5CF6).withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
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
            Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }

  // ================= NO DATA STATE =================

  Widget _buildNoDataState(BuildContext context) {
    return Column(
      children: [
        Image.network(
          'https://cdni.iconscout.com/illustration/premium/thumb/no-data-found-8867280-7265556.png',
          height: 180,
          errorBuilder: (context, error, stackTrace) => Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF5F3FF),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const Icon(
                    Icons.folder_open_rounded,
                    size: 80,
                    color: Color(0xFFC084FC),
                  ),
                  Positioned(
                    right: 20,
                    top: 20,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.question_mark_rounded,
                        size: 20,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
        const SizedBox(height: 10),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            "Select filters and click 'Get Students' to view attendance",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
          ),
        ),
      ],
    );
  }
}
