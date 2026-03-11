import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/staff_header.dart';

class AssignStudentsPage extends StatefulWidget {
  final List<Map<String, dynamic>> students;
  final bool isEdit;

  const AssignStudentsPage({
    super.key,
    required this.students,
    this.isEdit = false,
  });

  @override
  State<AssignStudentsPage> createState() => _AssignStudentsPageState();
}

class _AssignStudentsPageState extends State<AssignStudentsPage> {
  // Dropdown values/Controllers
  String? selectedBranch;
  String? selectedGroup;
  String? selectedCourse;
  String? selectedBatch;

  // Constants
  static const Color lavenderBg = Color(0xFFF1F4FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const StaffHeader(title: "Assign Students"),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // ================= FORM CONTAINER =================
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: lavenderBg.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(30),
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
                        _buildLabel("Branch"),
                        _buildDropdown(
                          hint: "Select Branch",
                          value: selectedBranch,
                          items: ["Branch 1", "Branch 2"],
                          onChanged: (v) => setState(() => selectedBranch = v),
                        ),

                        _buildLabel("Group"),
                        _buildDropdown(
                          hint: "Select Group",
                          value: selectedGroup,
                          items: ["Group A", "Group B"],
                          onChanged: (v) => setState(() => selectedGroup = v),
                        ),

                        _buildLabel("Course"),
                        _buildDropdown(
                          hint:
                              "Select Couse", // Correcting to match image typo "Select Couse"
                          value: selectedCourse,
                          items: ["Course 1", "Course 2"],
                          onChanged: (v) => setState(() => selectedCourse = v),
                        ),

                        _buildLabel("Batch"),
                        _buildDropdown(
                          hint: "Select Batch",
                          value: selectedBatch,
                          items: ["Batch 1", "Batch 2"],
                          onChanged: (v) => setState(() => selectedBatch = v),
                        ),

                        const SizedBox(height: 15),

                        // ================= GET STUDENT BUTTON =================
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
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 4,
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              Get.snackbar(
                                "Info",
                                "Fetching students...",
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: const Color(0xFF7E49FF).withOpacity(0.8),
                                colorText: Colors.white,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: const Text(
                              "Get Student",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
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
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: RichText(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
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
          isExpanded: true,
          value: value,
          hint: Text(
            hint,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
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
