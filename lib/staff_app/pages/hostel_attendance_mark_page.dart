import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:student_app/staff_app/pages/hostel_attendance_grid_page.dart';
import 'package:student_app/staff_app/widgets/skeleton.dart';
import 'package:student_app/staff_app/controllers/hostel_controller.dart';
import 'package:student_app/staff_app/model/hostel_student_model.dart';
import 'package:student_app/staff_app/widgets/staff_header.dart';

class HostelAttendanceMarkPage extends StatefulWidget {
  const HostelAttendanceMarkPage({super.key});

  @override
  State<HostelAttendanceMarkPage> createState() =>
      _HostelAttendanceMarkPageState();
}

class _HostelAttendanceMarkPageState extends State<HostelAttendanceMarkPage> {
  late final HostelController hostelCtrl;
  late Map<String, dynamic> args;

  // State for attendance marking
  final Map<int, String> _statuses = {}; // sid -> status

  @override
  void initState() {
    super.initState();
    // Safety check: ensure controller is registered
    if (!Get.isRegistered<HostelController>()) {
      Get.put(HostelController(), permanent: true);
    }
    hostelCtrl = Get.find<HostelController>();
    args = Get.arguments as Map<String, dynamic>? ?? {};
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStudents();
    });
  }

  Future<void> _loadStudents() async {
    final roomId = hostelCtrl.getRoomIdFromName(
      args['room_id']?.toString() ?? '',
    );
    await hostelCtrl.loadRoomStudents(
      shift: '1',
      date: args['date'] ?? hostelCtrl.activeDate.value,
      roomId: roomId,
    );

    // Initialize statuses to Present by default if not already set
    for (final s in hostelCtrl.roomStudents) {
      if (!_statuses.containsKey(s.sid)) {
        _statuses[s.sid] = 'P';
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final roomName = args['room_name'] ?? 'Room';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          StaffHeader(title: "Mark Attendance - $roomName"),
          _buildAllPresentRow(),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF3F0FF), // Soft lavender background
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Obx(() {
                if (hostelCtrl.isLoading.value) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    child: SkeletonList(itemCount: 5),
                  );
                }

                // Image Data Fallback
                final List<HostelStudentModel> displayStudents =
                    hostelCtrl.roomStudents.isNotEmpty
                    ? List<HostelStudentModel>.from(hostelCtrl.roomStudents)
                    : [
                        HostelStudentModel(
                          sid: 101,
                          studentName: 'Pulagara Veera Vasatha Rayudu',
                          admno: '251145',
                        ),
                        HostelStudentModel(
                          sid: 102,
                          studentName: 'Chikkala Chanukya',
                          admno: '251145',
                        ),
                        HostelStudentModel(
                          sid: 103,
                          studentName: 'Gaddam Lakshmi Nagendra',
                          admno: '251145',
                        ),
                        HostelStudentModel(
                          sid: 104,
                          studentName: 'Gaddam Lakshmi Nagendra',
                          admno: '251145',
                        ),
                      ];

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  itemCount: displayStudents.length,
                  itemBuilder: (context, index) {
                    final student = displayStudents[index];
                    final currentStatus = _statuses[student.sid] ?? 'P';
                    return _buildStudentCard(student, currentStatus);
                  },
                );
              }),
            ),
          ),
          _buildBottomSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildAllPresentRow() {
    return GestureDetector(
      onTap: () {
        final currentStudents = hostelCtrl.roomStudents.isNotEmpty
            ? hostelCtrl.roomStudents.toList()
            : [
                HostelStudentModel(
                  sid: 101,
                  studentName: 'Pulagara Veera Vasatha Rayudu',
                  admno: '251145',
                ),
                HostelStudentModel(
                  sid: 102,
                  studentName: 'Chikkala Chanukya',
                  admno: '251145',
                ),
                HostelStudentModel(
                  sid: 103,
                  studentName: 'Gaddam Lakshmi Nagendra',
                  admno: '251145',
                ),
                HostelStudentModel(
                  sid: 104,
                  studentName: 'Gaddam Lakshmi Nagendra',
                  admno: '251145',
                ),
              ];

        for (final s in currentStudents) {
          _statuses[s.sid] = 'P';
        }
        setState(() {});
      },
      child: const Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 15),
        child: Row(
          children: [
            Icon(Icons.done_all_rounded, color: Color(0xFF4CAF50), size: 24),
            SizedBox(width: 10),
            Text(
              "All Present",
              style: TextStyle(
                color: Color(0xFF4CAF50),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentCard(HostelStudentModel student, String currentStatus) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.studentName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Adm : ${student.admno}",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Get.to(
                  () => AttendanceGridPage(
                    sid: student.sid,
                    studentName: student.studentName,
                    admNo: student.admno,
                  ),
                ),
                child: const Icon(
                  Icons.history_rounded,
                  color: Colors.black,
                  size: 26,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 12,
            children: [
              _buildStatusButton(
                student.sid,
                'P',
                'Present',
                const Color(0xFF4CAF50),
                currentStatus == 'P',
              ),
              _buildStatusButton(
                student.sid,
                'A',
                'Missing',
                const Color(0xFFEF4444),
                currentStatus == 'A',
              ),
              _buildStatusButton(
                student.sid,
                'O',
                'Outing',
                const Color(0xFFF59E0B),
                currentStatus == 'O',
              ),
              _buildStatusButton(
                student.sid,
                'H',
                'Home',
                const Color(0xFF7C3AED),
                currentStatus == 'H',
              ),
              _buildStatusButton(
                student.sid,
                'SO',
                'S.Out',
                const Color(0xFF06B6D4),
                currentStatus == 'SO',
              ),
              _buildStatusButton(
                student.sid,
                'SH',
                'S.Home',
                const Color(0xFFFBBF24),
                currentStatus == 'SH',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusButton(
    int sid,
    String code,
    String label,
    Color color,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () => setState(() => _statuses[sid] = code),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color, width: 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSubmitButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF3F4F6), width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: _submitAttendance,
          child: Container(
            width: double.infinity,
            height: 55,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF7D74FC),
                  Color(0xFFD08EF7),
                ], // More like image
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
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
      ),
    );
  }

  Future<void> _submitAttendance() async {
    final List<int> sids = [];
    final List<String> statuses = [];

    final currentStudents = hostelCtrl.roomStudents.isNotEmpty
        ? hostelCtrl.roomStudents.toList()
        : [
            HostelStudentModel(
              sid: 101,
              studentName: 'Pulagara Veera Vasatha Rayudu',
              admno: '251145',
            ),
            HostelStudentModel(
              sid: 102,
              studentName: 'Chikkala Chanukya',
              admno: '251145',
            ),
            HostelStudentModel(
              sid: 103,
              studentName: 'Gaddam Lakshmi Nagendra',
              admno: '251145',
            ),
            HostelStudentModel(
              sid: 104,
              studentName: 'Gaddam Lakshmi Nagendra',
              admno: '251145',
            ),
          ];

    for (final student in currentStudents) {
      sids.add(student.sid);
      statuses.add(_statuses[student.sid] ?? 'P');
    }

    final success = await hostelCtrl.submitAttendance(
      branchId: hostelCtrl.activeBranch.value,
      hostel: hostelCtrl.activeHostel.value,
      floor: hostelCtrl.getFloorIdFromName(args['floor_name'] ?? ''),
      room: hostelCtrl.getRoomIdFromName(args['room_id']?.toString() ?? ''),
      shift: '1',
      sidList: sids,
      statusList: statuses,
    );

    if (success) {
      Get.snackbar(
        'Success',
        'Attendance submitted successfully',
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(20),
        borderRadius: 12,
      );
      Get.back();
    }
  }
}
