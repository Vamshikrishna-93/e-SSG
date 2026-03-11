import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/branch_controller.dart';
import '../widgets/staff_header.dart';

class TakeStaffAttendancePage extends StatefulWidget {
  const TakeStaffAttendancePage({super.key});

  @override
  State<TakeStaffAttendancePage> createState() =>
      _TakeStaffAttendancePageState();
}

class _TakeStaffAttendancePageState extends State<TakeStaffAttendancePage> {
  // ================= UI Constants =================
  static const Color primaryPurple = Color(0xFF7E49FF);
  static const Color lavenderBg = Color(0xFFF1F4FF);

  final BranchController branchCtrl = Get.put(BranchController());

  String query = "";
  int? selectedBranchId;
  String selectedDepartment = "All Departments";
  String selectedDateRange = "Nov 02 - 25";
  String activeFilter = "All";

  final List<String> departments = [
    "All Departments",
    "Accountant",
    "Teacher",
    "Admin",
  ];

  @override
  void initState() {
    super.initState();
    branchCtrl.loadBranches();
  }

  // SAMPLE DATA
  final List<Map<String, dynamic>> staffList = [
    {
      "id": "666980",
      "name": "A.ANJANNEYULU",
      "initial": "B",
      "department": "Accountant",
      "status": "Present",
    },
    {
      "id": "666980",
      "name": "A.ANJANNEYULU",
      "initial": "B",
      "department": "Accountant",
      "status": "Present",
    },
    {
      "id": "666980",
      "name": "A.ANJANNEYULU",
      "initial": "B",
      "department": "Accountant",
      "status": "Present",
    },
    {
      "id": "666980",
      "name": "A.ANJANNEYULU",
      "initial": "B",
      "department": "Accountant",
      "status": "Present",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const StaffHeader(title: "Take Staff Attendance"),

          // ================= STAFF ATTENDANCE & DATE =================
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Staff Attendance",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C69FF).withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        selectedDateRange,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ================= DROPDOWNS =================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel("Branch"),
                Obx(
                  () => _buildDropdown(
                    branchCtrl.branches
                            .firstWhereOrNull((b) => b.id == selectedBranchId)
                            ?.branchName ??
                        "Select Branch",
                    branchCtrl.branches.map((b) => b.branchName).toList(),
                    (v) {
                      final selected = branchCtrl.branches.firstWhere(
                        (b) => b.branchName == v,
                      );
                      setState(() => selectedBranchId = selected.id);
                    },
                  ),
                ),
                const SizedBox(height: 12),
                _buildLabel("Department"),
                _buildDropdown(
                  selectedDepartment,
                  departments,
                  (v) => setState(() => selectedDepartment = v!),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ================= FILTER TABS =================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _buildFilterTab("All"),
                const SizedBox(width: 10),
                _buildFilterTab("Present"),
                const SizedBox(width: 10),
                _buildFilterTab("Absent"),
              ],
            ),
          ),

          // ================= MAIN CONTENT =================
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 15, 16, 0),
              padding: const EdgeInsets.only(top: 15),
              decoration: BoxDecoration(
                color: lavenderBg.withOpacity(0.7),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: primaryPurple.withOpacity(0.4),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 4,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                      child: TextField(
                        onChanged: (v) => setState(() => query = v),
                        decoration: const InputDecoration(
                          icon: Icon(
                            Icons.search,
                            color: Colors.black54,
                            size: 20,
                          ),
                          hintText: "Search Staff name / ID",
                          hintStyle: TextStyle(
                            color: Colors.black38,
                            fontSize: 13,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),

                  // Staff List
                  Expanded(
                    child: ListView.builder(
                      itemCount: staffList.length,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      itemBuilder: (context, index) {
                        return _buildStaffAttendanceFormCard(staffList[index]);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
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
          isExpanded: true,
          items: items.map((String val) {
            return DropdownMenuItem<String>(
              value: val,
              child: Text(val, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildFilterTab(String label) {
    bool isActive = activeFilter == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => activeFilter = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF7E49FF) : const Color(0xFFF1F4FF),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 4,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStaffAttendanceFormCard(Map<String, dynamic> staff) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
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
          CircleAvatar(
            backgroundColor: const Color(0xFFB59CFF),
            radius: 25,
            child: Text(
              staff['initial'],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  staff['name'],
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "ID:${staff['id']}",
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 2),
                Text(
                  "Department:${staff['department']}",
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4DB6AC).withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    staff['status'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
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
}
