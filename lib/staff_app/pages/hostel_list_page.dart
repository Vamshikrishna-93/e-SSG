import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/hostel_controller.dart';
import '../controllers/branch_controller.dart';
import '../controllers/staff_controller.dart';
import '../model/hostel_model.dart';
import 'add_hostel_page.dart';
import '../widgets/skeleton.dart';
import '../widgets/staff_header.dart';

/// ================= HOSTEL LIST PAGE =================
class HostelListPage extends StatefulWidget {
  const HostelListPage({super.key});

  @override
  State<HostelListPage> createState() => _HostelListPageState();
}

class _HostelListPageState extends State<HostelListPage> {
  late final HostelController hostelCtrl;
  final BranchController branchCtrl = Get.put(BranchController());
  final StaffController staffCtrl = Get.put(StaffController());

  // ================= UI Constants =================
  static const Color primaryPurple = Color(0xFF7E49FF);
  static const Color lavenderBg = Color(0xFFF1F4FF);
  static const Color activeGreen = Color(0xFF78C991);

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<HostelController>()) {
      Get.put(HostelController(), permanent: true);
    }
    hostelCtrl = Get.find<HostelController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      staffCtrl.fetchStaff();
      if (branchCtrl.branches.isEmpty) {
        branchCtrl.loadBranches().then((_) {
          _loadHostelsForFirstBranch();
        });
      } else {
        _loadHostelsForFirstBranch();
      }
    });
  }

  void _loadHostelsForFirstBranch() {
    if (branchCtrl.branches.isNotEmpty) {
      branchCtrl.selectedBranch.value ??= branchCtrl.branches.first;
      final selected = branchCtrl.selectedBranch.value;
      if (selected != null) {
        hostelCtrl.loadHostelsByBranch(selected.id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const StaffHeader(title: "Hostel List"),

          Expanded(
            child: Obx(() {
              if (hostelCtrl.isLoading.isTrue || branchCtrl.isLoading.isTrue) {
                return const Center(child: StaffLoadingAnimation());
              }

              if (hostelCtrl.hostels.isEmpty) {
                return const Center(child: Text("No hostels found"));
              }

              return Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: lavenderBg.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: hostelCtrl.hostels.length,
                  itemBuilder: (context, i) =>
                      _hostelCard(context, hostelCtrl.hostels[i]),
                ),
              );
            }),
          ),

          // ================= BOTTOM BUTTON =================
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Container(
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
              child: ElevatedButton.icon(
                onPressed: () => Get.to(() => const AddHostelPage()),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  "Add Building",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _hostelCard(BuildContext context, HostelModel hostel) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
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
                child: Text(
                  hostel.buildingName.toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: activeGreen,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Active",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Incharge ID : ${hostel.incharge}",
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, thickness: 0.5),
          ),
          _infoRow("Category", hostel.category),
          const SizedBox(height: 8),
          _infoRow("Address", hostel.address),
          const SizedBox(height: 15),
          Row(
            children: [
              _actionIcon(Icons.edit, () => _showEditDialog(context, hostel)),
              const SizedBox(width: 12),
              _actionIcon(Icons.delete, () => _showDeleteDialog(context)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      children: [
        Text(
          "$label : ",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _actionIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: primaryPurple, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  // ================= DIALOGS & HELPERS =================

  void _showEditDialog(BuildContext context, HostelModel hostel) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nameCtrl = TextEditingController(text: hostel.buildingName);
    final addrCtrl = TextEditingController(text: hostel.address);

    final RxnInt selectedIncharge = RxnInt(hostel.incharge);
    final RxnInt selectedBranch = RxnInt(hostel.branchId);
    final RxString selectedStatus = RxString(
      hostel.status == 1 ? "Active" : "Inactive",
    );
    final RxString selectedCategory = RxString(hostel.category);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: isDark ? const Color(0xFF2D2D3A) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel("Building Name *", isDark),
              _buildTextField("Building Name", isDark, controller: nameCtrl),
              const SizedBox(height: 16),
              _buildLabel("Category", isDark),
              Obx(
                () => _buildDropdown(
                  ["BOYS HOSTEL", "GIRLS HOSTEL"],
                  isDark,
                  value: selectedCategory.value,
                  onChanged: (val) => selectedCategory.value = val!,
                ),
              ),
              const SizedBox(height: 16),
              _buildLabel("Address *", isDark),
              _buildTextField("Address", isDark, controller: addrCtrl),
              const SizedBox(height: 16),
              _buildLabel("Incharge *", isDark),
              Obx(() {
                final staffItems = [
                  "Select Staff",
                  ...staffCtrl.staffList.map(
                    (s) => "${s.designation} (${s.id})",
                  ),
                ];
                final currentStaff = staffCtrl.staffList.firstWhereOrNull(
                  (s) => s.id == selectedIncharge.value,
                );
                final dropdownValue = (currentStaff != null)
                    ? "${currentStaff.designation} (${currentStaff.id})"
                    : "Select Staff";
                return _buildDropdown(
                  staffItems,
                  isDark,
                  value: dropdownValue,
                  onChanged: (val) {
                    if (val == "Select Staff") {
                      selectedIncharge.value = null;
                    } else {
                      final idMatch = RegExp(r'\((\d+)\)$').firstMatch(val!);
                      if (idMatch != null) {
                        selectedIncharge.value = int.parse(idMatch.group(1)!);
                      }
                    }
                  },
                );
              }),
              const SizedBox(height: 16),
              _buildLabel("Branch *", isDark),
              Obx(
                () => _buildDropdown(
                  [
                    "Select Branch",
                    ...branchCtrl.branches.map((b) => b.branchName),
                  ],
                  isDark,
                  value:
                      branchCtrl.branches
                          .firstWhereOrNull((b) => b.id == selectedBranch.value)
                          ?.branchName ??
                      "Select Branch",
                  onChanged: (val) {
                    final b = branchCtrl.branches.firstWhereOrNull(
                      (b) => b.branchName == val,
                    );
                    selectedBranch.value = b?.id;
                  },
                ),
              ),
              const SizedBox(height: 16),
              _buildLabel("Status", isDark),
              Obx(
                () => _buildDropdown(
                  ["Select", "Active", "Inactive"],
                  isDark,
                  value: selectedStatus.value,
                  onChanged: (val) => selectedStatus.value = val!,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7D74FC), Color(0xFFD08EF7)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Update Hostel",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: Color(0xFFfcc4a6),
                size: 100,
              ),
              const SizedBox(height: 24),
              const Text(
                "Are you sure?",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A4A4A),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "You want to delete this hostel?",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF7D74FC), Color(0xFFD08EF7)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text("Yes"),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B6B),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text("Cancel"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: isDark ? Colors.white70 : const Color(0xFF374151),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String hint,
    bool isDark, {
    TextEditingController? controller,
  }) {
    return TextField(
      controller: controller,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: isDark ? Colors.white38 : const Color(0xFF9CA3AF),
          fontSize: 13,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDark ? Colors.white38 : const Color(0xFFD1D5DB),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryPurple),
        ),
      ),
    );
  }

  Widget _buildDropdown(
    List<String> items,
    bool isDark, {
    String? value,
    ValueChanged<String?>? onChanged,
  }) {
    final selectedValue = (value != null && items.contains(value))
        ? value
        : items.first;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: isDark ? Colors.white38 : const Color(0xFFD1D5DB),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: selectedValue,
          dropdownColor: isDark ? const Color(0xFF2D2D3A) : Colors.white,
          icon: Icon(
            Icons.arrow_drop_down,
            color: isDark ? Colors.white70 : const Color(0xFF6B7280),
          ),
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(
                    e,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
