import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/staff_header.dart';

class AddHostelMembersPage extends StatefulWidget {
  const AddHostelMembersPage({super.key});

  @override
  State<AddHostelMembersPage> createState() => _AddHostelMembersPageState();
}

class _AddHostelMembersPageState extends State<AddHostelMembersPage> {
  // Dropdown values
  String? selectedBranch;
  String? selectedGroup;
  String? selectedCourse;
  String? selectedBatch;

  bool _showData = false;

  // Mock list for cards
  final List<Map<String, dynamic>> _studentsList = [
    {
      "admNo": "251288",
      "name": "Pulagara Veera Vasatha Rayudu",
      "phone": "8923454677",
      "address": "Vijayawada,",
      "hostel": null,
      "floor": null,
    },
    {
      "admNo": "251288",
      "name": "Pulagara Veera Vasatha Rayudu",
      "phone": "8923454677",
      "address": "Vijayawada,",
      "hostel": null,
      "floor": null,
    },
    {
      "admNo": "251288",
      "name": "Pulagara Veera Vasatha Rayudu",
      "phone": "8923454677",
      "address": "Vijayawada,",
      "hostel": null,
      "floor": null,
    },
  ];

  // Constants
  static const Color primaryPurple = Color(0xFF7E49FF);
  static const Color lavenderBg = Color(0xFFF1F4FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const StaffHeader(title: "Add Hostel Members"),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // ================= CONTENT CONTAINER =================
                  if (!_showData)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: lavenderBg.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Branch"),
                          _buildDropdown(
                            hint: "Select Branch",
                            value: selectedBranch,
                            items: const ["Branch 1", "Branch 2"],
                            onChanged: (v) =>
                                setState(() => selectedBranch = v),
                          ),

                          _buildLabel("Group"),
                          _buildDropdown(
                            hint: "Select Group",
                            value: selectedGroup,
                            items: const ["Group A", "Group B"],
                            onChanged: (v) => setState(() => selectedGroup = v),
                          ),

                          _buildLabel("Course"),
                          _buildDropdown(
                            hint:
                                "Select Couse", // Kept the typo matching the image
                            value: selectedCourse,
                            items: const ["Course 1", "Course 2"],
                            onChanged: (v) =>
                                setState(() => selectedCourse = v),
                          ),

                          _buildLabel("Batch"),
                          _buildDropdown(
                            hint: "Select Batch",
                            value: selectedBatch,
                            items: const ["Batch 1", "Batch 2"],
                            onChanged: (v) => setState(() => selectedBatch = v),
                          ),

                          const SizedBox(height: 15),

                          // ================= GET STUDENT BUTTON =================
                          Container(
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF7D74FC), Color(0xFFD08EF7)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _showData = true;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                "Get Student",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: lavenderBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: _studentsList.asMap().entries.map((entry) {
                          int i = entry.key;
                          Map<String, dynamic> data = entry.value;
                          return _buildStudentCard(i, data);
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ================= SAVE MEMBERS BUTTON =================
          if (_showData)
            Container(
              padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                border: Border.all(color: Colors.grey.shade200, width: 1.5),
              ),
              child: SafeArea(
                top: false,
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3FAFB9), Color(0xFFAED160)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Get.snackbar(
                        "Success",
                        "Members saved successfully",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: primaryPurple.withOpacity(0.8),
                        colorText: Colors.white,
                        margin: const EdgeInsets.all(16),
                      );
                      setState(() {
                        _showData = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Save Members",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
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

  Widget _buildStudentCard(int index, Map<String, dynamic> data) {
    return Container(
      margin: EdgeInsets.only(
        bottom: index == _studentsList.length - 1 ? 0 : 15,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                "Adm No : ${data['admNo']}",
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(color: Colors.grey.shade200, height: 1),
          const SizedBox(height: 12),
          _infoRow("Student Name", data['name']),
          const SizedBox(height: 8),
          _infoRow("Phone Number", data['phone']),
          const SizedBox(height: 8),
          _infoRow("Address", data['address']),
          const SizedBox(height: 12),
          _cardDropdownRow(
            "Hostel",
            data['hostel'],
            "Select Hostel",
            ["Hostel 1", "Hostel 2"],
            (v) => setState(() => data['hostel'] = v),
          ),
          _cardDropdownRow(
            "Floor",
            data['floor'],
            "Select Floor",
            ["Floor 1", "Floor 2"],
            (v) => setState(() => data['floor'] = v),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              "$label :",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardDropdownRow(
    String label,
    String? value,
    String hint,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          SizedBox(
            width: 105,
            child: Text(
              "$label :",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          ),
          Container(
            height: 28,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isDense: true,
                value: value,
                hint: Text(
                  hint,
                  style: const TextStyle(fontSize: 11, color: Colors.black87),
                ),
                icon: const Padding(
                  padding: EdgeInsets.only(left: 6.0),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 16,
                    color: Colors.black87,
                  ),
                ),
                items: items
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(e, style: const TextStyle(fontSize: 11)),
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: RichText(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          children: const [
            TextSpan(
              text: " *",
              style: TextStyle(color: Colors.red),
            ),
          ],
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
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          hint: Text(
            hint,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.black87,
            size: 20,
          ),
          items: items.map((e) {
            return DropdownMenuItem(
              value: e,
              child: Text(
                e,
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
