import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/skeleton.dart';
import '../widgets/staff_header.dart';
import 'package:student_app/staff_app/controllers/outing_pending_controller.dart';
import 'package:student_app/staff_app/model/model2.dart';
import 'package:student_app/staff_app/pages/verify_outing_page.dart';

class OutingPendingListPage extends StatefulWidget {
  const OutingPendingListPage({super.key});

  @override
  State<OutingPendingListPage> createState() => _OutingPendingListPageState();
}

class _OutingPendingListPageState extends State<OutingPendingListPage> {
  final OutingPendingController controller = Get.put(OutingPendingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const StaffHeader(title: "Outing Pending"),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F3FF),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    _buildSearchBar(),
                    const SizedBox(height: 25),
                    _buildStudentList(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Header is now managed by StaffHeader widget

  // ================= SEARCH BAR =================
  Widget _buildSearchBar() {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC084FC).withOpacity(0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onChanged: controller.searchStudent,
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

  // ================= STUDENT LIST =================
  Widget _buildStudentList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: StaffLoadingAnimation(),
          ),
        );
      }

      if (controller.filteredStudents.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              "No pending outings found",
              style: TextStyle(color: Colors.grey),
            ),
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.filteredStudents.length,
        itemBuilder: (context, index) {
          final StudentModel s = controller.filteredStudents[index];

          return GestureDetector(
            onTap: () {
              Get.to(
                () => VerifyOutingPage(
                  adm: s.admNo,
                  name: s.name,
                  status: s.status,
                  time: "08:47 PM",
                  type: "Home Pass",
                  imageUrl: s.image,
                  permissionBy: s.permissionBy,
                  isReportIn: false,
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 4,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // IMAGE
                  Container(
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: (s.image != null && s.image!.isNotEmpty)
                            ? NetworkImage(s.image!)
                            : const AssetImage("assets/girl.jpg")
                                  as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // DETAILS
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.admNo,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          s.name.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Permission By : ${s.permissionBy}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}
