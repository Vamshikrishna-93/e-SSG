import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/non_hostel_controller.dart';
import '../controllers/branch_controller.dart';
import '../model/non_hostel_student_model.dart';
import '../widgets/staff_header.dart';

class NonHostelPage extends StatefulWidget {
  const NonHostelPage({super.key});

  @override
  State<NonHostelPage> createState() => _NonHostelPageState();
}

class _NonHostelPageState extends State<NonHostelPage> {
  late final NonHostelController controller;

  @override
  void initState() {
    super.initState();
    // Ensure BranchController is available
    if (!Get.isRegistered<BranchController>()) {
      Get.put(BranchController());
    }
    controller = Get.put(NonHostelController());
  }

  // ================= UI Constants =================
  static const Color primaryPurple = Color(0xFF7E49FF);
  static const Color lavenderBg = Color(0xFFF1F4FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const StaffHeader(title: "Non Hostel Students"),

          // ================= MAIN CONTAINER =================
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              decoration: BoxDecoration(
                color: lavenderBg.withOpacity(0.5),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                children: [
                  // Search inside container
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: primaryPurple.withOpacity(0.3),
                        ),
                      ),
                      child: TextField(
                        controller: controller.searchController,
                        onChanged: controller.filterStudents,
                        decoration: const InputDecoration(
                          icon: Icon(
                            Icons.search,
                            color: Colors.black54,
                            size: 20,
                          ),
                          hintText: "Search by Name or Admission No.....",
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
                    child: Obx(() {
                      if (controller.isLoading.value) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: primaryPurple,
                            ),
                          ),
                        );
                      }
                      if (controller.filteredList.isEmpty) {
                        return const Center(
                          child: Text(
                            "No students found",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 15,
                            ),
                          ),
                        );
                      }
                      return ListView.builder(
                        itemCount: controller.filteredList.length,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 5,
                        ),
                        itemBuilder: (context, index) {
                          final student = controller.filteredList[index];
                          return _buildStudentCard(student);
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(NonHostelStudentModel student) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFB59CFF),
            radius: 28,
            child: Text(
              student.studentName.isNotEmpty
                  ? student.studentName[0].toUpperCase()
                  : "?",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.studentName.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  "(${student.admNo})",
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 18,
                      color: primaryPurple,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 13,
                          ),
                          children: [
                            const TextSpan(
                              text: "Address : ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                            TextSpan(text: student.address.toUpperCase()),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
