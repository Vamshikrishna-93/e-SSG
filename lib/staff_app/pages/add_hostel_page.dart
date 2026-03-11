import 'package:flutter/material.dart';
import '../widgets/staff_header.dart';

class AddHostelPage extends StatefulWidget {
  const AddHostelPage({super.key});

  @override
  State<AddHostelPage> createState() => _AddHostelPageState();
}

class _AddHostelPageState extends State<AddHostelPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _buildingCtrl = TextEditingController();
  final TextEditingController _addressCtrl = TextEditingController();

  String? _category;
  String? _incharge;
  String? _branch;
  String? _status;

  // ================= UI Constants =================
  static const Color lavenderBg = Color(0xFFF1F4FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const StaffHeader(title: "Add Hostel"),

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
                          _buildLabel("Building Name *"),
                          _buildTextField(
                            hint: "Enter Building Name",
                            controller: _buildingCtrl,
                          ),

                          _buildLabel("Category"),
                          _buildDropdown(
                            hint: "Select Category",
                            value: _category,
                            items: const ["BOYS HOSTEL", "GIRLS HOSTEL"],
                            onChanged: (v) => setState(() => _category = v),
                          ),

                          _buildLabel("Address *"),
                          _buildTextField(
                            hint: "Enter Address",
                            controller: _addressCtrl,
                          ),

                          _buildLabel("Incharge *"),
                          _buildDropdown(
                            hint: "Select Incharge",
                            value: _incharge,
                            items: const ["Staff1", "Staff2"],
                            onChanged: (v) => setState(() => _incharge = v),
                          ),

                          _buildLabel("Branch *"),
                          _buildDropdown(
                            hint: "Select Branch",
                            value: _branch,
                            items: const ["EAMCET", "NEET"],
                            onChanged: (v) => setState(() => _branch = v),
                          ),

                          _buildLabel("Status"),
                          _buildDropdown(
                            hint: "Select Status",
                            value: _status,
                            items: const ["Active", "Inactive"],
                            onChanged: (v) => setState(() => _status = v),
                          ),

                          const SizedBox(height: 25),

                          // ================= ADD HOSTEL BUTTON =================
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
                                if (_formKey.currentState!.validate()) {
                                  // Implementation for adding hostel
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Add Hostel",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ],
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

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
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
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 4,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          border: InputBorder.none,
        ),
        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
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
        border: Border.all(color: Colors.grey.shade200),
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
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
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
