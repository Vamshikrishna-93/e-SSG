import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/branch_controller.dart';
import '../controllers/outing_controller.dart';
import '../widgets/skeleton.dart';
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
          _buildHeader(context),
          Expanded(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildStatsGrid(),
                        const SizedBox(height: 25),
                        _buildSearchBar(),
                        const SizedBox(height: 15),
                        _buildFilterSection(),
                        if (showStudents) ...[
                          const SizedBox(height: 20),
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
        color: Color(0xFF8B5CF6),
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
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 15),
          const Text(
            "Outing List",
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

  // ================= STATS GRID =================
  Widget _buildStatsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        double itemWidth = (constraints.maxWidth - 16) / 2;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildStatCard("Out Pass", controller.outPassInfo, itemWidth, [
              const Color(0xFF10B981),
              const Color(0xFF34D399),
            ], Icons.logout_rounded),
            _buildStatCard(
              "Self Outing",
              controller.selfOutingInfo,
              itemWidth,
              [const Color(0xFFF43F5E), const Color(0xFFFB7185)],
              Icons.logout_rounded,
            ),
            _buildStatCard("Home Pass", controller.homePassInfo, itemWidth, [
              const Color(0xFF3B82F6),
              const Color(0xFF60A5FA),
            ], Icons.home_outlined),
            _buildStatCard("Self Home", controller.selfHomeInfo, itemWidth, [
              const Color(0xFFF59E0B),
              const Color(0xFFFBBF24),
            ], Icons.home_outlined),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    Rx infoRx,
    double width,
    List<Color> colors,
    IconData icon,
  ) {
    return SizedBox(
      width: width,
      child: Obx(() {
        final info = infoRx.value;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
            boxShadow: [
              BoxShadow(
                color: colors[0].withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -15,
                bottom: -15,
                child: Opacity(
                  opacity: 0.15,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Icon(icon, color: Colors.white, size: 22),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    info?.total.toString() ?? "0",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildSubStatRow("Pending", info?.pending ?? 0),
                  _buildSubStatRow("Approved", info?.approved ?? 0),
                  _buildSubStatRow("Not Reported", info?.notReported ?? 0),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSubStatRow(String label, int value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Text(
        "$label : $value",
        style: TextStyle(
          color: Colors.white.withOpacity(0.95),
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  // ================= SEARCH BAR =================
  Widget _buildSearchBar() {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD8B4FE), width: 1.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: searchController,
              onChanged: controller.search,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "Search Student or ID",
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= FILTER SECTION =================
  Widget _buildFilterSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3FF),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Filter Options",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          _buildDropdownField(
            value: selectedBranchName,
            hint: "All",
            onChanged: (v) {
              setState(() => selectedBranchName = v!);
              // Find ID for the branch name to call controller
              if (v == "All") {
                controller.filterByBranch("All");
              } else {
                final b = branchController.branches.firstWhere(
                  (element) => element.branchName == v,
                );
                controller.filterByBranch(b.id.toString());
              }
            },
            items: [
              "All",
              ...branchController.branches.map((b) => b.branchName),
            ],
          ),
          const SizedBox(height: 12),
          _buildDropdownField(
            value: selectedStatus,
            hint: "All",
            onChanged: (v) {
              setState(() => selectedStatus = v!);
              controller.filterByStatus(v!);
            },
            items: ["All", "Pending", "Approved", "Not Reported"],
          ),
          const SizedBox(height: 12),
          _buildDropdownField(
            value: selectedDuration,
            hint: "All",
            onChanged: (v) {
              setState(() => selectedDuration = v!);
              if (v != "Custom") {
                controller.filterByDate(v!.replaceAll(" ", ""));
              }
            },
            items: [
              "All",
              "Today",
              "Yesterday",
              "Last 7 Days",
              "This Month",
              "Custom",
            ],
          ),

          if (selectedDuration == "Custom") ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDateChip(
                    fromDate?.toString().substring(0, 10) ?? 'Select From',
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
                const SizedBox(width: 8),
                Expanded(
                  child: _buildDateChip(
                    toDate?.toString().substring(0, 10) ?? 'Select To',
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

          const SizedBox(height: 25),
          GestureDetector(
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
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFC084FC), Color(0xFFA855F7)],
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Center(
                child: Text(
                  "Apply Filters",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String value,
    required String hint,
    required void Function(String?) onChanged,
    required List<String> items,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : items[0],
          isExpanded: true,
          items: items
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: onChanged,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
          style: const TextStyle(color: Colors.black87, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildDateChip(String text, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 13, color: Colors.black54),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // ================= STUDENT LIST =================
  Widget _buildStudentList() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3FF),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: StaffLoadingAnimation()),
          );
        }
        if (controller.filteredList.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text(
                "No records found",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.filteredList.length,
          itemBuilder: (context, index) {
            final o = controller.filteredList[index];
            bool isApproved = o.status == "Approved";

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              o.studentName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              o.admno,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isApproved
                                  ? const Color(0xFF22C55E)
                                  : const Color(0xFFF59E0B),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Text(
                              o.status,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            o.outingType,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF374151),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Color(0xFFF3F4F6), height: 1),
                  const SizedBox(height: 12),

                  _buildDetailRow(Icons.info_outline, "Purpose : ${o.purpose}"),
                  _buildDetailRow(
                    Icons.person_outline,
                    "Permission By : ${o.permission}",
                  ),
                  _buildDetailRow(
                    Icons.access_time,
                    "${o.outDate}  •  ${o.outingTime}",
                  ),

                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildActionButton(
                        icon: Icons.flag_outlined,
                        color: const Color(0xFFF97316),
                        bgColor: const Color(0xFFFFF7ED),
                        onTap: () => _showRemarksDialog(o),
                      ),
                      const SizedBox(width: 10),
                      _buildActionButton(
                        icon: Icons.edit_outlined,
                        color: const Color(0xFFEAB308),
                        bgColor: const Color(0xFFFEF9C3),
                        onTap: () => _showRemarksDialog(
                          o,
                        ), // Map edit to the same remarks dialog as requested
                      ),
                      const SizedBox(width: 10),
                      _buildActionButton(
                        icon: Icons.delete_outline,
                        color: const Color(0xFFEF4444),
                        bgColor: const Color(0xFFFEE2E2),
                        onTap: () => _showDeleteConfirmation(o),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF6B7280)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }

  void _showRemarksDialog(dynamic o) {
    final TextEditingController remarksController = TextEditingController();
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        backgroundColor: Colors.white,
        elevation: 0,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
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
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1.2,
                      ),
                    ),
                    child: TextField(
                      controller: remarksController,
                      maxLines: 5,
                      style: const TextStyle(fontSize: 15),
                      decoration: const InputDecoration(
                        hintText: "",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  GestureDetector(
                    onTap: () {
                      controller.addOutingRemarks(o.id, remarksController.text);
                      Get.back();
                    },
                    child: Container(
                      width: double.infinity,
                      height: 55,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFA78BFA), Color(0xFFC4B5FD)],
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFA78BFA).withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
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
                ],
              ),
              Positioned(
                right: 0,
                top: 0,
                child: IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close, color: Colors.black, size: 24),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierColor: Colors.black.withOpacity(0.6),
    );
  }

  void _showDeleteConfirmation(dynamic o) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        backgroundColor: Colors.white,
        elevation: 0,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  // Orange exclamation icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD8BE), // Light orange background
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        "!",
                        style: TextStyle(
                          color: Color(0xFFFB923C), // Darker orange
                          fontSize: 50,
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
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "you won't be able to revert this !",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Colors.black54),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      // Yes delete it! button
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Get.back();
                            Get.snackbar(
                              "Deleted",
                              "Outing record deleted successfully",
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                          },
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFA78BFA), Color(0xFFC4B5FD)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Text(
                                "Yes delete it!",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Cancel button
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Get.back(),
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFB7185), // Pinkish red
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Text(
                                "Cancel",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
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
              // Close icon at top-right
              Positioned(
                right: 0,
                top: 0,
                child: IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close, color: Colors.black, size: 24),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierColor: Colors.black.withOpacity(0.6),
    );
  }

  // ================= STICKY BOTTOM BUTTON =================
  Widget _buildStickyBottomButton() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: () {
            Get.to(
              () => const IssueOutingPage(studentName: '', outingType: ''),
            );
          },
          child: Container(
            height: 55,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF34D399), Color(0xFF84CC16)],
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: Colors.white),
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
      ),
    );
  }
}
