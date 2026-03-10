import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/branch_controller.dart';
import '../widgets/staff_header.dart';

class HostelAttendanceFilterPage extends StatefulWidget {
  const HostelAttendanceFilterPage({super.key});

  @override
  State<HostelAttendanceFilterPage> createState() =>
      _HostelAttendanceFilterPageState();
}

class _HostelAttendanceFilterPageState
    extends State<HostelAttendanceFilterPage> {
  String? _branch;
  String? _hostel;
  String? _floor;
  String? _room;
  String? _month;

  final BranchController branchCtrl = Get.put(BranchController());

  final List<String> hostels = ['ADARSA', 'VIDHYA'];
  final List<String> floors = ['First Floor', 'Second Floor', 'Third Floor'];
  final List<String> rooms = ['C-201', 'C-202', 'C-203', 'C-204'];
  final List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  void initState() {
    super.initState();
    branchCtrl.loadBranches();

    // Population logic
    void populateInitialBranch() {
      if (branchCtrl.branches.isNotEmpty && _branch == null) {
        setState(() {
          _branch = branchCtrl.branches.first.branchName;
        });
      }
    }

    // Auto-load if already present
    populateInitialBranch();

    // Auto-load when data arrives
    ever(branchCtrl.branches, (_) => populateInitialBranch());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const StaffHeader(title: "Hostel Attendance"),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: _buildFilterContainer(context),
            ),
          ),
          _buildBottomButtons(context),
        ],
      ),
    );
  }

  // Standard header widget used instead of local _buildHeader

  // ================= FILTER CONTAINER =================
  Widget _buildFilterContainer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EFFF), // Very Light Lavender
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(
            () => _buildInputField(
              label: "Branch",
              hint: "Select Branch",
              value: _branch,
              items: branchCtrl.branches.map((b) => b.branchName).toList(),
              onChanged: (v) => setState(() => _branch = v),
            ),
          ),
          const SizedBox(height: 15),
          _buildInputField(
            label: "Hostel",
            hint: "Select Hostel",
            value: _hostel,
            items: hostels,
            onChanged: (v) => setState(() => _hostel = v),
          ),
          const SizedBox(height: 15),
          _buildInputField(
            label: "Floor",
            hint: "Select Floor",
            value: _floor,
            items: floors,
            onChanged: (v) => setState(() => _floor = v),
          ),
          const SizedBox(height: 15),
          _buildInputField(
            label: "Room",
            hint: "Select Room",
            value: _room,
            items: rooms,
            onChanged: (v) => setState(() => _room = v),
          ),
          const SizedBox(height: 15),
          _buildInputField(
            label: "Month",
            hint: "Select Month",
            value: _month,
            items: months,
            onChanged: (v) => setState(() => _month = v),
          ),
          const SizedBox(height: 25),
          _buildGetStudentsButton(),
        ],
      ),
    );
  }

  Widget _buildInputField({
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
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF374151), // Dark Grey
            ),
          ),
        ),
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Colors.grey.withOpacity(0.15),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Text(
                hint,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.black,
                size: 28,
              ),
              items: items.map((String text) {
                return DropdownMenuItem<String>(
                  value: text,
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF1F2937),
                    ),
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

  Widget _buildGetStudentsButton() {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF7D74FC), Color(0xFFD08EF7)],

          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            if (_branch != null &&
                _hostel != null &&
                _floor != null &&
                _room != null &&
                _month != null) {
              Get.toNamed('/hostelAttendanceResult');
            } else {
              Get.snackbar(
                "Info",
                "Please select all fields",
                backgroundColor: Colors.white,
              );
            }
          },
          child: const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Get Students",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, color: Colors.white, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= BOTTOM BUTTONS =================

  Widget _buildBottomButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          // Add Attendance
          Expanded(
            child: Container(
              height: 55,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7D74FC), Color(0xFFD08EF7)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Get.toNamed('/addHostelAttendance'),
                  borderRadius: BorderRadius.circular(12),
                  child: const Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, color: Colors.white, size: 22),
                        SizedBox(width: 4),
                        Text(
                          "Add Attendance",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Check Status
          Expanded(
            child: Container(
              height: 55,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3FAFB9), Color(0xFFAED160)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Get.toNamed('/hostelAttendanceStatus'),
                  borderRadius: BorderRadius.circular(12),
                  child: const Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Colors.white, size: 22),
                        SizedBox(width: 4),
                        Text(
                          "Check Status",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
