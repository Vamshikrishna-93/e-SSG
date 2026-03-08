import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:student_app/student_app/exam_summary_dialog.dart';
import 'package:student_app/student_app/model/exam_item.dart';
import 'package:student_app/student_app/widgets/student_bottom_nav.dart';
import 'package:student_app/student_app/services/exams_service.dart';
import 'package:student_app/student_app/student_calendar.dart';
import 'package:student_app/student_app/studentdrawer.dart';
import 'package:student_app/student_app/widgets/stat_card.dart';
import 'package:student_app/student_app/widgets/exam_tab_item.dart';
import 'package:student_app/student_app/widgets/standard_exam_card.dart';
import 'package:student_app/student_app/widgets/completed_exam_card.dart';
import 'package:student_app/student_app/widgets/exam_headers.dart';
import 'package:student_app/student_app/widgets/loading_animation.dart';
import 'package:student_app/student_app/widgets/online_exam_card.dart';
import 'package:student_app/student_app/exam_details_dialog_page.dart';

class ExamsPage extends StatefulWidget {
  const ExamsPage({super.key});

  @override
  State<ExamsPage> createState() => _ExamsPageState();
}

class _ExamsPageState extends State<ExamsPage> {
  // State for filtering
  int _selectedTabIndex = 0; // 0: Upcoming, 1: Completed, 2: Online, 3: Offline
  String _searchQuery = "";
  String _selectedSubject = "All Subjects";
  final List<String> _subjects = ["All Subjects"];

  // Data lists
  List<ExamModel> _currentTabExams = [];
  bool _isLoading = true;
  Timer? _refreshTimer;

  // Pagination
  int _currentPage = 1;
  final int _itemsPerPage = 5;

