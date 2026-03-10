import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/staff_header.dart';
import '../controllers/branch_controller.dart';
import '../controllers/exam_category_controller.dart';

class ExamCategoryListPage extends StatefulWidget {
  const ExamCategoryListPage({super.key});

  @override
  State<ExamCategoryListPage> createState() => _ExamCategoryListPageState();
}

class _ExamCategoryListPageState extends State<ExamCategoryListPage> {
  final BranchController branchCtrl = Get.put(BranchController());
  final ExamCategoryController categoryCtrl = Get.put(ExamCategoryController());

  String _query = "";
  int? selectedBranchId;

  @override
  void initState() {
    super.initState();
    branchCtrl.loadBranches();
    categoryCtrl.loadCategories();
  }

  // ================= UI Constants =================
  static const Color primaryPurple = Color(0xFF7E49FF);
  static const Color lavenderBg = Color(0xFFE8EEFF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const StaffHeader(title: "Exam Categories"),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Branch",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ================= BRANCH DROPDOWN =================
                  Obx(() {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: selectedBranchId,
                          isExpanded: true,
                          hint: Text(
                            "Select Branch",
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 14,
                            ),
                          ),
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.black54,
                          ),
                          items: branchCtrl.branches.map((b) {
                            return DropdownMenuItem<int>(
                              value: b.id,
                              child: Text(
                                b.branchName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedBranchId = value;
                              categoryCtrl
                                  .loadCategories(); // No argument needed
                            });
                          },
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 25),

                  // ================= DATA VIEW =================
                  selectedBranchId == null
                      ? _buildInitialMessage()
                      : Obx(() {
                          if (categoryCtrl.isLoading.value) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.only(top: 50),
                                child: CircularProgressIndicator(
                                  color: primaryPurple,
                                ),
                              ),
                            );
                          }

                          return _buildCategoryList();
                        }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialMessage() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Image.network(
            "https://cdni.iconscout.com/illustration/premium/thumb/selecting-exam-category-11112448-8924151.png",
            height: 230,
            errorBuilder: (c, e, s) => const Icon(
              Icons.category_outlined,
              size: 100,
              color: lavenderBg,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Please select a branch to view categories",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList() {
    final filtered = categoryCtrl.categories.where((cat) {
      final matchesSearch = cat.category.toLowerCase().contains(
        _query.toLowerCase(),
      );
      final matchesBranch = cat.branchId == selectedBranchId;
      return matchesSearch && matchesBranch;
    }).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: lavenderBg.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // SEARCH BAR (Specific Style)
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: primaryPurple.withOpacity(0.5),
                width: 1.5,
              ),
            ),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: "Search Student or ID",
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.grey,
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 16),

          if (filtered.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Text(
                "No categories found",
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            ...filtered.asMap().entries.map((entry) {
              int idx = entry.key;
              var item = entry.value;
              return _buildCategoryCard(
                idx + 1,
                item.category,
                item.branchName,
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(int sno, String name, String branch) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: primaryPurple.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "NO : $sno",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.folder_rounded,
                color: Color(0xFF60A5FA),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Active",
                  style: TextStyle(
                    color: Color(0xFF10B981),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.location_on, color: Color(0xFF818CF8), size: 18),
              const SizedBox(width: 8),
              Text(
                "Branch : ",
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Expanded(
                child: Text(
                  branch,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
