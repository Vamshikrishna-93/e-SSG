import 'package:flutter/material.dart';

// This page displays the details of a specific exam.
class ExamDetailsPage extends StatelessWidget {
  final Map<String, dynamic> exam;

  const ExamDetailsPage({super.key, required this.exam});

  @override
  Widget build(BuildContext context) {
    final String examName = exam['exam_name'] ?? exam['title'] ?? 'N/A';
    final String subject = exam['subject'] ?? 'N/A';
    final String branch = exam['branch'] ?? 'SSJC-VIDHYA BHAVAN';
    final String examType = exam['exam_type'] ?? 'Online Exam';
    final String duration = exam['duration'] ?? '-';
    final String examId = exam['exam_id']?.toString() ?? 'N/A';
    final String date = exam['date'] ?? '2024-03-15 at 10:00 AM';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          "Details: $examName",
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.close,
              color: Color(0xFF64748B),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tabs simulation
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 8.0, bottom: 8),
                  child: Text(
                    "Details",
                    style: TextStyle(
                      color: Color(0xFF2563EB),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(height: 3, width: 60, color: const Color(0xFF2563EB)),
                const SizedBox(height: 20),
              ],
            ),

            // Table Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                children: [
                  _buildRow(context, "Subject", subject),
                  _buildDivider(),
                  _buildRow(context, "Branch", branch),
                  _buildDivider(),
                  _buildRow(context, "Exam Type", examType),
                  _buildDivider(),
                  _buildRow(context, "Duration", duration),
                  _buildDivider(),
                  _buildRow(
                    context,
                    "Exam ID",
                    examId,
                    valueColor: const Color(0xFFD81B60),
                  ),
                  _buildDivider(),
                  _buildRow(context, "Date", date, isLast: true),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Instructions
            const Text(
              "Instructions",
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: Color(0xFF64748B),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    "Standard exam instructions apply.",
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Container(
            width: 140,
            padding: const EdgeInsets.all(16),
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 14,
              ),
            ),
          ),
          const VerticalDivider(
            width: 1,
            color: Color(0xFFE2E8F0),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Text(
                value,
                style: TextStyle(
                  color: valueColor ?? const Color(0xFF1E293B),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
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
