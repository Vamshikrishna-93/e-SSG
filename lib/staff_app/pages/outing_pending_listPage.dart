import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
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
          StaffHeader(
            title: "Outing Pending",
            onBack: () {
              if (Navigator.canPop(context)) {
                Get.back();
              } else {
                Get.offAllNamed('/home'); // Fallback to Dashboard
              }
            },
          ),

          Expanded(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F3FF),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  _buildSearchBar(),
                  const SizedBox(height: 25),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: controller.fetchOutings,
                      color: const Color(0xFFC084FC),
                      child: _buildStudentList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

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
      /// LOADING

      /// EMPTY
      if (controller.filteredStudents.isEmpty) {
        if (controller.isLoading.value) {
          return ListView.builder(
            padding: EdgeInsets.zero,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: 8,
            itemBuilder: (context, index) {
              return Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              );
            },
          );
        }

        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 100),
            Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  "No pending outings found",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        );
      }

      /// LIST
      return ListView.builder(
        padding: EdgeInsets.zero,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: controller.filteredStudents.length,
        itemBuilder: (context, index) {
          final StudentModel s = controller.filteredStudents[index];

          return GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VerifyOutingPage(
                    key: ValueKey(s.outingId),
                    outingId: s.outingId,
                    adm: s.admNo,
                    name: s.name,
                    status: s.status,
                    imageUrl: s.image,
                  ),
                ),
              );

              /// refresh list after returning
              controller.fetchOutings();
            },

            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: s.status.toLowerCase() == 'approved'
                    ? const Color(0xFF34D399) // Green for approved
                    : const Color(0xFF7D74FC), // Blue for others
                borderRadius: BorderRadius.circular(16),
              ),

              child: Row(
                children: [
                  /// IMAGE
                  Container(
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: _getImageProvider(s.image),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  /// DETAILS
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.admNo,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 2),

                        Text(
                          s.name.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          "Permission By : ${s.permissionBy}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
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

  // ================= IMAGE HANDLER =================
  ImageProvider _getImageProvider(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return const AssetImage("assets/girl.jpg");
    }

    if (imageUrl.startsWith('http')) {
      return NetworkImage(imageUrl);
    }

    try {
      final base64String = imageUrl.contains(',')
          ? imageUrl.split(',').last
          : imageUrl;

      return MemoryImage(base64Decode(base64String));
    } catch (e) {
      return const AssetImage("assets/girl.jpg");
    }
  }
}
