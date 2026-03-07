import 'package:flutter/material.dart';
import 'package:student_app/student_app/model/exam_item.dart';
import 'package:student_app/student_app/marks_grades_page.dart';
import 'package:student_app/student_app/services/exams_service.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class CompletedExamCard extends StatelessWidget {
  final ExamModel exam;
  final VoidCallback onViewScoreCard;

  const CompletedExamCard({
    super.key,
    required this.exam,
    required this.onViewScoreCard,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF007BFF);
    const textColor = Color(0xFF1E293B);
    const secondaryTextColor = Color(0xFF64748B);
    const dividerColor = Color(0xFFE2E8F0);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: dividerColor)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width - 16,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Exam Name column (Title, Board, ID)
              SizedBox(
                width: 150,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exam.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${exam.board} • Online",
                      style: const TextStyle(
                        fontSize: 11,
                        color: secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Exam ID in pink
                    Text(
                      "Exam ID: ${exam.id}",
                      style: const TextStyle(
                        color: Color(0xFFF06292), // Pink 300 equivalent
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // 2. Marks
              SizedBox(
                width: 60,
                child: Text(
                  exam.marks ?? "-",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: textColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // 3. Percentage
              SizedBox(
                width: 80,
                child: Text(
                  exam.percentage ?? "-",
                  style: const TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // 4. Grade & Rank
              SizedBox(
                width: 150,
                child: Row(
                  children: [
                    // Grade Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        exam.grade ?? "-",
                        style: const TextStyle(
                          color: Color(0xFFB45309), // Amber 800 equivalent
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Rank Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.cyan.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        "Rank: ${exam.rank ?? 'N/A'}",
                        style: const TextStyle(
                          color: Color(0xFF155E75), // Cyan 800 equivalent
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // 5. Performance
              SizedBox(
                width: 90,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      exam.performance ?? "Good",
                      style: const TextStyle(
                        color: Color(0xFF9A3412), // Orange 800 equivalent
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // 6. Actions
              SizedBox(
                width: 280,
                child: Row(
                  children: [
                    // Marks
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MarksGradesPage(examId: exam.id, exam: {}),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: dividerColor),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.bar_chart,
                                size: 14,
                                color: textColor,
                              ),
                              SizedBox(width: 4),
                              Text(
                                "Marks",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Score Card (Color Button)
                    Expanded(
                      child: InkWell(
                        onTap: onViewScoreCard,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            "Score Card",
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Download
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          try {
                            // Show loading indicator
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Preparing report..."),
                              ),
                            );

                            final data = await ExamsService.downloadExamReport(
                              exam.id,
                            );

                            // Get directory to save file
                            final directory = await getTemporaryDirectory();
                            final filePath =
                                '${directory.path}/exam_report_${exam.id}.pdf';
                            final file = File(filePath);

                            // Write bytes to file
                            await file.writeAsBytes(data);

                            if (context.mounted) {
                              ScaffoldMessenger.of(
                                context,
                              ).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Report ready: exam_report_${exam.id}.pdf (${(data.length / 1024).toStringAsFixed(2)} KB)",
                                  ),
                                  action: SnackBarAction(
                                    label: "Open",
                                    textColor: Colors.white,
                                    onPressed: () {
                                      OpenFilex.open(filePath);
                                    },
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(
                                context,
                              ).hideCurrentSnackBar();
                              String errorMsg = e.toString();
                              if (errorMsg.contains('MissingPluginException') ||
                                  errorMsg.contains('Unsupported operation')) {
                                errorMsg =
                                    "App restart required to activate download plugin. Please stop and re-run the app.";
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Download failed: $errorMsg"),
                                  backgroundColor: Colors.red,
                                  duration: const Duration(seconds: 5),
                                ),
                              );
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: dividerColor),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.download,
                                size: 14,
                                color: textColor,
                              ),
                              SizedBox(width: 4),
                              Text(
                                "Download",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
