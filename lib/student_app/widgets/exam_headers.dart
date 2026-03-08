import 'package:flutter/material.dart';

class StandardExamHeader extends StatelessWidget {
  const StandardExamHeader({super.key});

  @override
  Widget build(BuildContext context) {
    const textColor = Color(0xFF1E293B);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 250,
            child: Text(
              "Exam Name",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: textColor,
              ),
            ),
          ),
          SizedBox(width: 12),
          SizedBox(
            width: 180,
            child: Text(
              "Date & Time",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: textColor,
              ),
            ),
          ),
          SizedBox(width: 12),
          SizedBox(
            width: 180,
            child: Text(
              "Preparation",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: textColor,
              ),
            ),
          ),
          SizedBox(width: 12),
          SizedBox(
            width: 150,
            child: Text(
              "Status",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: textColor,
              ),
            ),
          ),
          SizedBox(width: 12),
          SizedBox(
            width: 90,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                "Action",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: textColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CompletedExamHeader extends StatelessWidget {
  const CompletedExamHeader({super.key});

  @override
  Widget build(BuildContext context) {
    const textColor = Color(0xFF1E293B);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 250,
            child: Text(
              "Exam Name",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: textColor,
              ),
            ),
          ),
          SizedBox(width: 12),
          SizedBox(
            width: 150,
            child: Text(
              "Result Info",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: textColor,
              ),
            ),
          ),
          SizedBox(width: 12),
          SizedBox(
            width: 180,
            child: Text(
              "Academic Stats",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: textColor,
              ),
            ),
          ),
          SizedBox(width: 12),
          SizedBox(
            width: 120,
            child: Text(
              "Performance",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: textColor,
              ),
            ),
          ),
          SizedBox(width: 12),
          SizedBox(
            width: 300,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Actions",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: textColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnlineExamHeader extends StatelessWidget {
  const OnlineExamHeader({super.key});

  @override
  Widget build(BuildContext context) {
    const textColor = Color(0xFF1E293B);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 250,
            child: Text(
              "Exam Name",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: textColor,
              ),
            ),
          ),
          SizedBox(width: 12),
          SizedBox(
            width: 180,
            child: Text(
              "Exam Details",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: textColor,
              ),
            ),
          ),
          SizedBox(width: 8),
          SizedBox(
            width: 100,
            child: Text(
              "Schedule",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: textColor,
              ),
            ),
          ),
          SizedBox(width: 8),
          SizedBox(
            width: 220,
            child: Text(
              "Requirements",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: textColor,
              ),
            ),
          ),
          SizedBox(width: 8),
          SizedBox(
            width: 200,
            child: Text(
              "Actions",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnlineExamBanner extends StatelessWidget {
  const OnlineExamBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.primary.withOpacity(0.1)
            : const Color(0xFFE0F2FE),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark
              ? theme.colorScheme.primary.withOpacity(0.3)
              : const Color(0xFFBAE6FD),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info,
            color: isDark ? theme.colorScheme.primary : const Color(0xFF0EA5E9),
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Online Exam Information",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0C4A6E),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Take online exams from anywhere with internet connection. Ensure you have webcam and microphone enabled.",
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 14,
                    color: isDark
                        ? theme.textTheme.bodySmall?.color
                        : Colors.blue.shade900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
