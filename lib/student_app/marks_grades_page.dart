import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:student_app/student_app/exam_summary_dialog.dart';
import 'package:student_app/student_app/studentdrawer.dart';
import 'package:student_app/student_app/widgets/marks_widgets.dart';
import 'package:student_app/student_app/services/exams_service.dart';
import 'package:student_app/theme_controllers.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class MarksGradesPage extends StatefulWidget {
  final Map<String, dynamic> exam;
  final String examId;

  const MarksGradesPage({super.key, required this.exam, required this.examId});

  @override
  State<MarksGradesPage> createState() => _MarksGradesPageState();
}

class _MarksGradesPageState extends State<MarksGradesPage> {
  @override
  Widget build(BuildContext context) {
    return ThemeControllerWrapper(
      themeController: StudentThemeController.themeMode,
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final textTheme = theme.textTheme;
          final isDark = theme.brightness == Brightness.dark;

          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            drawer: const StudentDrawerPage(),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, textTheme, isDark),
                    const SizedBox(height: 24),
                    _buildSummaryCards(context),
                    const SizedBox(height: 24),
                    _buildPerformanceTrend(context, theme, isDark),
                    const SizedBox(height: 24),
                    _buildSubjectPerformance(context, theme, isDark),
                    const SizedBox(height: 24),
                    _buildExamHistory(context, theme, isDark),
                    const SizedBox(height: 24),
                    _buildAchievements(context, theme, isDark),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, TextTheme textTheme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Marks & Grades",
                      style: textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "Academic Performance Overview - 2024 Batch",
                  style: textTheme.bodyMedium?.copyWith(
                    color: textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.print_outlined, size: 18),
              label: const Text("Print Report"),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                side: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () async {
                try {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Preparing report...")),
                  );

                  final data = await ExamsService.downloadExamReport(
                    widget.examId,
                  );

                  final directory = await getTemporaryDirectory();
                  final filePath =
                      '${directory.path}/exam_report_${widget.examId}.pdf';
                  final file = File(filePath);
                  await file.writeAsBytes(data);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Report ready: exam_report_${widget.examId}.pdf",
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
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Download failed: $e"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.file_download_outlined, size: 18),
              label: const Text("Download Report"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCards(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: const [
            MarksStatCard(
              title: "Overall Percentage",
              value: "-5.00 %",
              description: "No change from previous term",
              valueColor: Color(0xFFEF4444),
            ),
            MarksStatCard(
              title: "Current Grade",
              value: "D",
              description: "Needs Improvement",
              valueColor: Color(0xFF10B981),
            ),
            MarksStatCard(
              title: "Class Rank",
              value: "2/2",
              description: "Top 100% of the class",
              valueColor: Color(0xFF8B5CF6),
            ),
            MarksStatCard(
              title: "Attendance in Exams",
              value: "100 %",
              description: "Perfect attendance record",
              valueColor: Color(0xFF0EA5E9),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAchievements(
    BuildContext context,
    ThemeData theme,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Achievements",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 24),
          Column(
            children: const [
              AchievementCard(
                title: "Top 5 Rank",
                description: "Consistently in top 5 positions",
                icon: Icons.star,
                iconColor: Color(0xFFF1C40F),
                backgroundColor: Color(0xFFEEF6FF),
              ),
              SizedBox(height: 16),
              AchievementCard(
                title: "Perfect Attendance",
                description: "100% exam attendance record",
                icon: Icons.trending_down,
                iconColor: Color(0xFF10B981),
                backgroundColor: Color(0xFFF0FDF4),
              ),
              SizedBox(height: 16),
              AchievementCard(
                title: "Subject Topper",
                description: "Chemistry & Computer Science",
                icon: Icons.star,
                iconColor: Color(0xFFF39C12),
                backgroundColor: Color(0xFFFFF7ED),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceTrend(
    BuildContext context,
    ThemeData theme,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Performance Trend",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.dividerColor),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Text(
                      "Monthly",
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 16,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          AspectRatio(
            aspectRatio: 1.5,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: theme.dividerColor.withValues(alpha: 0.2),
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            "Jan",
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color,
                            ),
                          ),
                        );
                      },
                      reservedSize: 32,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        );
                      },
                      reservedSize: 40,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineTouchData: const LineTouchData(enabled: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: [const FlSpot(0, -20)],
                    isCurved: true,
                    color: const Color(0xFF2563EB),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildSimpleStatCard(
                "Best Performance",
                "PHYSICS",
                Icons.star,
                const Color(0xFFF1C40F),
                theme,
              ),
              const SizedBox(width: 16),
              _buildSimpleStatCard(
                "Need Improvement",
                "PHYSICS",
                Icons.trending_down,
                const Color(0xFFEF4444),
                theme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleStatCard(
    String title,
    String subject,
    IconData icon,
    Color color,
    ThemeData theme,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  subject,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: themeColor(subject, theme),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color themeColor(String subject, ThemeData theme) {
    if (subject == "PHYSICS") return const Color(0xFF2563EB);
    return theme.textTheme.bodyLarge?.color ?? Colors.black87;
  }

  Widget _buildSubjectPerformance(
    BuildContext context,
    ThemeData theme,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Subject-wise Performance",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              Column(
                children: [
                  _buildTableButton(Icons.tune, "Filter", theme),
                  const SizedBox(height: 20),
                  _buildTableButton(
                    Icons.file_download_outlined,
                    "Export",
                    theme,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF2563EB).withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.info, color: Color(0xFF2563EB), size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "You can improve your performance. Focus on weaker subjects.",
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? Colors.blue.shade300
                          : const Color(0xFF2563EB),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Scrollbar(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: 800,
                child: _buildSubjectTable(theme, isDark),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableButton(IconData icon, String label, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: theme.textTheme.bodySmall?.color),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectTable(ThemeData theme, bool isDark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.3,
            ),
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: 0.1),
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: const [
              HeaderCell(title: "Subject", flex: 3),
              HeaderCell(title: "Marks Obtained", flex: 2, centered: true),
              HeaderCell(title: "Percentage", flex: 4, centered: true),
              HeaderCell(title: "Status", flex: 2, centered: true),
              HeaderCell(title: "Class Rank", flex: 2, centered: true),
              HeaderCell(title: "Actions", flex: 2, alignRight: true),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SubjectRow(
          subject: "PHYSICS",
          marks: "-1/5",
          percentage: -20,
          grade: "Average",
          gradeColor: const Color(0xFFF39C12),
        ),
      ],
    );
  }

  Widget _buildExamHistory(BuildContext context, ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Exam History",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 24),
          Scrollbar(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: 800,
                child: _buildExamHistoryTable(theme, isDark),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExamHistoryTable(ThemeData theme, bool isDark) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.3,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: const [
              HeaderCell(title: "Exam Name", flex: 4),
              HeaderCell(title: "Marks", flex: 2),
              HeaderCell(title: "Percentage", flex: 2),
              HeaderCell(title: "Grade", flex: 2),
              HeaderCell(title: "Actions", flex: 2, alignRight: true),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Data Rows
        _buildHistoryRow(
          context,
          theme,
          "Mid Term Exam",
          "450/500",
          "90%",
          "A+",
          Colors.green,
        ),
        const SizedBox(height: 8),
        _buildHistoryRow(
          context,
          theme,
          "Quarterly Exam",
          "400/500",
          "80%",
          "A",
          Colors.blue,
        ),
      ],
    );
  }

  Widget _buildHistoryRow(
    BuildContext context,
    ThemeData theme,
    String examName,
    String marks,
    String percentage,
    String grade,
    Color gradeColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        children: [
          _cell(examName, flex: 4, theme: theme),
          _cell(marks, flex: 2, theme: theme),
          _cell(percentage, flex: 2, theme: theme),
          _gradeCell(grade, gradeColor, flex: 2),
          _actionCell(context, flex: 2),
        ],
      ),
    );
  }

  Widget _cell(String text, {required int flex, required ThemeData theme}) {
    return Expanded(
      flex: flex,
      child: Text(text, style: theme.textTheme.bodyMedium),
    );
  }

  Widget _gradeCell(String grade, Color color, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            grade,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _actionCell(BuildContext context, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Align(
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ExamSummaryDialog(examId: widget.examId),
                  ),
                );
              },
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(
                  Icons.remove_red_eye_outlined,
                  color: Colors.blue,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () async {
                try {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Preparing report...")),
                  );

                  final data = await ExamsService.downloadExamReport(
                    widget.examId,
                  );

                  final directory = await getTemporaryDirectory();
                  final filePath =
                      '${directory.path}/exam_report_${widget.examId}.pdf';
                  final file = File(filePath);
                  await file.writeAsBytes(data);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Report ready: exam_report_${widget.examId}.pdf",
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
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Download failed: $e"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(
                  Icons.download_outlined,
                  color: Colors.green,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
