import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/staff_header.dart';

class AddFloorPage extends StatefulWidget {
  const AddFloorPage({super.key});

  @override
  State<AddFloorPage> createState() => _AddFloorPageState();
}

class _AddFloorPageState extends State<AddFloorPage> {
  final _formKey = GlobalKey<FormState>();

  // Dropdown values/Controllers
  final TextEditingController floorNameCtrl = TextEditingController();
  String? selectedBranch;
  String? selectedBuilding;
  final TextEditingController inchargeCtrl = TextEditingController();
  String selectedStatus = "Active";

  // Constants
  static const Color lavenderBg = Color(0xFFF1F4FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const StaffHeader(title: "Add New Floor"),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // ================= FORM CONTAINER =================
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: lavenderBg.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Floor Name"),
                          _buildTextField(
                            hint: "Floor Name/Number",
                            controller: floorNameCtrl,
                          ),

                          _buildLabel("Branch"),
                          _buildDropdown(
                            hint: "Select Branch",
                            value: selectedBranch,
                            items: ["Branch 1", "Branch 2"],
                            onChanged: (v) =>
                                setState(() => selectedBranch = v),
                          ),

                          _buildLabel("Building"),
                          _buildDropdown(
                            hint: "Select",
                            value: selectedBuilding,
                            items: ["Building A", "Building B"],
                            onChanged: (v) =>
                                setState(() => selectedBuilding = v),
                          ),

                          _buildLabel("Incharge"),
                          _buildTextField(
                            hint: "Enter Incharge Name",
                            controller: inchargeCtrl,
                          ),

                          _buildLabel("Status"),
                          _buildDropdown(
                            hint: "Select",
                            value: selectedStatus,
                            items: ["Active", "Inactive"],
                            onChanged: (v) =>
                                setState(() => selectedStatus = v!),
                          ),

                          const SizedBox(height: 25),

                          // ================= ADD FLOOR BUTTON =================
                          Container(
                            width: double.infinity,
                            height: 55,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF7D74FC), Color(0xFFD08EF7)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  Get.snackbar(
                                    "Success",
                                    "Floor Added",
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.green.withOpacity(
                                      0.8,
                                    ),
                                    colorText: Colors.white,
                                    margin: const EdgeInsets.all(15),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: const Text(
                                "Add Floor",
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

  Widget _buildTextField({
    required String hint,
    required TextEditingController controller,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
