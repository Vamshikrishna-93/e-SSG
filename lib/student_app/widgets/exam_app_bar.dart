import 'package:flutter/material.dart';

class ExamAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String examName;
  final String studentName;
  final String hallTicket;
  final String group;
  final int warnings;
  final int maxWarnings;

  const ExamAppBar({
    super.key,
    required this.examName,
    required this.studentName,
    required this.hallTicket,
    required this.group,
    required this.warnings,
    required this.maxWarnings,
  });

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(100),
      child: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1D68F2),
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1D58D8), Color(0xFF1D68F2)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const SizedBox(height: 20),
            Text(
              examName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              studentName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              "HT No: $hallTicket | $group",
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        actions: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white30),
              ),
              child: Text(
                "Warning $warnings/$maxWarnings",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(100);
}
