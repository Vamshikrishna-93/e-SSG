import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/branch_controller.dart';
import '../controllers/floor_controller.dart';
import '../controllers/hostel_controller.dart';
import '../model/floor_model.dart';
import 'add_floor_page.dart';
import 'floor_students_page.dart';

class FloorsPage extends StatefulWidget {
  const FloorsPage({super.key});

  @override
  State<FloorsPage> createState() => _FloorsPageState();
}

class _FloorsPageState extends State<FloorsPage> {
  // ================= CONTROLLERS =================
  final BranchController branchCtrl = Get.put(BranchController());
  final HostelController hostelCtrl = Get.find<HostelController>();
  final FloorController floorCtrl = Get.put(FloorController());

  int? selectedBranchId;
  int? selectedHostelId;
  bool _showResults = false;
  String _query = '';

  @override
  void initState() {
    super.initState();
    branchCtrl.loadBranches();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: _showResults ? _buildResultsView() : _buildFilterView(),
          ),
        ],
      ),
      bottomNavigationBar: _buildStickyFooter(),
    );
  }

  Widget _buildFilterView() {
    return SingleChildScrollView(
      child: Column(children: [_buildFilterSection(), _buildEmptyState()]),
    );
  }

  Widget _buildResultsView() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F5FF),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF7C3AED).withOpacity(0.5),
                ),
              ),
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                decoration: const InputDecoration(
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.black45,
                    size: 20,
                  ),
                  hintText: "Search Floor",
                  hintStyle: TextStyle(color: Colors.black38, fontSize: 13),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (floorCtrl.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF8147E7)),
                );
              }

              final filteredFloors = floorCtrl.floors.where((f) {
                return f.floorName.toLowerCase().contains(_query.toLowerCase());
              }).toList();

              if (filteredFloors.isEmpty) {
                return const Center(
                  child: Text(
                    "No floors found",
                    style: TextStyle(color: Colors.black54),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredFloors.length,
                itemBuilder: (context, i) => _floorCard(filteredFloors[i], i),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 25,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF8147E7),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 15),
          const Text(
            "Floor Management",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ================= FILTERS =================
  Widget _buildFilterSection() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          _buildLabel("Branch"),
          Obx(
            () => _buildDropdown(
              hint: "Select Branch",
              value: selectedBranchId,
              items: branchCtrl.branches
                  .map((b) => {"id": b.id, "name": b.branchName})
                  .toList(),
              onChanged: (val) {
                setState(() {
                  selectedBranchId = val;
                  selectedHostelId = null;
                });
                if (val != null) {
                  hostelCtrl.loadHostelsByBranch(val);
                }
              },
            ),
          ),
          const SizedBox(height: 15),
          _buildLabel("Hostel"),
          Obx(
            () => _buildDropdown(
              hint: "Select Hostel",
              value: selectedHostelId,
              items: hostelCtrl.hostels
                  .map((h) => {"id": h.id, "name": h.buildingName})
                  .toList(),
              onChanged: (val) => setState(() => selectedHostelId = val),
            ),
          ),
          const SizedBox(height: 25),
          _buildGradientButton(
            text: "Get Floors",
            icon: Icons.arrow_forward,
            onTap: () {
              if (selectedBranchId == null || selectedHostelId == null) {
                Get.snackbar(
                  "Required",
                  "Please select branch and hostel",
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.orange.shade100,
                );
              } else {
                setState(() => _showResults = true);
                floorCtrl.fetchFloorsByHostel(selectedHostelId!);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        children: [
          Image.network(
            "https://img.freepik.com/free-vector/interaction-design-concept-illustration_114360-3940.jpg",
            height: 220,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.list_alt, size: 100, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          const Text(
            "Please select a branch to view categories",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF4B5563),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyFooter() {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 15,
        bottom: MediaQuery.of(Get.context!).padding.bottom + 15,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: _buildGradientButton(
        text: "Add New Floor",
        icon: Icons.add,
        onTap: () => Get.to(() => const AddFloorPage()),
      ),
    );
  }

  Widget _buildGradientButton({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8B5CF6), Color(0xFFC084FC)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _floorCard(FloorModel floor, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
              Text(
                floor.floorName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF78C991).withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  floor.status == 1 ? "Active" : "Inactive",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E7EB)),
          const SizedBox(height: 12),
          _infoRow("Hostel (Building ID)", floor.building.toString()),
          const SizedBox(height: 6),
          _infoRow("Branch (Branch ID)", floor.branchId.toString()),
          const SizedBox(height: 15),
          Row(
            children: [
              _actionIcon(
                icon: Icons.edit_outlined,
                color: const Color(0xFFD97706),
                bgColor: const Color(0xFFFEF3C7),
                onTap: () => _showUpdateFloorPopup(floor),
              ),
              const SizedBox(width: 10),
              _actionIcon(
                icon: Icons.delete_outline,
                color: const Color(0xFFDC2626),
                bgColor: const Color(0xFFFEE2E2),
                onTap: () {},
              ),
              const SizedBox(width: 10),
              _actionIcon(
                icon: Icons.people_outline,
                color: const Color(0xFF7C3AED),
                bgColor: const Color(0xFFF3E8FF),
                onTap: () => Get.to(
                  () => FloorStudentsPage(
                    floorId: floor.id,
                    floorName: floor.floorName,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionIcon({
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        width: 36,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black, fontSize: 13),
        children: [
          TextSpan(
            text: "$label : ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Align(
        alignment: Alignment.centerLeft,
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
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required dynamic value,
    required List<Map<String, dynamic>> items,
    required void Function(dynamic) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<dynamic>(
          isExpanded: true,
          value: value,
          hint: Text(
            hint,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          ),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
          items: items.map((item) {
            return DropdownMenuItem<dynamic>(
              value: item['id'],
              child: Text(
                item['name'],
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  void _showUpdateFloorPopup(FloorModel floor) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Navigator.of(dialogContext).pop(),
                  child: const Icon(Icons.close, color: Colors.black, size: 20),
                ),
              ),
              const SizedBox(height: 8),
              _buildPopupLabel("Floor Name"),
              _buildPopupField(initialValue: floor.floorName),
              const SizedBox(height: 16),
              _buildPopupLabel("Incharge"),
              _buildPopupField(hint: "Search incharge...."),
              const SizedBox(height: 16),
              _buildPopupLabel("Status"),
              _buildPopupDropdown(value: "Active"),
              const SizedBox(height: 24),
              _buildGradientButton(
                text: "Update Floor",
                icon: Icons.check,
                onTap: () => Navigator.of(dialogContext).pop(),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopupLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
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

  Widget _buildPopupField({String? initialValue, String? hint}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: TextField(
        controller: TextEditingController(text: initialValue),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildPopupDropdown({required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
          items: ["Active", "Inactive"].map((e) {
            return DropdownMenuItem(
              value: e,
              child: Text(
                e,
                style: const TextStyle(fontSize: 14, color: Colors.black),
              ),
            );
          }).toList(),
          onChanged: (v) {},
        ),
      ),
    );
  }
}
