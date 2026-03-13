import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/branch_controller.dart';
import '../controllers/outing_controller.dart';
import '../widgets/skeleton.dart';
import '../widgets/staff_header.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import '../utils/iconify_icons.dart';
import 'issue_outing.dart';

class OutingListPage extends StatefulWidget {
  const OutingListPage({super.key});

  @override
  State<OutingListPage> createState() => _OutingListPageState();
}

class _OutingListPageState extends State<OutingListPage> {
  bool showStudents = false;
  final TextEditingController searchController = TextEditingController();
  final BranchController branchController = Get.put(BranchController());
  final OutingController controller = Get.put(OutingController());

  String selectedBranchName = "All";
  String selectedStatus = "All";
  String selectedDuration = "All";
  DateTime? fromDate;
  DateTime? toDate;

  // ─── color palette ─────────────────────────────────────────────
  static const Color _purple = Color(0xFF7C3FE3);

  @override
  void initState() {
    super.initState();
    branchController.loadBranches();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Custom Header to match the image precisely
          StaffHeader(title: "Outing List", onBack: () => Get.back()),
          Expanded(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatsGrid(),
                        const SizedBox(height: 5),

                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F3FF),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSearchBar(),
                              const SizedBox(height: 18),
                              const Text(
                                "Filter Options",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 14),
                              _buildFilterSectionContent(),
                              const SizedBox(height: 18),
                              _buildApplyButton(),
                            ],
                          ),
                        ),

                        if (showStudents) ...[
                          const SizedBox(height: 25),
                          _buildStudentList(),
                        ],
                      ],
                    ),
                  ),
                ),
                _buildStickyBottomButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //  SECTION LABEL
  // ─────────────────────────────────────────────────────────────────
  Widget _buildStatsGrid() {
    return Obx(() {
      if (controller.isLoading.value && controller.outingList.isEmpty) {
        return GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 0.9,
          children: const [
            StatCardSkeleton(baseColor: Color(0xFF11DA81)),
            StatCardSkeleton(baseColor: Color(0xFFEE6B9D)),
            StatCardSkeleton(baseColor: Color(0xFF29A5ED)),
            StatCardSkeleton(baseColor: Color(0xFFF6AD39)),
          ],
        );
      }
      return GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 0.9,
        children: [
          _buildStatCard("Out Pass", controller.outPassInfo, [
            const Color(0xFF11DA81),
            const Color(0xFF2BB78B),
          ], IconifyIcons.logout),
          _buildStatCard("Self Outing", controller.selfOutingInfo, [
            const Color(0xFFEE6B9D),
            const Color(0xFFCC385D),
          ], IconifyIcons.logout),
          _buildStatCard("Home Pass", controller.homePassInfo, [
            const Color(0xFF29A5ED),
            const Color(0xFF2987E9),
          ], IconifyIcons.home),
          _buildStatCard("Self Home", controller.selfHomeInfo, [
            const Color(0xFFF6AD39),
            const Color(0xFFF69137),
          ], IconifyIcons.home),
        ],
      );
    });
  }

  Widget _buildStatCard(
    String title,
    Rx infoRx,
    List<Color> colors,
    String icon,
  ) {
    return Obx(() {
      final info = infoRx.value;
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
          boxShadow: [
            BoxShadow(
              color: colors[0].withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // Bottom decorative arcs (slightly smaller for compact look)
              Positioned(
                bottom: -30,
                right: -30,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.25),
                      width: 1.2,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -45,
                right: -45,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.25),
                      width: 1.2,
                    ),
                  ),
                ),
              ),
              // Main Content
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 65,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            title,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            info?.total.toString() ?? "0",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 30,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Iconify(
                                      icon,
                                      color: Colors.white.withOpacity(0.95),
                                      size: 32,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _statLine("Pending", info?.pending ?? 0),
                            const SizedBox(height: 0.5),
                            _statLine("Approved", info?.approved ?? 0),
                            const SizedBox(height: 0.5),
                            _statLine("Not Reported", info?.notReported ?? 0),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _statLine(String label, int value) {
    return Text(
      "$label : $value",
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  //  SEARCH BAR
  // ─────────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD8B4FE), width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          const Icon(Icons.search, color: Color(0xFF9CA3AF), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: searchController,
              onChanged: controller.search,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "Search Student or ID",
                hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSectionContent() {
    return Column(
      children: [
        _buildSimpleDropdown(
          value: selectedBranchName,
          items: ["All", ...branchController.branches.map((b) => b.branchName)],
          onChanged: (v) {
            setState(() => selectedBranchName = v!);
            if (v == "All") {
              controller.filterByBranch("All");
            } else {
              final b = branchController.branches.firstWhere(
                (e) => e.branchName == v,
              );
              controller.filterByBranch(b.id.toString());
            }
          },
        ),
        const SizedBox(height: 12),
        _buildSimpleDropdown(
          value: selectedStatus,
          items: ["All", "Pending", "Approved", "Not Reported"],
          onChanged: (v) {
            setState(() => selectedStatus = v!);
            controller.filterByStatus(v!);
          },
        ),
        const SizedBox(height: 12),
        _buildSimpleDropdown(
          value: selectedDuration,
          items: [
            "All",
            "Today",
            "Yesterday",
            "Last 7 Days",
            "This Month",
            "Custom",
          ],
          onChanged: (v) {
            setState(() => selectedDuration = v!);
            if (v != "Custom") {
              controller.filterByDate(v!.replaceAll(" ", ""));
            }
          },
        ),
        if (selectedDuration == "Custom") ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDateChip(
                  fromDate?.toString().substring(0, 10) ?? 'From date',
                  icon: Icons.calendar_today,
                  onTap: () async {
                    fromDate = await showDatePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      initialDate: DateTime.now(),
                    );
                    setState(() {});
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildDateChip(
                  toDate?.toString().substring(0, 10) ?? 'To date',
                  icon: Icons.calendar_today,
                  onTap: () async {
                    toDate = await showDatePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      initialDate: DateTime.now(),
                    );
                    setState(() {});
                  },
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSimpleDropdown({
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
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
          value: items.contains(value) ? value : items[0],
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
          items: items
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDateChip(
    String text, {
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final bool isSelected = !text.contains('date');
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF5F3FF) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFD8B4FE)
                : const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? const Color(0xFF7C3FE3) : Colors.grey,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? const Color(0xFF7C3FE3) : Colors.grey,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplyButton() {
    return GestureDetector(
      onTap: () {
        if (selectedDuration == "Custom" &&
            fromDate != null &&
            toDate != null) {
          controller.filterByCustomDate(fromDate!, toDate!);
        }
        setState(() => showStudents = true);
      },
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7C3FE3), Color(0xFFB06EF3)],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: _purple.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.filter_alt_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text(
              "Apply Filters",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  //  STUDENT LIST
  // ─────────────────────────────────────────────────────────────────
  Widget _buildStudentList() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3FF),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: StaffLoadingAnimation());
        }

        if (controller.filteredList.isEmpty) {
          return const Center(child: Text("No records found"));
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.filteredList.length,
          itemBuilder: (context, index) {
            return _buildStudentCard(controller.filteredList[index]);
          },
        );
      }),
    );
  }

  Widget _buildStudentCard(dynamic o) {
    final bool isApproved = o.status == "Approved";
    final Color statusBg = isApproved
        ? const Color(0xFF4CAF50)
        : const Color(0xFFF39C12);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEDE9FE)),
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
              Expanded(
                child: Text(
                  o.studentName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  o.status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                o.admno,
                style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              ),
              Text(
                o.outingType,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _studentInfoRow(Icons.access_time, "Purpose : ", o.purpose),
          const SizedBox(height: 8),
          _studentInfoRow(
            Icons.person_outline,
            "Permission By : ",
            o.permission,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _studentInfoIconRow(Icons.calendar_today, o.outDate),
              const SizedBox(width: 16),
              _studentInfoIconRow(Icons.access_time, o.outingTime),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _actionIconButton(
                Icons.flag,
                const Color(0xFFF39C12),
                () => _showRemarksDialog(o),
              ),
              const SizedBox(width: 8),
              _actionIconButton(
                Icons.delete,
                const Color(0xFFEF4444),
                () => _showDeleteConfirmation(o),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _studentInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.black),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
          ),
        ),
      ],
    );
  }

  Widget _studentInfoIconRow(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.black),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _actionIconButton(IconData icon, Color bgColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: bgColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: bgColor),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  //  REMARKS DIALOG
  // ─────────────────────────────────────────────────────────────────
  void _showRemarksDialog(dynamic o) {
    final TextEditingController remarksController = TextEditingController();
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  const Text(
                    "Remarks *",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TextField(
                      controller: remarksController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () async {
                      if (remarksController.text.trim().isEmpty) {
                        Get.snackbar(
                          "Error",
                          "Remarks cannot be empty",
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                        return;
                      }
                      await controller.addOutingRemarks(
                        o.id,
                        remarksController.text,
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF9070FF), Color(0xFFC0A0FF)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Obx(
                        () => controller.isLoading.value
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Center(
                                child: Text(
                                  "Update Remarks",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: const Icon(Icons.close, color: Colors.black, size: 24),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierColor: Colors.black.withOpacity(0.5),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  //  DELETE CONFIRMATION DIALOG
  // ─────────────────────────────────────────────────────────────────
  void _showDeleteConfirmation(dynamic o) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEAD1),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        "!",
                        style: TextStyle(
                          color: Color(0xFFF9A825),
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Are you sure? You want to delete this Outing",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "you won't be able to revert this !",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 25),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Get.back();
                            Get.snackbar(
                              "Deleted",
                              "Outing record deleted successfully",
                              backgroundColor: Colors.green,
                              colorText: Colors.white,
                            );
                          },
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFFA685F9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Text(
                                "Yes delete it!",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Get.back(),
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF7070),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Text(
                                "Cancel",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: const Icon(Icons.close, color: Colors.black, size: 24),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierColor: Colors.black.withOpacity(0.5),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  //  STICKY BOTTOM BUTTON
  // ─────────────────────────────────────────────────────────────────
  Widget _buildStickyBottomButton() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE5E7EB), width: 1.5)),
        ),
        child: GestureDetector(
          onTap: () {
            Get.to(
              () => const IssueOutingPage(studentName: '', outingType: ''),
            );
          },
          child: Container(
            height: 54,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4DA1A9), Color(0xFFA1D071)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4DA1A9).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, color: Colors.white, size: 24),
                SizedBox(width: 8),
                Text(
                  "Issue Outing",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
