import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/branch_controller.dart';
import 'assign_students_page.dart';

class HostelMembersPage extends StatefulWidget {
  const HostelMembersPage({super.key});

  @override
  State<HostelMembersPage> createState() => _HostelMembersPageState();
}

class _HostelMembersPageState extends State<HostelMembersPage> {
  // ================= UI Constants =================
  static const Color primaryPurple = Color(0xFF7E49FF);
  static const Color lavenderBg = Color(0xFFF1F4FF);

  final BranchController branchCtrl = Get.put(BranchController());

  // Filter Values
  String? selectedHostel;
  int? selectedBranchId;
  String _query = "";

  // Mock Data List
  final List<Map<String, String>> _hostelMembers = [
    {
      'name': 'TIRUMALARADDY VENKATA KEER..',
      'admNo': '241400',
      'branch': 'SSJC-SSG EAMCET CAMPUS',
      'group': 'G3',
    },
    {
      'name': 'B. RAJESH KUMAR',
      'admNo': '241401',
      'branch': 'SSJC-SSG EAMCET CAMPUS',
      'group': 'G1',
    },
    {
      'name': 'CH. SAI TEJA',
      'admNo': '241402',
      'branch': 'SSJC-SSG EAMCET CAMPUS',
      'group': 'G2',
    },
    {
      'name': 'D. MAHESH',
      'admNo': '241403',
      'branch': 'SSJC-SSG EAMCET CAMPUS',
      'group': 'G3',
    },
  ];

  @override
  void initState() {
    super.initState();
    branchCtrl.loadBranches();
  }