  // Stats
  int _upcomingCount = 0;
  int _completedCount = 0;
  String _studentFullName = "";
  String _admno = "";
  int _totalExamsCount = 0;
  String _courseName = "";
  double _averageScore = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchExams();
    // Refresh data every 3 minutes
    _refreshTimer = Timer.periodic(const Duration(minutes: 3), (_) {
      _fetchExams();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchExams() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch online exams from API
      final response = await ExamsService.getOnlineExams();

      if (mounted) {
        setState(() {
          // Parse API response
          List<dynamic> apiExams = [];

          if (response['data'] != null && response['data'] is List) {
            apiExams = response['data'];
          } else if (response['exams'] != null && response['exams'] is List) {
            apiExams = response['exams'];
          }

          _studentFullName = response['student_full_name'] ?? "";
          _admno = response['admno']?.toString() ?? "";
          _totalExamsCount =
              int.tryParse(response['total_exams']?.toString() ?? '0') ?? 0;
          _courseName = response['course_name'] ?? "";

          // Convert API data to ExamModel and categorize
          List<ExamModel> onlineExamsList = [
            const ExamModel(
              title: "weekend Exam Testing",
              board: "SSJC-VRB CAMPUS",
              date: "2026-02-17",
              time: "17:00:00",
              progress: 100,
              type: "Online",
              id: "699",
              subject: "General",
              color: Colors.blue,
              duration: "N/A",
              questions: 2,
              passingMarks: "10.00",
              platform: "Online Portal",
            ),
          ];
          List<ExamModel> upcomingExamsList = [];
          List<ExamModel> completedExamsList = [];
          List<ExamModel> offlineExamsList = [];

          for (var examData in apiExams) {
            final exam = ExamModel.fromJson(examData);

            // Skip IPR test data
            if (exam.title.toUpperCase().contains('IPR')) {
              continue;
            }

            // Categorize based on status and type
            final isCompleted =
                exam.progress == 100 ||
                examData['status']?.toString().toLowerCase() == 'completed' ||
                examData['is_completed'] == true;

            if (exam.type == 'Offline') {
              offlineExamsList.add(exam);
            } else {
              onlineExamsList.add(exam);
            }

            if (isCompleted) {
              completedExamsList.add(exam);
            } else {
              upcomingExamsList.add(exam);
            }
          }

          // Update the static lists in ExamModel
          ExamModel.onlineExams.clear();
          ExamModel.onlineExams.addAll(onlineExamsList);

          ExamModel.upcomingExams.clear();
          ExamModel.upcomingExams.addAll(upcomingExamsList);

          ExamModel.completedExams.clear();
          ExamModel.completedExams.addAll(completedExamsList);

          ExamModel.offlineExams.clear();
          ExamModel.offlineExams.addAll(offlineExamsList);

          // Update counts
          _upcomingCount = ExamModel.upcomingExams.length;
          _completedCount = ExamModel.completedExams.length;

          // Calculate average score and performance
          double totalPercentage = 0;
          int scoredExamsCount = 0;
          for (var exam in ExamModel.completedExams) {
            if (exam.percentage != null) {
              final cleanPercent = exam.percentage!.replaceAll('%', '').trim();
              final p = double.tryParse(cleanPercent);
              if (p != null) {
                totalPercentage += p;
                scoredExamsCount++;
              }
            }
          }

          _averageScore = scoredExamsCount > 0
              ? totalPercentage / scoredExamsCount
              : 0.0;

          if (_averageScore >= 90) {
          } else if (_averageScore >= 75) {
          } else if (_averageScore >= 60) {
          } else if (_averageScore > 0) {
          } else {}

          // Populate subjects
          final uniqueSubjects = [
            ...onlineExamsList,
            ...offlineExamsList,
          ].map((e) => e.subject).toSet();
          _subjects.clear();
          _subjects.add("All Subjects");
          _subjects.addAll(uniqueSubjects);

          _updateCurrentTabExams();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          // Fallback to static data if API fails
          _upcomingCount = ExamModel.upcomingExams.length;
          _completedCount = ExamModel.completedExams.length;

          final uniqueSubjects = ExamModel.upcomingExams
              .map((e) => e.subject)
              .toSet();
          _subjects.clear();
          _subjects.add("All Subjects");
          _subjects.addAll(uniqueSubjects);

          _updateCurrentTabExams();
          _isLoading = false;
        });

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load exams: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _updateCurrentTabExams() {
    // Select the source list based on tab
    List<ExamModel> source;
    switch (_selectedTabIndex) {
      case 0:
        source = ExamModel.upcomingExams;
        break;
      case 1:
        source = ExamModel.completedExams;
        break;
      case 2:
        source = ExamModel.onlineExams;
        break;
      case 3:
        source = ExamModel.offlineExams;
        break;
      default:
        source = [];
    }

    setState(() {
      _currentTabExams = source;
      _currentPage = 1; // Reset to page 1 on tab switch
    });
  }

  List<ExamModel> _getFilteredAndPagedExams() {
    // Safety check
    if (_currentTabExams.isEmpty) return [];

    // 1. Filter
    List<ExamModel> filtered = _currentTabExams.where((exam) {
      // Subject Filter
      if (_selectedSubject != "All Subjects" &&
          exam.subject != _selectedSubject) {
        return false;
      }
      // Search Filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return exam.title.toLowerCase().contains(query) ||
            exam.board.toLowerCase().contains(query);
      }
      return true;
    }).toList();

    // 2. Paginate
    final totalItems = filtered.length;
    if (totalItems == 0) return [];

    if (_selectedTabIndex == 2) {
      // Return all filtered online exams instead of just one
      return filtered;
    }

    int startIndex = (_currentPage - 1) * _itemsPerPage;
    if (startIndex >= totalItems) {
      // If start index is out of bounds (e.g. after filtering), reset or show empty
      return [];
    }

    int endIndex = min(startIndex + _itemsPerPage, totalItems);

    return filtered.sublist(startIndex, endIndex);
  }

  int _getTotalPages() {
    if (_currentTabExams.isEmpty) return 1;

    // Calculate total pages for current filtered list
    List<ExamModel> filtered = _currentTabExams.where((exam) {
      if (_selectedSubject != "All Subjects" &&
          exam.subject != _selectedSubject) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return exam.title.toLowerCase().contains(query) ||
            exam.board.toLowerCase().contains(query);
      }
      return true;
    }).toList();

    if (filtered.isEmpty) return 1;

    return (filtered.length / _itemsPerPage).ceil();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF8B5CF6);
    const lightPurple = Color(0xFFC084FC);
    const textColor = Color(0xFF1E293B);
    const secondaryTextColor = Color(0xFF64748B);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          decoration: const BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Scaffold.of(context).openDrawer(),
                    child: const Icon(
                      Icons.assignment_outlined,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Exams",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      drawer: const StudentDrawerPage(),
      bottomNavigationBar: const StudentBottomNav(currentIndex: 2),
      body: _isLoading
          ? const Center(child: StudentLoadingAnimation())
          : RefreshIndicator(
              onRefresh: _fetchExams,
              color: primaryColor,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Header
                    const Text(
                      "Exam",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Manage your exams and view results",
                      style: TextStyle(fontSize: 14, color: secondaryTextColor),
                    ),
                    const SizedBox(height: 12),
                    // Student Info Row
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildInfoItem(
                            Icons.person_outline,
                            _studentFullName,
                            const Color(0xFF3B82F6),
                          ),
                          const SizedBox(width: 16),
                          _buildInfoItem(
                            Icons.badge_outlined,
                            "ADM: $_admno",
                            const Color(0xFF3B82F6),
                          ),
                          const SizedBox(width: 16),
                          _buildInfoItem(
                            Icons.school_outlined,
                            _courseName,
                            const Color(0xFF3B82F6),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Open Calendar Button
                    SizedBox(
                      height: 44,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const StudentCalendar(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.calendar_month, size: 18),
                        label: const Text("Open Calender"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: lightPurple,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Stats Cards
                    StatCard(
                      title: "Upcoming Exams",
                      value: "$_upcomingCount",
                      subtext: "Total assigned: $_totalExamsCount",
                      icon: Icons.calendar_today,
                      iconColor: const Color(0xFF3B82F6),
                    ),
                    const SizedBox(height: 16),
                    StatCard(
                      title: "Completed",
                      value: "$_completedCount",
                      subtext: "Based on your Submissions",
                      icon: Icons.emoji_events_outlined,
                      iconColor: const Color(0xFF22C55E),
                    ),
                    const SizedBox(height: 16),
                    StatCard(
                      title: "Class Rank",
                      value: "1/85",
                      subtext: "Top 10 of the class",
                      icon: Icons.star_outline,
                      iconColor: const Color(0xFFA855F7),
                    ),
                    const SizedBox(height: 16),
                    StatCard(
                      title: "Study Hours",
                      value: "32 hrs",
                      subtext: "Recommended for upcoming exams",
                      icon: Icons.access_time,
                      iconColor: const Color(0xFF14B8A6),
                    ),

                    const SizedBox(height: 32),

                    // Tab Row
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ExamTabItem(
                            index: 0,
                            label: "Upcoming Exams",
                            count: _upcomingCount,
                            icon: Icons.calendar_today_outlined,
                            isSelected: _selectedTabIndex == 0,
                            onTap: () {
                              setState(() {
                                _selectedTabIndex = 0;
                                _updateCurrentTabExams();
                              });
                            },
                          ),
                          const SizedBox(width: 24),
                          ExamTabItem(
                            index: 1,
                            label: "Completed Exams",
                            count: _completedCount,
                            icon: Icons.check_circle_outline,
                            isSelected: _selectedTabIndex == 1,
                            onTap: () {
                              setState(() {
                                _selectedTabIndex = 1;
                                _updateCurrentTabExams();
                              });
                            },
                          ),
                          const SizedBox(width: 24),
                          ExamTabItem(
                            index: 2,
                            label: "Online Exam",
                            count: ExamModel.onlineExams.length,
                            icon: Icons.computer_outlined,
                            isSelected: _selectedTabIndex == 2,
                            onTap: () {
                              setState(() {
                                _selectedTabIndex = 2;
                                _updateCurrentTabExams();
                              });
                            },
                          ),
                          const SizedBox(width: 24),
                          ExamTabItem(
                            index: 3,
                            label: "Offline Exams",
                            count: ExamModel.offlineExams.length,
                            icon: Icons.assignment_outlined,
                            isSelected: _selectedTabIndex == 3,
                            onTap: () {
                              setState(() {
                                _selectedTabIndex = 3;
                                _updateCurrentTabExams();
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Filters Row
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedSubject,
                                isExpanded: true,
                                icon: const Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 20,
                                ),
                                items: _subjects
                                    .map(
                                      (s) => DropdownMenuItem(
                                        value: s,
                                        child: Text(
                                          s,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _selectedSubject = val);
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 1,
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextField(
                              onChanged: (val) {
                                setState(() => _searchQuery = val);
                              },
                              decoration: const InputDecoration(
                                hintText: "Search Exams..",
                                hintStyle: TextStyle(
                                  fontSize: 14,
                                  color: secondaryTextColor,
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  size: 20,
                                  color: secondaryTextColor,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Performance Banner for Completed Tab
                    if (_selectedTabIndex == 1 &&
                        _getFilteredAndPagedExams().isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          border: Border.all(color: const Color(0xFFBBF7D0)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Color(0xFF22C55E),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Your overall performance is Excellent!",
                                    style: TextStyle(
                                      color: Color(0xFF166534),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    "Average score: ${_averageScore.toStringAsFixed(1)}%",
                                    style: const TextStyle(
                                      color: Color(0xFF166534),
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    // List Section
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          double minTableWidth = 1200;
                          double actualWidth = max(
                            constraints.maxWidth,
                            minTableWidth,
                          );

                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SizedBox(
                              width: actualWidth,
                              child: Column(
                                children: [
                                  // Table Header
                                  _selectedTabIndex == 1
                                      ? const CompletedExamHeader()
                                      : _selectedTabIndex == 2
                                      ? const OnlineExamHeader()
                                      : const StandardExamHeader(),

                                  // List Items
                                  ..._getFilteredAndPagedExams().map((exam) {
                                    if (_selectedTabIndex == 1) {
                                      return CompletedExamCard(
                                        exam: exam,
                                        onViewScoreCard: () =>
                                            _showExamSummaryDialog(
                                              context,
                                              exam.id,
                                            ),
                                      );
                                    } else if (_selectedTabIndex == 2) {
                                      return OnlineExamCard(
                                        exam: exam,
                                        onViewResult: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  ExamDetailsPhysicsDialog(
                                                    exam: exam,
                                                  ),
                                            ),
                                          );
                                        },
                                      );
                                    } else {
                                      return StandardExamCard(exam: exam);
                                    }
                                  }),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Pagination
                    if (_getTotalPages() > 1)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: List.generate(_getTotalPages(), (index) {
                          final pageNum = index + 1;
                          final isSelected = _currentPage == pageNum;
                          return InkWell(
                            onTap: () => setState(() => _currentPage = pageNum),
                            child: Container(
                              margin: const EdgeInsets.only(left: 8),
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? primaryColor
                                    : const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "$pageNum",
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : secondaryTextColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

void _showExamSummaryDialog(BuildContext context, String examId) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => ExamSummaryDialog(examId: examId)),
  );
}
