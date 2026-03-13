import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/skeleton.dart';
import '../controllers/hostel_controller.dart';
import '../widgets/staff_header.dart';

class AddHostelAttendancePage extends StatefulWidget {
  const AddHostelAttendancePage({super.key});

  @override
  State<AddHostelAttendancePage> createState() =>
      _AddHostelAttendancePageState();
}

class _AddHostelAttendancePageState extends State<AddHostelAttendancePage> {
  final HostelController hostelCtrl = Get.find<HostelController>();
  final Map<int, String> attendanceStatus = {};
  String selectedDate = DateTime.now().toIso8601String().split('T')[0];

  // Route arguments
  String? _branchId;
  String? _branchName;
  String? _hostelId;
  String? _hostelName;
  String? _floorId;
  String? _floorName;
  String? _roomId;
  String? _roomName;
  String? _month;

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
    // Read arguments passed from HostelAttendanceFilterPage
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      _branchId   = args['branchId']   as String?;
      _branchName = args['branchName'] as String?;
      _hostelId   = args['hostelId']   as String?;
      _hostelName = args['hostelName'] as String?;
      _floorId    = args['floorId']    as String?;
      _floorName  = args['floorName']  as String?;
      _roomId     = args['roomId']     as String?;
      _roomName   = args['roomName']   as String?;
      _month      = args['month']      as String?;
      selectedDate = args['date'] as String? ?? selectedDate;
    }
    // Auto-load students if we have a room ID
    if (_roomId != null && _roomId!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _getStudents());
    }
  }

  Future<void> _getStudents() async {
    // Use the roomId from route arguments directly (already the numeric ID)
    final roomId = _roomId ?? '';
    if (roomId.isEmpty) {
      Get.snackbar('Info', 'Room not selected');
      return;
    }
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

    // Use IDs from route arguments directly
    final String branchId = _branchId ?? hostelCtrl.activeBranch.value;
    final String hostelId = _hostelId ?? hostelCtrl.activeHostel.value;
    final String floorId  = _floorId  ?? hostelCtrl.activeFloor.value;
    final String roomId   = _roomId   ?? '';

    if (roomId.isEmpty) {
      Get.snackbar('Info', 'Room not available');
      return;
    }

    // Calculate stats before submission
    final int total   = sids.length;
    final int present = statuses.where((s) => s == 'P').length;
    final int absent  = statuses.where((s) => s == 'A').length;

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
      _showSuccessDialog(total: total, present: present, absent: absent);
    }
  }

  void _showSuccessDialog({
    required int total,
    required int present,
    required int absent,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Close button ──
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(ctx).pop();
                    Get.back();
                  },
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 16, color: Colors.black54),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // ── Green check icon ──
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Color(0xFF1B8C3A),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 16),
              const Text(
                'Success',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Attendance has been submitted\nsuccessfully!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 20),
              // ── Stats row ──
              Row(
                children: [
                  _statBox(label: 'Total',   value: total,   bgColor: const Color(0xFFF3EFFF), textColor: const Color(0xFF7D74FC)),
                  const SizedBox(width: 8),
                  _statBox(label: 'Present', value: present, bgColor: const Color(0xFFE8F5E9), textColor: const Color(0xFF1B8C3A)),
                  const SizedBox(width: 8),
                  _statBox(label: 'Absent',  value: absent,  bgColor: const Color(0xFFFFF0F0), textColor: const Color(0xFFE53935)),
                ],
              ),
              const SizedBox(height: 20),
              // ── OK button ──
              SizedBox(
                width: double.infinity,
                height: 48,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7D74FC), Color(0xFFD08EF7)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      Get.back();
                    },
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statBox({
    required String label,
    required int value,
    required Color bgColor,
    required Color textColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              '$value',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
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
          _summaryRow("Branch", _branchName ?? hostelCtrl.activeBranch.value),
          const SizedBox(height: 8),
          _summaryRow("Hostel", _hostelName ?? hostelCtrl.activeHostel.value),
          const SizedBox(height: 8),
          _summaryRow("Floor",  _floorName  ?? hostelCtrl.activeFloor.value),
          const SizedBox(height: 8),
          _summaryRow("Room",   _roomName   ?? ''),
          const SizedBox(height: 8),
          _summaryRow("Month",  _month      ?? ''),
          const SizedBox(height: 8),
          _summaryRow("Date",   selectedDate),
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
