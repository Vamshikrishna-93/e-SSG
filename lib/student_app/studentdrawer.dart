import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:student_app/student_app/services/student_profile_service.dart';

class StudentDrawerPage extends StatelessWidget {
  const StudentDrawerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Row(
        children: [
          // Main Drawer content (80% width)
          Expanded(
            flex: 8,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF3EFFF), // Light Lavender
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(50),
                ),
              ),
              child: Column(
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      children: [
                        _buildMenuItem(
                          context,
                          icon: Icons.people_outline,
                          title: "Class Attendance",
                          onTap: () {
                            Navigator.pop(context);
                            Get.toNamed('/studentClassAttendance');
                          },
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.badge_outlined,
                          title: "Hostel Attendance",
                          onTap: () {
                            Navigator.pop(context);
                            Get.toNamed('/studentHostelAttendance');
                          },
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.currency_rupee,
                          title: "Hostel Fee",
                          onTap: () {
                            Navigator.pop(context);
                            Get.toNamed('/studentHostelFee');
                          },
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.description_outlined,
                          title: "Documents",
                          onTap: () {
                            Navigator.pop(context);
                            Get.toNamed('/studentDocuments');
                          },
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.directions_walk_outlined,
                          title: "Outings",
                          onTap: () {
                            Navigator.pop(context);
                            Get.toNamed('/studentOutings');
                          },
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.speaker_notes_outlined,
                          title: "Remarks",
                          onTap: () {
                            Navigator.pop(context);
                            Get.toNamed('/studentRemarks');
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Semitransparent dismissal area (20% width)
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(color: Colors.black.withOpacity(0.5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 30,
        bottom: 30,
        left: 25,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF8B5CF6), Color(0xFFC084FC)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Image Circle
          ValueListenableBuilder<String?>(
            valueListenable: StudentProfileService.profileImageUrl,
            builder: (context, imageUrl, _) {
              return Container(
                width: 75,
                height: 75,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                  image: (imageUrl != null && imageUrl.isNotEmpty)
                      ? DecorationImage(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: (imageUrl == null || imageUrl.isEmpty)
                    ? const Center(
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: Color(0xFF8B5CF6),
                        ),
                      )
                    : null,
              );
            },
          ),
          const SizedBox(height: 18),
          // User Name
          ValueListenableBuilder<String?>(
            valueListenable: StudentProfileService.displayName,
            builder: (context, name, _) {
              return Text(
                name ?? "Ashok Reddy",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
          const SizedBox(height: 6),
          // User ID
          ValueListenableBuilder<String?>(
            valueListenable: StudentProfileService.displayId,
            builder: (context, id, _) {
              return Text(
                "Admission No: ${id ?? ''}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: ListTile(
        onTap: onTap,
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
        leading: Icon(icon, color: Colors.black87, size: 22),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
      ),
    );
  }
}
