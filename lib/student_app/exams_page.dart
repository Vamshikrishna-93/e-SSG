import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'dart:math';
import 'package:student_app/student_app/exam_summary_dialog.dart';
import 'package:student_app/student_app/model/exam_item.dart';
import 'package:student_app/student_app/services/exams_service.dart';
import 'package:student_app/student_app/student_calendar.dart';
import 'package:student_app/student_app/studentdrawer.dart';
import 'package:student_app/student_app/widgets/online_exam_card.dart';
import 'package:student_app/student_app/widgets/stat_card.dart';
import 'package:student_app/student_app/widgets/exam_tab_item.dart';
import 'package:student_app/student_app/widgets/standard_exam_card.dart';
import 'package:student_app/student_app/widgets/completed_exam_card.dart';
import 'package:student_app/student_app/widgets/exam_headers.dart';
import 'package:student_app/student_app/widgets/loading_animation.dart';

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
  String _selectedProctoringType = "All Proctoring Types";
  final List<String> _proctoringTypes = [
    "All Proctoring Types",
    "Proctored",
    "Non-Proctored",
  ];

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
          List<ExamModel> onlineExamsList = [];
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
    if (_selectedTabIndex == 2) return 1;

    // Calculate total pages for current filtered list
    List<ExamModel> filtered = _currentTabExams.where((exam) {
      if (_selectedSubject != "All Subjects" &&
          exam.subject != _selectedSubject)
        return false;
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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(title: const Text("Exams"), centerTitle: true),
      drawer: const StudentDrawerPage(),
      bottomNavigationBar: _buildBottomNav(),
      body: _isLoading
          ? const Center(child: StudentLoadingAnimation())
          : RefreshIndicator(
              onRefresh: _fetchExams,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Header
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Exams",
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Manage your exams and view results",
                              style: theme.textTheme.bodySmall,
                            ),
                            if (_studentFullName.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Wrap(
                                  spacing: 16,
                                  runSpacing: 8,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.person_outline,
                                          size: 14,
                                          color: Colors.blue.shade700,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          _studentFullName,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.blue.shade700,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (_admno.isNotEmpty)
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.badge_outlined,
                                            size: 14,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            "ADM: $_admno",
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    if (_courseName.isNotEmpty)
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.school_outlined,
                                            size: 14,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            _courseName,
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const StudentCalendar(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.calendar_month, size: 18),
                          label: const Text("Open Calendar"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Stats Cards
                    Column(
                      children: [
                        StatCard(
                          title: "Upcoming Exams",
                          value: "$_upcomingCount",
                          subtext: "Total assigned: $_totalExamsCount",
                          icon: Icons.calendar_today,
                          iconColor: Colors.blue,
                          content: null,
                        ),
                        const SizedBox(height: 16),
                        StatCard(
                          title: "Completed",
                          value: "$_completedCount",
                          subtext: "Based on your submissions",
                          icon: Icons.emoji_events_outlined,
                          iconColor: Colors.green,
                          content: null,
                        ),
                        const SizedBox(height: 16),
                        StatCard(
                          title: "Class Rank",
                          value: "1/85",
                          subtext: "Top 10 of the class",
                          icon: Icons.star_outline,
                          iconColor: Colors.purple,
                          content: null,
                        ),
                        const SizedBox(height: 16),
                        StatCard(
                          title: "Study Hours",
                          value: "${_upcomingCount * 2} hrs",
                          subtext: "Approx. 2 hrs per upcoming exam",
                          icon: Icons.access_time,
                          iconColor: Colors.teal,
                          content: null,
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Tab Container
                    Container(
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tabs Row
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
                                  icon: Icons.computer,
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
                                  label: "Offline Exam",
                                  count: ExamModel.offlineExams.length,
                                  icon: Icons.class_outlined,
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

                          // Online Exam Banner
                          if (_selectedTabIndex == 2) const OnlineExamBanner(),
                          const SizedBox(height: 24),
                          // Filters: Dropdown + Search
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                      color: theme.dividerColor,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedSubject,
                                      isExpanded: true,
                                      dropdownColor: theme.cardColor,
                                      items: _subjects
                                          .map(
                                            (s) => DropdownMenuItem(
                                              value: s,
                                              child: Text(
                                                s,
                                                style: TextStyle(
                                                  color: theme
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.color,
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (val) {
                                        if (val != null) {
                                          setState(
                                            () => _selectedSubject = val,
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              if (_selectedTabIndex == 2) ...[
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                        color: theme.dividerColor,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: _selectedProctoringType,
                                        isExpanded: true,
                                        dropdownColor: theme.cardColor,
                                        items: _proctoringTypes
                                            .map(
                                              (s) => DropdownMenuItem(
                                                value: s,
                                                child: Text(
                                                  s,
                                                  style: TextStyle(
                                                    color: theme
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.color,
                                                  ),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (val) {
                                          if (val != null) {
                                            setState(
                                              () =>
                                                  _selectedProctoringType = val,
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                              ],
                              Expanded(
                                flex: 3,
                                child: TextField(
                                  onChanged: (val) {
                                    setState(() => _searchQuery = val);
                                  },
                                  style: TextStyle(
                                    color: theme.textTheme.bodyMedium?.color,
                                  ),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    hintText: _selectedTabIndex == 2
                                        ? "Search online exams..."
                                        : "Search exams...",
                                    hintStyle: TextStyle(
                                      color: theme.textTheme.bodySmall?.color,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.search,
                                      size: 20,
                                      color: theme.textTheme.bodySmall?.color,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(
                                        color: theme.dividerColor,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(
                                        color: theme.dividerColor,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 0,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Completed Exam Banner (Only on Completed Tab)
                          if (_selectedTabIndex == 1 &&
                              _getFilteredAndPagedExams().isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(bottom: 24),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.lightGreen.shade50.withAlpha(127),
                                border: Border.all(
                                  color: Colors.lightGreen.shade200,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(2),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        style: TextStyle(
                                          color: Colors.green.shade900,
                                          fontSize: 14,
                                        ),
                                        children: [
                                          const TextSpan(
                                            text:
                                                "Your average score in online exams is ",
                                          ),
                                          TextSpan(
                                            text:
                                                "${_averageScore.toStringAsFixed(1)}%",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green.shade900,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // List Header & Items
                          LayoutBuilder(
                            builder: (context, constraints) {
                              double minTableWidth = 1000;
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
                                      // Header
                                      _selectedTabIndex == 1
                                          ? const CompletedExamHeader()
                                          : _selectedTabIndex == 2
                                          ? const OnlineExamHeader()
                                          : const StandardExamHeader(),

                                      // List Items
                                      ..._getFilteredAndPagedExams().map((
                                        exam,
                                      ) {
                                        if (_selectedTabIndex == 1) {
                                          return CompletedExamCard(
                                            exam: exam,
                                            onViewScoreCard: () =>
                                                _showExamSummaryDialog(
                                                  context,
                                                  exam.id,
                                                ),
                                          );
                                        }
                                        if (_selectedTabIndex == 2) {
                                          return OnlineExamCard(
                                            exam: exam,
                                            onViewResult: () =>
                                                _showExamSummaryDialog(
                                                  context,
                                                  exam.id,
                                                ),
                                          );
                                        }
                                        return StandardExamCard(exam: exam);
                                      }),

                                      if (_getFilteredAndPagedExams().isEmpty)
                                        Padding(
                                          padding: const EdgeInsets.all(40.0),
                                          child: Center(
                                            child: Text(
                                              "No exams found.",
                                              style: TextStyle(
                                                color: Colors.grey[500],
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 20),

                          // Pagination Controls
                          if (_getTotalPages() > 1)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  onPressed: _currentPage > 1
                                      ? () {
                                          setState(() {
                                            _currentPage--;
                                          });
                                        }
                                      : null,
                                  icon: const Icon(Icons.chevron_left),
                                ),
                                // Page numbers
                                ...List.generate(_getTotalPages(), (index) {
                                  int pageNum = index + 1;
                                  bool isCurrent = pageNum == _currentPage;
                                  return InkWell(
                                    onTap: () {
                                      setState(() => _currentPage = pageNum);
                                    },
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      alignment: Alignment.center,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isCurrent
                                            ? Colors.blue.shade50
                                            : Colors.transparent,
                                        border: isCurrent
                                            ? Border.all(color: Colors.blue)
                                            : Border.all(
                                                color: Colors.transparent,
                                              ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        "$pageNum",
                                        style: TextStyle(
                                          color: isCurrent
                                              ? Colors.blue
                                              : Colors.grey[700],
                                          fontWeight: isCurrent
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                                IconButton(
                                  onPressed: _currentPage < _getTotalPages()
                                      ? () {
                                          setState(() {
                                            _currentPage++;
                                          });
                                        }
                                      : null,
                                  icon: const Icon(Icons.chevron_right),
                                ),
                              ],
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

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: const BoxDecoration(
        color: Color(0xFF7C3AED),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(35),
          topRight: Radius.circular(35),
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              Icons.home,
              "Home",
              onTap: () => Get.offNamed('/studentDashboard'),
            ),
            _buildNavItem(
              Icons.bar_chart,
              "Marks",
              onTap: () => Get.offNamed('/studentMarks'),
            ),
            _buildNavItem(Icons.assignment_outlined, "Exams", active: true),
            _buildNavItem(
              Icons.person,
              "Profile",
              onTap: () => Get.offNamed('/studentProfile'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label, {
    bool active = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: active ? Colors.white.withOpacity(0.25) : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showExamSummaryDialog(BuildContext context, String examId) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => ExamSummaryDialog(examId: examId)),
  );
}
