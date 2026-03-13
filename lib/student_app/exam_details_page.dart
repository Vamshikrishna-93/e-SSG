import 'package:flutter/material.dart';

// This page displays the details of a specific exam.
class ExamDetailsPage extends StatelessWidget {
  final Map<String, dynamic> exam;

  const ExamDetailsPage({super.key, required this.exam});

  @override
  Widget build(BuildContext context) {
    // Determine subject name - check multiple possible keys
    final String subject = exam['subject'] ?? 
                         exam['subject_name'] ?? 
                         exam['exam_name'] ?? 
                         exam['title'] ?? 
                         'IPE';
    
    final String branch = exam['branch'] ?? 'SSJC-VIDHYA BHAVAN';
    final String examType = exam['exam_type'] ?? 'Online';
    final String duration = exam['duration'] ?? '-';
    final String examId = exam['exam_id']?.toString() ?? '660';
    final String date = exam['date'] ?? '2025-10-27';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 1. Purple Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 10,
              bottom: 30,
              left: 16,
              right: 16,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF7C3AED),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
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
                const SizedBox(width: 16),
                const Text(
                  "Details",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Details Table Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 4,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow("Subject", subject),
                        _buildDivider(),
                        _buildDetailRow("Branch", branch),
                        _buildDivider(),
                        _buildDetailRow("Exam Type", examType),
                        _buildDivider(),
                        _buildDetailRow("Duration", duration),
                        _buildDivider(),
                        _buildDetailRow(
                          "Exam ID",
                          examId,
                          valueColor: const Color(0xFFEF4444),
                        ),
                        _buildDivider(),
                        _buildDetailRow("Date", date, isLast: true),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 3. Instructions Section
                  const Text(
                    "Instructions",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF3B82F6),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "Standard exam instructions apply.",
                          style: TextStyle(
                            color: Color(0xFF1E293B),
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor, bool isLast = false}) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Container(
            width: 130,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const VerticalDivider(
            width: 1,
            thickness: 1,
            color: Color(0xFFE2E8F0),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Text(
                value,
                style: TextStyle(
                  color: valueColor ?? Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0xFFE2E8F0),
    );
  }
}
