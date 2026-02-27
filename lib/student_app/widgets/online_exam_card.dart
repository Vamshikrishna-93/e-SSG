import 'package:flutter/material.dart';
import 'package:student_app/student_app/exam_portal_writing_page.dart';
import 'package:student_app/student_app/exam_writing_page.dart';
import 'package:student_app/student_app/model/exam_item.dart';
import 'package:student_app/student_app/services/exams_service.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:student_app/student_app/widgets/exam_widgets.dart';

class OnlineExamCard extends StatefulWidget {
  final ExamModel exam;
  final VoidCallback onViewResult;

  const OnlineExamCard({
    super.key,
    required this.exam,
    required this.onViewResult,
  });

  @override
  State<OnlineExamCard> createState() => _OnlineExamCardState();
}

class _OnlineExamCardState extends State<OnlineExamCard> {
  bool _isDownloading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bool isCompleted = widget.exam.progress == 100;

    // TODO: For production, change `true` to `_isExamToday()` below
    // so "Start Exam" only shows on the exam day.
    // For now, always show "Start Exam" for non-completed exams (for testing).
    final bool showStartExam =
        !isCompleted &&
        true; // Change `true` to `_isExamToday()` for production

    String buttonLabel;
    IconData buttonIcon;
    Color buttonColor;
    bool usePrimaryStyle;

    if (isCompleted) {
      // Exam done → View Result
      buttonLabel = "View Result";
      buttonIcon = Icons.bar_chart;
      buttonColor = theme.colorScheme.primary;
      usePrimaryStyle = false;
    } else if (showStartExam) {
      // Exam today & not completed → Start Exam
      buttonLabel = "Start Exam";
      buttonIcon = Icons.play_arrow;
      buttonColor = Colors.green;
      usePrimaryStyle = true;
    } else {
      // No exam today → View Result
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
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.exam.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(widget.exam.board, style: theme.textTheme.bodySmall),
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
                      if (widget.exam.isProctored)
                        OnlineBadge(
                          label: "Proctored",
                          bgColor: Colors.green.withOpacity(0.1),
                          textColor: isDark
                              ? Colors.green.shade300
                              : const Color(0xFF22C55E),
                        ),
                      const SizedBox(width: 6),
                      if (isCompleted)
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
                  "Exam ID: ${widget.exam.id}",
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
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ExamDetailRow(
                  label: "Duration: ",
                  value: widget.exam.duration ?? "N/A",
                ),
                const SizedBox(height: 4),
                ExamDetailRow(
                  label: "Questions: ",
                  value: "${widget.exam.questions ?? 'N/A'}",
                ),
                const SizedBox(height: 4),
                ExamDetailRow(
                  label: "Passing: ",
                  value: widget.exam.passingMarks ?? "N/A",
                ),
              ],
            ),
          ),
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
                      widget.exam.date,
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
                      widget.exam.time,
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "Platform: ${widget.exam.platform ?? 'Online Portal'}",
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
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
                          builder: (_) =>
                              ExamPortalWritingPage(exam: widget.exam),
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
                  Column(
                    children: [
                      OutlinedButton.icon(
                        onPressed: widget.onViewResult,
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
                      // Added Download Report Button for completed exams
                      OutlinedButton.icon(
                        onPressed: _isDownloading
                            ? null
                            : () async {
                                try {
                                  setState(() {
                                    _isDownloading = true;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Preparing report..."),
                                    ),
                                  );

                                  final data =
                                      await ExamsService.downloadExamReport(
                                        widget.exam.id,
                                      );

                                  final directory =
                                      await getTemporaryDirectory();
                                  final filePath =
                                      '${directory.path}/exam_report_${widget.exam.id}.pdf';
                                  final file = File(filePath);
                                  await file.writeAsBytes(data);

                                  if (mounted) {
                                    setState(() {
                                      _isDownloading = false;
                                    });
                                    ScaffoldMessenger.of(
                                      context,
                                    ).hideCurrentSnackBar();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Report ready: exam_report_${widget.exam.id}.pdf",
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
                                  if (mounted) {
                                    setState(() {
                                      _isDownloading = false;
                                    });
                                    ScaffoldMessenger.of(
                                      context,
                                    ).hideCurrentSnackBar();
                                    String errorMsg = e.toString();
                                    if (errorMsg.contains(
                                          'MissingPluginException',
                                        ) ||
                                        errorMsg.contains(
                                          'Unsupported operation',
                                        )) {
                                      errorMsg =
                                          "App restart required to activate download plugin. Please stop and re-run the app.";
                                    }
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Download failed: $errorMsg",
                                        ),
                                        backgroundColor: Colors.red,
                                        duration: const Duration(seconds: 5),
                                      ),
                                    );
                                  }
                                }
                              },
                        icon: _isDownloading
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.green,
                                  ),
                                ),
                              )
                            : const Icon(Icons.download, size: 14),
                        label: Text(
                          _isDownloading ? "Downloading..." : "Download",
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.green,
                          side: BorderSide(
                            color: Colors.green.withOpacity(0.5),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
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
                      // Added Start Exam button below Download as requested
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ExamWritingPage(
                                exam: widget.exam,
                                examId: '',
                                examName: '',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.play_arrow, size: 14),
                        label: const Text("Start Exam"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
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
                      ),
                    ],
                  ),
                const SizedBox(height: 8),
                // Commented out Details button as requested
                /*
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ExamWeekendDetails(examId: widget.exam.id),
                      ),
                    );
                  },
                  icon: const Icon(Icons.description_outlined, size: 14),
                  label: const Text("Details"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.textTheme.bodyLarge?.color,
                    side: BorderSide(color: theme.dividerColor),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    minimumSize: const Size(double.infinity, 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    textStyle: const TextStyle(fontSize: 11),
                  ),
                ),
                */
              ],
            ),
          ),
        ],
      ),
    );
  }
}
