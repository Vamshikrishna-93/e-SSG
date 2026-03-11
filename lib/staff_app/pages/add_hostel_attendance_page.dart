import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/skeleton.dart';
import '../controllers/hostel_controller.dart';
import '../controllers/branch_controller.dart';
import '../widgets/staff_header.dart';

class AddHostelAttendancePage extends StatefulWidget {
  final String? branch;
  final String? hostel;
  final String? floor;
  final String? room;
  final String? month;
  final String? date;

  const AddHostelAttendancePage({
    super.key,
    this.branch,
    this.hostel,
    this.floor,
    this.room,
    this.month,
    this.date,
  });

  @override
  State<AddHostelAttendancePage> createState() =>
      _AddHostelAttendancePageState();
}

class _AddHostelAttendancePageState extends State<AddHostelAttendancePage> {
  final HostelController hostelCtrl = Get.find<HostelController>();
  final BranchController branchCtrl = Get.put(BranchController());
  final Map<int, String> attendanceStatus = {};
  String selectedDate = DateTime.now().toIso8601String().split('T')[0];

  final List<String> statusOptions = [
    'Present',
    'Missing',
    'Outing',
    'Home Pass',
    'Self Outing',
    'Self Home',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.date != null) {
      selectedDate = widget.date!;
    }
  }

  Future<void> _getStudents() async {
    final roomId = hostelCtrl.getRoomIdFromName(widget.room ?? '101');
    await hostelCtrl.loadRoomStudents(
      shift: '1',
      date: selectedDate,
      roomId: roomId,
    );

    for (final student in hostelCtrl.roomStudents) {
      attendanceStatus[student.sid] = 'Present';
    }
    setState(() {});
  }

  Future<void> _submitAttendance() async {
    final List<int> sids = [];
    final List<String> statuses = [];

    if (hostelCtrl.roomStudents.isEmpty) {
      Get.snackbar('Info', 'No students to submit attendance for');
      return;
    }

    for (final student in hostelCtrl.roomStudents) {
      sids.add(student.sid);
      String status = attendanceStatus[student.sid] ?? 'Present';
      String statusCode = 'P';
      switch (status) {
        case 'Present':
          statusCode = 'P';
          break;
        case 'Missing':
          statusCode = 'A';
          break;
        case 'Outing':
          statusCode = 'O';
          break;
        case 'Home Pass':
          statusCode = 'H';
          break;
        case 'Self Outing':
          statusCode = 'SO';
          break;
        case 'Self Home':
          statusCode = 'SH';
          break;
        default:
          statusCode = 'P';
      }
      statuses.add(statusCode);
    }

    if (branchCtrl.branches.isEmpty) await branchCtrl.loadBranches();

    final branchName = widget.branch ?? hostelCtrl.activeBranch.value;
    final branchObj = branchCtrl.branches.firstWhereOrNull(
      (b) => b.branchName == branchName || b.id.toString() == branchName,
    );
    final String branchId = branchObj?.id.toString() ?? branchName;

    if (hostelCtrl.hostels.isEmpty && branchObj != null) {
      await hostelCtrl.loadHostelsByBranch(branchObj.id);
    }

    final hostelName = widget.hostel ?? hostelCtrl.activeHostel.value;
    final hostelObj = hostelCtrl.hostels.firstWhereOrNull(
      (h) => h.buildingName == hostelName || h.id.toString() == hostelName,
    );
    final String hostelId = hostelObj?.id.toString() ?? hostelName;

    final floorId = hostelCtrl.getFloorIdFromName(
      widget.floor ?? hostelCtrl.activeFloor.value,
    );
    final roomId = hostelCtrl.getRoomIdFromName(widget.room ?? '101');

    final success = await hostelCtrl.submitAttendance(
      branchId: branchId,
      hostel: hostelId,
      floor: floorId,
      room: roomId,
      shift: '1',
      sidList: sids,
      statusList: statuses,
    );

    if (success) {
      Get.snackbar(
        'Success',
        'Attendance submitted successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      await hostelCtrl.loadRoomAttendanceSummary(
        branch: branchId,
        date: selectedDate,
        hostel: hostelId,
        floor: floorId,
        room: roomId,
      );
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const StaffHeader(title: "Add Hostel Attendance"),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      "Filter Summary",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildFilterSummary(),
                  const SizedBox(height: 16),
                  _buildGetStudentsButton(),
                  const SizedBox(height: 20),
                  Obx(() {
                    if (!hostelCtrl.isLoading.value &&
                        hostelCtrl.roomStudents.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF3F0FF),
                        borderRadius: BorderRadius.all(Radius.circular(28)),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Column(
                        children: [
                          if (hostelCtrl.isLoading.value)
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: SkeletonList(itemCount: 3),
                            )
                          else
                            _buildStudentList(),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          _buildBottomSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildFilterSummary() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withOpacity(0.12)),
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
          _summaryRow(
            "Branch",
            widget.branch ??
                (hostelCtrl.activeBranch.value.isEmpty
                    ? 'SSJC-VIDHYA BHAVAN'
                    : hostelCtrl.activeBranch.value),
          ),
          const SizedBox(height: 8),
          _summaryRow(
            "Hostel",
            widget.hostel ??
                (hostelCtrl.activeHostel.value.isEmpty
                    ? 'VIDHYA BHAVAN'
                    : hostelCtrl.activeHostel.value),
          ),
          const SizedBox(height: 8),
          _summaryRow(
            "Floor",
            widget.floor ??
                (hostelCtrl.activeFloor.value.isEmpty
                    ? '1-FLOOR'
                    : hostelCtrl.activeFloor.value),
          ),
          const SizedBox(height: 8),
          _summaryRow("Room", widget.room ?? '101'),
          const SizedBox(height: 8),
          _summaryRow(
            "Date",
            selectedDate.isEmpty
                ? (hostelCtrl.activeDate.value.isEmpty
                      ? '2026-02-28'
                      : hostelCtrl.activeDate.value)
                : selectedDate,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      children: [
        Text(
          "$label : ",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black,
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildGetStudentsButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF7D74FC),
              Color(0xFFD08EF7),
            ], // Refined Purple Gradient
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 4,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _getStudents,
            borderRadius: BorderRadius.circular(12),
            child: const Center(
              child: Text(
                "Get Students",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStudentList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: hostelCtrl.roomStudents.length,
      itemBuilder: (context, index) {
        final student = hostelCtrl.roomStudents[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 4,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "S.NO: ${index + 1}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    "Adm No : ${student.admno}",
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(
                height: 1,
                thickness: 1,
                color: Colors.grey.withOpacity(0.12),
              ),
              const SizedBox(height: 16),
              _studentInfoRow("Student Name", student.studentName),
              const SizedBox(height: 10),
              _studentInfoRow("Phone Number", student.phone ?? '8923454677'),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Text(
                    "Attendance Status : ",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),
                  _buildStatusDropdown(student.sid),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _studentInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label : ",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusDropdown(int sid) {
    final currentStatus = attendanceStatus[sid] ?? 'Present';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      height: 34,
      decoration: BoxDecoration(
        color: const Color(0xFFDCFCE7), // Light green badge
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentStatus,
          icon: const Padding(
            padding: EdgeInsets.only(left: 4),
            child: Icon(
              Icons.keyboard_arrow_down,
              color: Color(0xFF166534),
              size: 20,
            ),
          ),
          style: const TextStyle(
            color: Color(0xFF166534),
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
          onChanged: (String? newValue) {
            setState(() {
              attendanceStatus[sid] = newValue!;
            });
          },
          items: statusOptions.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBottomSubmitButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 4,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF3FAFB9), Color(0xFFAED581)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 4,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _submitAttendance,
            borderRadius: BorderRadius.circular(12),
            child: const Center(
              child: Text(
                "Submit Attendance",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
