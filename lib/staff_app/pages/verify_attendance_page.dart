import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:student_app/staff_app/api/api_service.dart';
import 'package:student_app/staff_app/controllers/shift_controller.dart';
import 'package:student_app/staff_app/model/attendance_record_model.dart';
import '../controllers/branch_controller.dart';
import '../widgets/staff_header.dart';

class VerifyAttendancePage extends StatefulWidget {
  const VerifyAttendancePage({super.key});

  @override
  State<VerifyAttendancePage> createState() => _VerifyAttendancePageState();
}

class _VerifyAttendancePageState extends State<VerifyAttendancePage>
    with SingleTickerProviderStateMixin {
  String? selectedBranch;
  String? selectedShift;

  bool isLoading = false;
  bool isSubmitting = false;
  List<AttendanceRecord> attendanceData = [];

  late AnimationController _animationController;

  // ================= CONTROLLERS =================
  final BranchController branchCtrl = Get.put(BranchController());
  final ShiftController shiftCtrl = Get.put(ShiftController());

  List<String> branches = [];

  // ================= DARK COLORS =================
  final Color darkBg1 = const Color(0xFF1a1a2e);
  final Color darkBg2 = const Color(0xFF16213e);
  final Color darkBg3 = const Color(0xFF0f3460);
  final Color darkBg4 = const Color(0xFF533483);

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    // Load branches
    branchCtrl.loadBranches();

    // Population logic
    void populateInitialData() {
      if (branchCtrl.branches.isNotEmpty) {
        setState(() {
          branches = branchCtrl.branches.map((b) => b.branchName).toList();

          if (selectedBranch == null) {
            selectedBranch = branches.first;
            final branch = branchCtrl.branches.first;
            shiftCtrl.loadShifts(branch.id);
          }
        });
      }
    }

    // Auto-load if already present
    populateInitialData();

    // Auto-load when data arrives
    ever(branchCtrl.branches, (_) => populateInitialData());

    // Auto-select shift
    ever(shiftCtrl.shifts, (List sList) {
      if (sList.isNotEmpty && selectedShift == null) {
        setState(() {
          selectedShift = sList.first.shiftName;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ================= FETCH =================
  Future<void> _fetchAttendanceData() async {
    if (selectedBranch == null || selectedShift == null) {
      _showSnackBar('Please select Branch & Shift', Colors.orange);
      return;
    }

    try {
      setState(() {
        isLoading = true;
        attendanceData.clear();
      });

      // get selected branch id
      final branch = branchCtrl.branches.firstWhere(
        (b) => b.branchName == selectedBranch,
      );

      // get selected shift id
      final shift = shiftCtrl.shifts.firstWhere(
        (s) => s.shiftName == selectedShift,
      );

      // 🔥 API CALL (Detailed endpoint to get all totals)
      final result = await ApiService.getVerifyAttendanceDetailed(
        branchId: branch.id,
        shiftId: shift.id,
      );

      setState(() {
        attendanceData = result
            .map((e) => AttendanceRecord.fromJson(e))
            .toList();
        isLoading = false;
      });

      _animationController.forward(from: 0);

      if (attendanceData.isEmpty) {
        _showSnackBar('No attendance found', Colors.orange);
      } else {
        _showSnackBar('Attendance Loaded', Colors.green);
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showSnackBar(e.toString(), Colors.red);
    }
  }

  void _showSnackBar(String msg, Color color) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ================= UI Constants =================
  static const Color primaryPurple = Color(0xFF7E49FF);
  static const Color lavenderBg = Color(0xFFEAE6F9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const StaffHeader(title: "Verify Attendance"),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (attendanceData.isEmpty) ...[
                    const Text(
                      "Select filters to verify attendance",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // ================= FILTER CARD =================
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: lavenderBg,
                        borderRadius: BorderRadius.circular(25),
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
                          _buildDropdownField(
                            label: "Branch",
                            hint: "Select Branch",
                            value: selectedBranch,
                            items: branches,
                            onChanged: (v) {
                              setState(() {
                                selectedBranch = v;
                                selectedShift = null;
                              });
                              final branchObj = branchCtrl.branches.firstWhere(
                                (b) => b.branchName == v,
                              );
                              shiftCtrl.loadShifts(branchObj.id);
                            },
                          ),
                          const SizedBox(height: 15),
                          Obx(
                            () => _buildDropdownField(
                              label: "Shift",
                              hint: "Select Shift",
                              value: selectedShift,
                              items: shiftCtrl.shifts
                                  .map((e) => e.shiftName)
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => selectedShift = v),
                            ),
                          ),
                          const SizedBox(height: 25),

                          // VERIFY BUTTON
                          _buildGradientButton(),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],

                  // ================= CONTENT =================
                  if (isLoading)
                    const Center(
                      child: CircularProgressIndicator(color: primaryPurple),
                    )
                  else if (attendanceData.isEmpty)
                    _buildEmptyState()
                  else
                    _buildAttendanceList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String hint,
    required List<String> items,
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
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200, width: 1),
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
                style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
              ),
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.black87,
                size: 20,
              ),
              dropdownColor: Colors.white,
              items: items.map((String text) {
                return DropdownMenuItem<String>(
                  value: text,
                  child: Text(
                    text,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGradientButton() {
    return GestureDetector(
      onTap: isLoading ? null : _fetchAttendanceData,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7D74FC), Color(0xFFD08EF7)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isLoading ? "Loading..." : "Verify Attendance",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            if (!isLoading)
              const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          Image.network(
            "https://cdni.iconscout.com/illustration/premium/thumb/no-data-found-8867280-7223912.png",
            height: 180,
            errorBuilder: (c, e, s) => const Icon(
              Icons.folder_open_rounded,
              size: 100,
              color: lavenderBg,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "No Attendance Data",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceList() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: lavenderBg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: attendanceData
            .map((record) => _buildRecordCard(record))
            .toList(),
      ),
    );
  }

  Widget _buildRecordCard(AttendanceRecord record) {
    int totalMarked =
        record.present +
        record.absent +
        record.totalOuting +
        record.totalHomePass +
        record.totalSelfOuting +
        record.totalSelfHome +
        record.totalMissing;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 1),
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
                record.batch,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: primaryPurple,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  "Shift Wise",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: Color(0xFFEEEEEE)),
          ),
          Row(
            children: [
              Expanded(
                child: _statMiniItem(
                  "Total",
                  record.total,
                  const Color(0xFF3B82F6),
                ),
              ), // Blue
              const SizedBox(width: 8),
              Expanded(
                child: _statMiniItem(
                  "Present",
                  record.present,
                  const Color(0xFF22C55E),
                ),
              ), // Green
              const SizedBox(width: 8),
              Expanded(
                child: _statMiniItem(
                  "Absent",
                  record.absent,
                  const Color(0xFFEF4444),
                ),
              ), // Red
              const SizedBox(width: 8),
              Expanded(
                child: _statMiniItem(
                  "Outing",
                  record.totalOuting,
                  const Color(0xFFF59E0B),
                ),
              ), // Orange
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _statMiniItem(
                  "Home Pass",
                  record.totalHomePass,
                  const Color(0xFF8B5CF6),
                ),
              ), // Purple
              const SizedBox(width: 8),
              Expanded(
                child: _statMiniItem(
                  "Self Outing",
                  record.totalSelfOuting,
                  const Color(0xFF06B6D4),
                ),
              ), // Cyan
              const SizedBox(width: 8),
              Expanded(
                child: _statMiniItem(
                  "Self Home",
                  record.totalSelfHome,
                  const Color(0xFF0EA5E9),
                ),
              ), // Light Blue
              const SizedBox(width: 8),
              Expanded(
                child: _statMiniItem(
                  "Missing",
                  record.totalMissing,
                  const Color(0xFFEAB308),
                ),
              ), // Yellow
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: Color(0xFFEEEEEE)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total Marked",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              Text(
                totalMarked.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statMiniItem(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.6), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
