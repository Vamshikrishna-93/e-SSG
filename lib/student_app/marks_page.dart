import 'package:flutter/material.dart';
import 'package:student_app/student_app/studentdrawer.dart';
import 'package:student_app/student_app/widgets/marks_widgets.dart';
import 'package:student_app/theme_controllers.dart';

class MarksPage extends StatefulWidget {
  const MarksPage({super.key});

  @override
  State<MarksPage> createState() => _MarksPageState();
}

class _MarksPageState extends State<MarksPage> {
  String selectedSemester = "All Semesters";
  String selectedPeriod = "Monthly";

  @override
  Widget build(BuildContext context) {
    return ThemeControllerWrapper(
      themeController: StudentThemeController.themeMode,
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            drawer: const StudentDrawerPage(),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
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
                                    "Marks",
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700,
                                      color: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge?.color,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Padding(
                                padding: const EdgeInsets.only(left: 36),
                                child: Text(
                                  "Academic Performance Overview - 2024 Batch",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            OutlinedButton.icon(
                              onPressed: () {
                                // Print Report
                              },
                              icon: Icon(
                                Icons.print,
                                size: 18,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.color,
                              ),
                              label: Text(
                                "Print Report",
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.color,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey.shade700
                                      : Colors.grey.shade300,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              onPressed: () {
                                // Download All
                              },
                              icon: const Icon(Icons.download, size: 18),
                              label: const Text(
                                "Download All",
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Stats Cards
                    MarksStatCard(
                      title: "Overall Percentage",
                      value: "83.40 %",
                      valueColor: const Color(0xFF2563EB),
                      description: 'Consistent Improvement',
                    ),
                    const SizedBox(height: 24),
                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.stretch, // 🔑 important
                      children: [
                        MarksStatCard(
                          title: "Current Grade",
                          value: "A",
                          valueColor: Colors.green,
                          description: "Excellent Performance",
                        ),
                        const SizedBox(height: 24),
                        MarksStatCard(
                          title: "Class Rank",
                          value: "4/85",
                          valueColor: Colors.purple,
                          description: "Top 5% of the class",
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Attendance in Exams Card
                    Container(
                      width: double.infinity, // 🔑 forces full screen width
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.black.withValues(alpha: 0.3)
                                : Colors.black.withValues(alpha: 0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Attendance in Exams",
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "100 %",
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF14B8A6),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Perfect attendance record",
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Filters Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.black.withValues(alpha: 0.3)
                                : Colors.black.withValues(alpha: 0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Semester Dropdown
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade300,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  selectedSemester,
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.color,
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_drop_down,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.color,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Date Range
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.grey.shade700
                                          : Colors.grey.shade300,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Start date",
                                        style: TextStyle(
                                          color:
                                              Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.grey.shade400
                                              : Colors.grey.shade600,
                                        ),
                                      ),
                                      Icon(
                                        Icons.calendar_today,
                                        size: 18,
                                        color:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.grey.shade400
                                            : Colors.grey.shade600,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward,
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.grey.shade700
                                          : Colors.grey.shade300,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "End date",
                                        style: TextStyle(
                                          color:
                                              Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.grey.shade400
                                              : Colors.grey.shade600,
                                        ),
                                      ),
                                      Icon(
                                        Icons.calendar_today,
                                        size: 18,
                                        color:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.grey.shade400
                                            : Colors.grey.shade600,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Search Field
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade300,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "Search subjects...",
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.grey.shade400
                                          : Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.search,
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Performance Trend Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.black.withValues(alpha: 0.3)
                                : Colors.black.withValues(alpha: 0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Performance Trend",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.color,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.grey.shade700
                                        : Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      selectedPeriod,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(
                                          context,
                                        ).textTheme.bodyLarge?.color,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.arrow_drop_down,
                                      size: 18,
                                      color: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge?.color,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 200,
                            child: const PerformanceTrendChart(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Grade Distribution Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.black.withValues(alpha: 0.3)
                                : Colors.black.withValues(alpha: 0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Grade Distribution",
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 20),
                          const SizedBox(
                            height: 220,
                            child: const GradeDistributionChart(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Subject-wise Performance Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.black.withValues(alpha: 0.3)
                                : Colors.black.withValues(alpha: 0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// HEADER (FIXED)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  "Subject-wise Performance",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(
                                      Icons.filter_list,
                                      size: 14,
                                    ),
                                    label: const Text("Filter"),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(Icons.download, size: 16),
                                    label: const Text("Export"),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          /// PERFORMANCE BANNER (SAFE)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.green.shade50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    "Your overall performance is Excellent! Keep up the good work.",
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.green.shade200
                                          : Colors.green.shade900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          /// TABLE HEADER (FIXED)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 8,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey.shade800.withValues(alpha: 0.5)
                                  : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: const [
                                HeaderCell(title: "Subject", flex: 3),
                                HeaderCell(
                                  title: "Marks",
                                  flex: 2,
                                  centered: true,
                                ),
                                HeaderCell(
                                  title: "Percentage",
                                  flex: 3,
                                  centered: true,
                                ),
                                HeaderCell(
                                  title: "Grade",
                                  flex: 2,
                                  alignRight: true,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          SubjectRow(
                            subject: "Mathematics",
                            marks: "85/100",
                            percentage: 85,
                            grade: "A",
                            gradeColor: Colors.blue,
                          ),
                          const SizedBox(height: 12),
                          SubjectRow(
                            subject: "Physics",
                            marks: "78/100",
                            percentage: 78,
                            grade: "B+",
                            gradeColor: Colors.orange,
                          ),
                          const SizedBox(height: 12),
                          SubjectRow(
                            subject: "Chemistry",
                            marks: "92/100",
                            percentage: 92,
                            grade: "A+",
                            gradeColor: Colors.green,
                            isExcellent: true,
                          ),
                          const SizedBox(height: 12),
                          SubjectRow(
                            subject: "English",
                            marks: "72/100",
                            percentage: 72,
                            grade: "B",
                            gradeColor: Colors.orange,
                          ),
                          const SizedBox(height: 12),
                          SubjectRow(
                            subject: "Computer Science",
                            marks: "88/100",
                            percentage: 88,
                            grade: "A",
                            gradeColor: Colors.blue,
                          ),
                          const SizedBox(height: 12),
                          SubjectRow(
                            subject: "Biology",
                            marks: "68/100",
                            percentage: 68,
                            grade: "C+",
                            gradeColor: Colors.red,
                          ),
                          const SizedBox(height: 12),
                          SubjectRow(
                            subject: "Social Studies",
                            marks: "81/100",
                            percentage: 81,
                            grade: "A-",
                            gradeColor: Colors.red,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Exam History Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.black.withValues(alpha: 0.3)
                                : Colors.black.withValues(alpha: 0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Exam History",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.color,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.grey.shade700
                                        : Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Text(
                                      "All Exams",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.arrow_drop_down,
                                      size: 18,
                                      color: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge?.color,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Best Performance & Need Improvement
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.green.withOpacity(0.1)
                                        : Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "Best Performance: Chemistry - 92% (Rank 1)",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.green.shade200
                                          : Colors.green.shade900,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "Need Improvement: Biology - 68% (Rank 9)",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.orange.shade900,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Exam History Table
                          ExamHistoryRow(
                            examName: "Mid Term - Mar 2024",
                            marks: "580/650",
                            percentage: "89.23%",
                            grade: "A+",
                            rank: "Rank: 3",
                            gradeColor: Colors.green,
                            rankColor: Colors.green,
                          ),
                          const SizedBox(height: 12),
                          ExamHistoryRow(
                            examName: "Unit Test - Feb 2024",
                            marks: "168/200",
                            percentage: "84%",
                            grade: "A",
                            rank: "Rank: 5",
                            gradeColor: Colors.blue,
                            rankColor: Colors.blue,
                          ),
                          const SizedBox(height: 12),
                          ExamHistoryRow(
                            examName: "Final Term - Dec 2023",
                            marks: "610/700",
                            percentage: "87.14%",
                            grade: "A",
                            rank: "Rank: 4",
                            gradeColor: Colors.blue,
                            rankColor: Colors.blue,
                          ),
                          const SizedBox(height: 12),
                          ExamHistoryRow(
                            examName: "Quarterly - Oct 2023",
                            marks: "425/500",
                            percentage: "85%",
                            grade: "A",
                            rank: "Rank: 6",
                            gradeColor: Colors.blue,
                            rankColor: Colors.blue,
                          ),
                          const SizedBox(height: 12),
                          ExamHistoryRow(
                            examName: "Pre Board - Sep 2023",
                            marks: "510/600",
                            percentage: "85%",
                            grade: "A",
                            rank: "Rank: 7",
                            gradeColor: Colors.blue,
                            rankColor: Colors.blue,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Achievements Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.black.withValues(alpha: 0.3)
                                : Colors.black.withValues(alpha: 0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Achievements",
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),

                          const SizedBox(height: 24),

                          AchievementCard(
                            icon: Icons.star,
                            iconColor: Colors.amber,
                            title: "Top 5 Rank",
                            description: "Consistently in top 5 positions",
                            backgroundColor: Colors.blue.shade50,
                          ),

                          const SizedBox(height: 20),

                          AchievementCard(
                            icon: Icons.trending_up,
                            iconColor: Colors.green,
                            title: "Perfect Attendance",
                            description: "100% exam attendance record",
                            backgroundColor: Colors.green.shade50,
                          ),

                          const SizedBox(height: 20),

                          AchievementCard(
                            icon: Icons.star,
                            iconColor: Colors.orange,
                            title: "Subject Topper",
                            description: "Chemistry & Computer Science",
                            backgroundColor: Colors.orange.shade50,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
