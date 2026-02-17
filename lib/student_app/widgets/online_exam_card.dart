import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:student_app/student_app/model/exam_item.dart';
import 'package:student_app/student_app/exam_writing_page.dart';
import 'package:student_app/student_app/exam_weekend_details.dart';
import 'package:student_app/student_app/online_exam_portal_page.dart';
import 'package:student_app/student_app/widgets/exam_widgets.dart';

class OnlineExamCard extends StatelessWidget {
  final ExamModel exam;
  final VoidCallback onViewResult;

  const OnlineExamCard({
    super.key,
    required this.exam,
    required this.onViewResult,
  });

  bool _isCurrentlyExamTime() {
    try {
      final now = DateTime.now();

      // Parse exam date: yyyy-MM-dd
      final examDate = DateFormat("yyyy-MM-dd").parse(exam.date);

      // Check if it's today
      final bool isToday =
          examDate.year == now.year &&
          examDate.month == now.month &&
          examDate.day == now.day;

      return isToday;
    } catch (e) {
      debugPrint("Error checking exam time: $e");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bool isCompleted = exam.progress == 100;
    final bool isExamTime = _isCurrentlyExamTime();

    String buttonLabel = "View Result";
    IconData buttonIcon = Icons.bar_chart;
    Color buttonColor = theme.colorScheme.primary;
    bool usePrimaryStyle = false;

    // Only show "Start Exam" if it's currently the scheduled time AND not completed
    if (isExamTime && !isCompleted) {
      buttonLabel = "Start Exam";
      buttonIcon = Icons.play_arrow;
      buttonColor = Colors.green;
      usePrimaryStyle = true;
    } else {
      // Otherwise show "View Result" (user requirement)
      buttonLabel = "View Result";
      buttonIcon = Icons.bar_chart;
      buttonColor = theme.colorScheme.primary;
      usePrimaryStyle = false;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Exam Name
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exam.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(exam.board, style: theme.textTheme.bodySmall),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      OnlineBadge(
                        label: "Online",
                        bgColor: theme.colorScheme.primary.withOpacity(0.1),
                        textColor: theme.colorScheme.primary,
                        icon: Icons.computer,
                      ),
                      const SizedBox(width: 6),
                      if (exam.isProctored)
                        OnlineBadge(
                          label: "Proctored",
                          bgColor: Colors.green.withOpacity(0.1),
                          textColor: isDark
                              ? Colors.green.shade300
                              : const Color(0xFF22C55E),
                        ),
                      const SizedBox(width: 6),
                      if (exam.progress == 100)
                        OnlineBadge(
                          label: "Completed",
                          bgColor: Colors.green.withOpacity(0.1),
                          textColor: isDark
                              ? Colors.green.shade300
                              : const Color(0xFF22C55E),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Exam ID: ${exam.id}",
                  style: TextStyle(
                    color: isDark
                        ? Colors.pinkAccent.shade100
                        : const Color(0xFFEC4899),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // 2. Exam Details
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ExamDetailRow(
                  label: "Duration: ",
                  value: exam.duration ?? "N/A",
                ),
                const SizedBox(height: 4),
                ExamDetailRow(
                  label: "Questions: ",
                  value: "${exam.questions ?? 'N/A'}",
                ),
                const SizedBox(height: 4),
                ExamDetailRow(
                  label: "Passing: ",
                  value: exam.passingMarks ?? "N/A",
                ),
              ],
            ),
          ),

          // 3. Schedule
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      exam.date,
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      exam.time,
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "Platform: ${exam.platform ?? 'N/A'}",
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),

          // 4. Requirements
          Expanded(
            flex: 2,
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                if (exam.hasWebcam)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.videocam_outlined,
                          size: 12,
                          color: isDark
                              ? Colors.redAccent.shade100
                              : const Color(0xFFEF4444),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "Webcam",
                          style: TextStyle(
                            color: isDark
                                ? Colors.redAccent.shade100
                                : const Color(0xFFEF4444),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (exam.hasInternet)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      "Internet",
                      style: TextStyle(
                        color: isDark
                            ? Colors.green.shade300
                            : const Color(0xFF22C55E),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // 5. Actions
          Expanded(
            flex: 2,
            child: Column(
              children: [
                if (usePrimaryStyle)
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ExamWritingPage(
                            examId: exam.id,
                            examName: exam.title,
                            subject: exam.subject,
                            duration: exam.duration ?? "N/A",
                            questionsCount: exam.questions ?? 0,
                          ),
                        ),
                      );
                    },
                    icon: Icon(buttonIcon, size: 14),
                    label: Text(buttonLabel),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      minimumSize: const Size(double.infinity, 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  OutlinedButton.icon(
                    onPressed: onViewResult,
                    icon: Icon(buttonIcon, size: 14),
                    label: Text(buttonLabel),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: buttonColor,
                      side: BorderSide(color: buttonColor.withOpacity(0.5)),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      minimumSize: const Size(double.infinity, 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ExamWeekendDetails(examId: '${exam.id}'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.description_outlined, size: 14),
                  label: const Text("Instructions"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.textTheme.bodyLarge?.color,
                    side: BorderSide(color: theme.dividerColor),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    minimumSize: const Size(double.infinity, 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    textStyle: const TextStyle(fontSize: 11),
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
