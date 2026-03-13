import 'package:flutter/material.dart';
import '../widgets/staff_header.dart';

class SyllabusDetailsPage extends StatelessWidget {
  const SyllabusDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Column(
        children: [
          /// STAFF HEADER
          const StaffHeader(title: "Syllabus Details"),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// SUBJECT TITLE
                  const Text(
                    "MATHS",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  /// DETAILS CARD
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.10),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRow("Exam Name", "INC SR MAINS-02"),
                        const SizedBox(height: 8),

                        _buildRow("Batch/Course", "SS-SR-SM1 / MAINS"),
                        const SizedBox(height: 8),

                        _buildRow("Branch", "SSJC-SSG EAMCET CAMPUS"),
                        const SizedBox(height: 8),

                        _buildRow("Group", "SR MPC"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// SUBJECT SYLLABUS TITLE
                  const Text(
                    "Subject Syllabus",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  /// SYLLABUS BOX
                  Container(
                    height: 140,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: const Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "No syllabus content added yet.",
                        style: TextStyle(color: Colors.black87),
                      ),
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

  /// DETAILS ROW
  Widget _buildRow(String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            "$title :",
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),

        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF0A66FF),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