  bool _showData = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ================= CUSTOM HEADER =================
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 10,
              bottom: 25,
              left: 20,
              right: 20,
            ),
            decoration: const BoxDecoration(
              color: primaryPurple,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(35),
                bottomRight: Radius.circular(35),
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
                const SizedBox(width: 20),
                const Text(
                  "Hostel Members",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // ================= FILTERS & CONTENT =================
          if (!_showData) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Column(
                children: [
                  _buildLabel("Category"),
                  _buildDropdown(
                    hint: "Hostel Wise",
                    value: selectedHostel,
                    items: ["Hostel Wise", "Floor Wise", "Room Wise"],
                    onChanged: (val) => setState(() => selectedHostel = val),
                  ),
                  const SizedBox(height: 12),
                  _buildLabel("Campus"),
                  Obx(
                    () => _buildDropdown(
                      hint: "Select Campus",
                      value: branchCtrl.branches
                          .firstWhereOrNull((b) => b.id == selectedBranchId)
                          ?.branchName,
                      items: branchCtrl.branches
                          .map((b) => b.branchName)
                          .toList(),
                      onChanged: (val) {
                        final selected = branchCtrl.branches.firstWhere(
                          (b) => b.branchName == val,
                        );
                        setState(() => selectedBranchId = selected.id);
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors:
                            (selectedHostel != null && selectedBranchId != null)
                            ? [const Color(0xFF856CFB), const Color(0xFFCD96FB)]
                            : [
                                const Color(0xFF856CFB).withOpacity(0.5),
                                const Color(0xFFCD96FB).withOpacity(0.5),
                              ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ElevatedButton(
                      onPressed:
                          selectedHostel != null && selectedBranchId != null
                          ? () {
                              setState(() {
                                _showData = true;
                              });
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        disabledBackgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Get Students",
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
            ),
            Expanded(child: _buildEmptyState()),
          ] else ...[
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: lavenderBg.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: primaryPurple.withOpacity(0.3),
                          ),
                        ),
                        child: TextField(
                          onChanged: (v) => setState(() => _query = v),
                          decoration: const InputDecoration(
                            icon: Icon(
                              Icons.search,
                              color: Colors.black54,
                              size: 20,
                            ),
                            hintText: "Search by Name, Adm No, Room....",
                            hintStyle: TextStyle(
                              color: Colors.black38,
                              fontSize: 13,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 0,
                        ),
                        itemCount: _hostelMembers
                            .where(
                              (m) =>
                                  m['name']!.toLowerCase().contains(
                                    _query.toLowerCase(),
                                  ) ||
                                  m['admNo']!.contains(_query),
                            )
                            .length,
                        itemBuilder: (context, i) {
                          final filtered = _hostelMembers
                              .where(
                                (m) =>
                                    m['name']!.toLowerCase().contains(
                                      _query.toLowerCase(),
                                    ) ||
                                    m['admNo']!.contains(_query),
                              )
                              .toList();
                          return _memberCard(filtered[i], i);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // ================= ASSIGN STUDENTS BUTTON =================
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF856CFB), Color(0xFFCD96FB)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ElevatedButton.icon(
                onPressed: () =>
                    Get.to(() => const AssignStudentsPage(students: [])),
                icon: const Icon(Icons.add, color: Colors.white, size: 18),
                label: const Text(
                  "Assign Students",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= MEMBER CARD =================
  Widget _memberCard(Map<String, String> data, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Group Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: primaryPurple,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              data['group'] ?? 'G3',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            data['name']!,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, thickness: 0.5),
          const SizedBox(height: 12),
          _infoRow("Adm No", data['admNo']!),
          const SizedBox(height: 4),
          _infoRow("Branch", data['branch'] ?? 'SSJC-SSG EAMCET CAMPUS'),
          const SizedBox(height: 14),
          Row(
            children: [
              _squareIcon(
                icon: Icons.edit_outlined,
                bgColor: const Color(0xFFFFF4D2),
                iconColor: const Color(0xFFFFB038),
                onTap: () {
                  _showEditMemberDialog(context, data);
                },
              ),
              const SizedBox(width: 10),
              _squareIcon(
                icon: Icons.delete_outline,
                bgColor: const Color(0xFFFFE6E4),
                iconColor: const Color(0xFFFF6B6B),
                onTap: () {
                  _showDeleteDialog(index);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= EDIT MEMBER DIALOG =================
  void _showEditMemberDialog(BuildContext ctx, Map<String, String> data) {
    String? selectedHostelVal = "VIDHYA BHAVAN";
    String? selectedFloorVal = "First Floor";
    String? selectedRoomVal = "G3";

    final hostels = ["VIDHYA BHAVAN", "BLOCK A", "BLOCK B"];
    final floors = ["First Floor", "Second Floor", "Third Floor"];
    final rooms = ["G1", "G2", "G3", "G4"];

    showDialog(
      context: ctx,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => Dialog(
          insetPadding: const EdgeInsets.all(0),
          backgroundColor: Colors.transparent,
          child: Scaffold(
            backgroundColor: Colors.white,
            body: Column(
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(dialogContext).padding.top + 10,
                    bottom: 25,
                    left: 20,
                    right: 20,
                  ),
                  decoration: const BoxDecoration(
                    color: primaryPurple,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(35),
                      bottomRight: Radius.circular(35),
                    ),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(dialogContext).pop(),
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
                      const SizedBox(width: 16),
                      const Text(
                        "Edit Hostel Member",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ---- Student Details Card ----
                        const Text(
                          "Student Details",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _detailRow("Name", data['name'] ?? ""),
                              const SizedBox(height: 8),
                              _detailRow("Adm No", data['admNo'] ?? ""),
                              const SizedBox(height: 8),
                              _detailRow(
                                "Branch",
                                data['branch'] ?? "SSJC-VIDHYA BHAVAN",
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ---- Hostel Assignment Card ----
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F0FF),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Hostel Assignment",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Change Location chip
                              GestureDetector(
                                onTap: () {},
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(
                                        Icons.location_on,
                                        size: 14,
                                        color: Colors.black54,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        "Change Location",
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Hostel dropdown
                              const Text(
                                "Hostel",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 6),
                              _editDropdown(
                                value: selectedHostelVal,
                                items: hostels,
                                onChanged: (v) =>
                                    setDialogState(() => selectedHostelVal = v),
                              ),
                              const SizedBox(height: 14),

                              // Floor dropdown
                              const Text(
                                "Floor",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 6),
                              _editDropdown(
                                value: selectedFloorVal,
                                items: floors,
                                onChanged: (v) =>
                                    setDialogState(() => selectedFloorVal = v),
                              ),
                              const SizedBox(height: 14),

                              // Room dropdown
                              const Text(
                                "Room",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 6),
                              _editDropdown(
                                value: selectedRoomVal,
                                items: rooms,
                                onChanged: (v) =>
                                    setDialogState(() => selectedRoomVal = v),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ---- Update Button ----
                Padding(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 12,
                    bottom: MediaQuery.of(dialogContext).padding.bottom + 16,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(dialogContext).pop();
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(
                          content: Text("Member updated successfully"),
                          backgroundColor: primaryPurple,
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF7C69FF), Color(0xFFD38DFA)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        "Update Members",
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
      ),
    );
  }

  Widget _editDropdown({
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black87, fontSize: 13.5),
        children: [
          TextSpan(
            text: "$label :  ",
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

  void _showDeleteDialog(int index) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Navigator.pop(dialogContext),
                  child: const Icon(Icons.close, size: 18, color: Colors.black),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    "!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Remove Member?",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                    height: 1.4,
                  ),
                  children: [
                    TextSpan(text: "Are you sure you want to remove\n"),
                    TextSpan(
                      text: "TIRUMALARADDY VENKATA KEERTHANA\n",
                      style: TextStyle(color: Colors.black87),
                    ),
                    TextSpan(text: "from this hostel?"),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB57BF2),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF7062),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          setState(() => _hostelMembers.removeAt(index));
                          Navigator.of(dialogContext).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Member removed successfully"),
                            ),
                          );
                        },
                        child: const Text(
                          "Remove",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            "https://cdni.iconscout.com/illustration/premium/thumb/searching-concept-illustration-download-in-svg-png-gif-file-formats--person-magnifying-glass-data-find-pack-business-illustrations-4712431.png",
            height: 200,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.cloud_off, size: 80, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "Please select a branch to view categories",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black54,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
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
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _squareIcon({
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5, left: 4),
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
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.1)),
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
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
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
