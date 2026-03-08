import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StudentAttendanceViewPage extends StatelessWidget {
  const StudentAttendanceViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryPurple = Color(0xFF7E49FF);
    const lavenderBg = Color(0xFFF3EBFF);

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
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                const Text(
                  "Students Attendance",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // ================= STUDENTS LIST CONTAINER =================
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: lavenderBg.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  children: [
                    _buildStudentCard(0),
                    _buildStudentCard(1),
                    _buildStudentCard(2),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "S.NO: 1",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                "Adm No : 251288",
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(color: Colors.grey.shade200, height: 1.5),
          const SizedBox(height: 12),
          _infoRow("Student Name", "Pulagara Veera Vasatha\nRayudu"),
          const SizedBox(height: 12),
          const Text(
            "Attendance Status :",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          _buildAttendanceDaysRow(),
        ],
      ),
    );
  }

  Widget _buildAttendanceDaysRow() {
    // Days 2, 7, 14, 20, 25 are absent — rest are present
    const absentDays = {2, 7, 14, 20, 25};

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(31, (index) {
          final day = index + 1;
          final isAbsent = absentDays.contains(day);

          return Container(
            margin: const EdgeInsets.only(right: 8),
            width: 40,
            height: 55,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300, width: 1.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "$day",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: isAbsent
                        ? const Color(0xFFFB7185) // Red for Absent
                        : const Color(0xFF6FC888), // Green for Present
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      isAbsent ? "A" : "P",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            "$label :",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}
