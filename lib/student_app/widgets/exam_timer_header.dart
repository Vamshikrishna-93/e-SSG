import 'package:flutter/material.dart';

class ExamTimerHeader extends StatelessWidget {
  final bool isDark;
  final String formattedTime;
  final bool isCritical;
  final int currentIndex;
  final int totalQuestions;

  const ExamTimerHeader({
    super.key,
    required this.isDark,
    required this.formattedTime,
    required this.isCritical,
    required this.currentIndex,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.timer_outlined,
                size: 20,
                color: isCritical ? Colors.red : Colors.blue,
              ),
              const SizedBox(width: 8),
              Text(
                formattedTime,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isCritical
                      ? Colors.red
                      : (isDark ? Colors.white : Colors.black87),
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.blue.withOpacity(0.2)
                  : Colors.blue.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "Question ${currentIndex + 1} of $totalQuestions",
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
