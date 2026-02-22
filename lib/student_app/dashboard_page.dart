import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:student_app/theme_controllers.dart';
import 'package:student_app/student_app/announcement_page.dart';
import 'package:student_app/student_app/model/class_attendance.dart';
import 'package:student_app/student_app/model/hostel_attendance.dart';
import 'package:student_app/student_app/services/attendance_service.dart';
import 'package:student_app/student_app/services/hostel_attendance_service.dart';
import 'package:student_app/student_app/services/remarks_service.dart';
import 'package:student_app/student_app/student_app_bar.dart';
import 'package:student_app/student_app/full_day_timetable.dart';
import 'package:student_app/student_app/upcoming_exams_page.dart';
import 'package:student_app/student_app/student_calendar.dart';
import 'package:student_app/student_app/widgets/dashboard_widgets.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _isLoading = true;
  Map<String, dynamic> _attendanceData = {};

  // Graph Data
  List<Map<String, dynamic>> _chartData = [];
  List<Map<String, dynamic>> _allChartData = []; // Store all data
  List<String> _chartMonths = [];
  List<String> _allChartMonths = []; // Store all months
  double _chartMaxValue = 30;
  TimeRange _selectedTimeRange = TimeRange.academicYear;

  List<dynamic> _remarks = [];

  // Hostel Attendance Graph Data
  List<Map<String, dynamic>> _hostelChartData = [];
  List<Map<String, dynamic>> _allHostelChartData = []; // Store all data
  List<String> _hostelChartMonths = [];
  List<String> _allHostelChartMonths = []; // Store all months
  double _hostelChartMaxValue = 30;
  TimeRange _selectedHostelTimeRange = TimeRange.academicYear;

  @override
  void initState() {
    super.initState();
    // 1. Initial load from cache (instant)
    _fetchDashboardData(forceRefresh: false);

    // 2. Background sync from server (automatic update)
    _fetchDashboardData(forceRefresh: true);
  }

  Future<void> _fetchDashboardData({bool forceRefresh = false}) async {
    try {
      // Fetch all data in parallel
      final results = await Future.wait([
        AttendanceService.getAttendanceSummary(forceRefresh: forceRefresh),
        AttendanceService.getAttendance(forceRefresh: forceRefresh),
        RemarksService.getRemarks(forceRefresh: forceRefresh),
        HostelAttendanceService.getHostelAttendance(forceRefresh: forceRefresh),
      ]);

      final summary = results[0] as Map<String, dynamic>;
      final grid = results[1] as ClassAttendance;
      final remarks = results[2] as List<dynamic>;
      final hostelGrid = results[3] as HostelAttendance;

      if (mounted) {
        // Sort remarks by date descending (newest first)
        final List<dynamic> sortedRemarks = List.from(remarks);
        sortedRemarks.sort((a, b) {
          final dateA =
              DateTime.tryParse(a['created_at']?.toString() ?? '') ??
              DateTime(0);
          final dateB =
              DateTime.tryParse(b['created_at']?.toString() ?? '') ??
              DateTime(0);
          return dateB.compareTo(dateA);
        });

        setState(() {
          _attendanceData = summary;
          _processChartData(grid);
          _remarks = sortedRemarks;
          _processHostelChartData(hostelGrid);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        debugPrint("Error fetching dashboard data: $e");
      }
    }
  }

  void _processChartData(dynamic data) {
    try {
      if (data is! ClassAttendance) return;

      final monthsList = data.attendance;

      if (monthsList.isNotEmpty) {
        _allChartData.clear();
        _allChartMonths.clear();

        double maxVal = 0;

        // Store all data first
        for (var m in monthsList) {
          final monthName = m.monthName;
          final present = m.present;
          final absent = m.absent;
          final holidays = m.holidays;
          final outings = m.outings;
          final total = m.total;

          if (total > maxVal) maxVal = total.toDouble();

          _allChartMonths.add(monthName);
          _allChartData.add({
            'present': present,
            'absent': absent,
            'holidays': holidays,
            'outings': outings,
            'total': total,
            'month': monthName,
          });
        }

        // Apply time range filter
        _applyTimeRangeFilter();
        _chartMaxValue = maxVal > 0 ? maxVal + 2 : 30; // Add buffer
      }
    } catch (e) {
      print("Error processing chart data: $e");
    }
  }

  void _applyTimeRangeFilter() {
    _chartData.clear();
    _chartMonths.clear();

    int monthsToShow;
    switch (_selectedTimeRange) {
      case TimeRange.last3Months:
        monthsToShow = 3;
        break;
      case TimeRange.last6Months:
        monthsToShow = 6;
        break;
      case TimeRange.lastMonth:
        monthsToShow = 1;
        break;
      case TimeRange.academicYear:
        monthsToShow = _allChartData.length;
        break;
    }

    final startIndex = _allChartData.length > monthsToShow
        ? _allChartData.length - monthsToShow
        : 0;

    for (int i = startIndex; i < _allChartData.length; i++) {
      if (i >= _allChartMonths.length) break;
      final data = _allChartData[i];
      final monthName = _allChartMonths[i];

      // Extract short month name (first 3 chars)
      final shortMonth = monthName.length > 3
          ? monthName.substring(0, 3)
          : monthName;

      _chartMonths.add(shortMonth);
      _chartData.add(data);
    }
  }

  void _processHostelChartData(HostelAttendance data) {
    try {
      _allHostelChartData.clear();
      _allHostelChartMonths.clear();

      double maxVal = 0;

      for (var m in data.attendance) {
        final monthName = m.monthName;
        final present = m.present;
        final absent = m.absent;
        final total = m.total;

        if (total > maxVal) maxVal = total.toDouble();

        _allHostelChartMonths.add(monthName);
        _allHostelChartData.add({
          'present': present,
          'absent': absent,
          'holidays': m.holidays,
          'outings': m.outings,
          'total': total,
          'totalHostelDays': present + absent,
          'month': monthName,
        });
      }

      _applyHostelTimeRangeFilter();
      _hostelChartMaxValue = maxVal > 0 ? maxVal + 2 : 30;
    } catch (e) {
      print("Error processing hostel chart data: $e");
    }
  }

  void _applyHostelTimeRangeFilter() {
    _hostelChartData.clear();
    _hostelChartMonths.clear();

    int monthsToShow;
    switch (_selectedHostelTimeRange) {
      case TimeRange.last3Months:
        monthsToShow = 3;
        break;
      case TimeRange.last6Months:
        monthsToShow = 6;
        break;
      case TimeRange.lastMonth:
        monthsToShow = 1;
        break;
      case TimeRange.academicYear:
        monthsToShow = _allHostelChartData.length;
        break;
    }

    final startIndex = _allHostelChartData.length > monthsToShow
        ? _allHostelChartData.length - monthsToShow
        : 0;

    for (int i = startIndex; i < _allHostelChartData.length; i++) {
      if (i >= _allHostelChartMonths.length) break;
      final data = _allHostelChartData[i];
      final monthName = _allHostelChartMonths[i];

      // Extract short month name (first 3 chars)
      final shortMonth = monthName.length > 3
          ? monthName.substring(0, 3)
          : monthName;

      _hostelChartMonths.add(shortMonth);
      _hostelChartData.add(data);
    }
  }

  String _getTimeRangeLabel(TimeRange range) {
    switch (range) {
      case TimeRange.academicYear:
        return 'Academic Year';
      case TimeRange.last6Months:
        return 'Last 6 Months';
      case TimeRange.last3Months:
        return 'Last 3 Months';
      case TimeRange.lastMonth:
        return 'Last Month';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ThemeControllerWrapper(
      themeController: StudentThemeController.themeMode,
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: const StudentAppBar(),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    "Student Dashboard",
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text("Dashboard", style: const TextStyle(color: Colors.blue)),

                  const SizedBox(height: 20),

                  // Attendance Card
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.black.withOpacity(0.3)
                              : Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {},
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Attendance",
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                    if (_isLoading)
                                      const SizedBox(
                                        height: 16,
                                        width: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                              AttendanceTile(
                                icon: Icons.calendar_today,
                                iconColor: Colors.blue,
                                title: "Total Days",
                                value:
                                    _attendanceData['total_working_days']
                                        ?.toString() ??
                                    "-",
                              ),
                              AttendanceTile(
                                icon: Icons.check_circle,
                                iconColor: Colors.green,
                                title: "Present",
                                value:
                                    _attendanceData['present']?.toString() ??
                                    "-",
                              ),
                              AttendanceTile(
                                icon: Icons.directions_run,
                                iconColor: Colors.cyan,
                                title: "Outings",
                                value:
                                    _attendanceData['outings']?.toString() ??
                                    "-",
                              ),
                              AttendanceTile(
                                icon: Icons.cancel,
                                iconColor: Colors.red,
                                title: "Absent",
                                value:
                                    _attendanceData['absent']?.toString() ??
                                    "-",
                              ),
                              AttendanceTile(
                                icon: Icons.event,
                                iconColor: Colors.amber,
                                title: "Holidays",
                                value:
                                    _attendanceData['holidays']?.toString() ??
                                    "-",
                                isLast: true,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Exam Stats Card
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.black.withOpacity(0.3)
                              : Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {},
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  "Exam Stats",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.color,
                                  ),
                                ),
                              ),

                              AttendanceTile(
                                icon: Icons.assignment,
                                iconColor: Colors.blue,
                                title: "Total Exam Questions",
                                value:
                                    _attendanceData['total_exam_questions']
                                        ?.toString() ??
                                    "200",
                              ),
                              AttendanceTile(
                                icon: Icons.check_circle,
                                iconColor: Colors.green,
                                title: "Total Attempted Questions",
                                value:
                                    _attendanceData['total_attempted_questions']
                                        ?.toString() ??
                                    "150",
                              ),
                              AttendanceTile(
                                icon: Icons.close,
                                iconColor: Colors.amber,
                                title: "Total Not Attempted",
                                value:
                                    _attendanceData['total_not_attempted']
                                        ?.toString() ??
                                    "50",
                              ),
                              AttendanceTile(
                                icon: Icons.add_circle,
                                iconColor: Colors.cyan,
                                title: "Total +ve Questions",
                                value:
                                    _attendanceData['total_positive_questions']
                                        ?.toString() ??
                                    "120",
                              ),
                              AttendanceTile(
                                icon: Icons.remove_circle,
                                iconColor: Colors.red,
                                title: "Total -ve Questions",
                                value:
                                    _attendanceData['total_negative_questions']
                                        ?.toString() ??
                                    "30",
                                isLast: true,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Rank Stats Card
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.black.withOpacity(0.3)
                              : Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {},
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  "Rank Stats",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.color,
                                  ),
                                ),
                              ),

                              RankTile(
                                icon: Icons.emoji_events,
                                iconColor: Colors.blue,
                                title: "Overall Rank",
                                value:
                                    _attendanceData['overall_rank']
                                        ?.toString() ??
                                    "12",
                              ),
                              RankTile(
                                icon: Icons.account_tree,
                                iconColor: Colors.green,
                                title: "Branch Wise Rank",
                                value:
                                    _attendanceData['branch_wise_rank']
                                        ?.toString() ??
                                    "3",
                              ),
                              RankTile(
                                icon: Icons.groups,
                                iconColor: Colors.cyan,
                                title: "Group Wise Rank",
                                value:
                                    _attendanceData['group_wise_rank']
                                        ?.toString() ??
                                    "5",
                              ),
                              RankTile(
                                icon: Icons.menu_book,
                                iconColor: Colors.amber,
                                title: "Course Wise Rank",
                                value:
                                    _attendanceData['course_wise_rank']
                                        ?.toString() ??
                                    "8",
                              ),
                              RankTile(
                                icon: Icons.layers,
                                iconColor: Colors.red,
                                title: "Batch Wise Rank",
                                value:
                                    _attendanceData['batch_wise_rank']
                                        ?.toString() ??
                                    "2",
                                isLast: true,
                                isHighlighted: true,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Time Table Card
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.black.withOpacity(0.3)
                              : Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Time Table",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.color,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Subject Cards
                        TimeTableCard(
                          subject: "Maths",
                          time: "09:00 - 09:45",
                          instructor: "Mr. Ramesh",
                        ),
                        TimeTableCard(
                          subject: "Physics",
                          time: "09:50 - 10:35",
                          instructor: "Ms. Anjali",
                        ),
                        TimeTableCard(
                          subject: "Chemistry",
                          time: "10:40 - 11:25",
                          instructor: "Dr. Suresh",
                        ),
                        TimeTableCard(
                          subject: "English",
                          time: "11:30 - 12:15",
                          instructor: "Mrs. Kavitha",
                          isLast: true,
                        ),

                        // View All Button
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Center(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const FullDayTimetablePage(),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.calendar_today,
                                color: Color(0xFF2563EB),
                                size: 18,
                              ),
                              label: const Text(
                                "View All",
                                style: TextStyle(
                                  color: Color(0xFF2563EB),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFF2563EB),
                                  width: 1.5,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Class Attendance Chart Card
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.black.withOpacity(0.3)
                              : Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  "Class Attendance (Month-wise Days)",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.color,
                                  ),
                                ),
                              ),
                              PopupMenuButton<TimeRange>(
                                initialValue: _selectedTimeRange,
                                onSelected: (TimeRange value) {
                                  setState(() {
                                    _selectedTimeRange = value;
                                    _applyTimeRangeFilter();
                                  });
                                },
                                offset: const Offset(0, 40),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.grey.shade800
                                        : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _getTimeRangeLabel(_selectedTimeRange),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
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
                                itemBuilder: (BuildContext context) =>
                                    <PopupMenuEntry<TimeRange>>[
                                      PopupMenuItem<TimeRange>(
                                        value: TimeRange.academicYear,
                                        child: Text('Academic Year'),
                                      ),
                                      PopupMenuItem<TimeRange>(
                                        value: TimeRange.last6Months,
                                        child: Text('Last 6 Months'),
                                      ),
                                      PopupMenuItem<TimeRange>(
                                        value: TimeRange.last3Months,
                                        child: Text('Last 3 Months'),
                                      ),
                                      PopupMenuItem<TimeRange>(
                                        value: TimeRange.lastMonth,
                                        child: Text('Last Month'),
                                      ),
                                    ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _chartData.isEmpty
                              ? const SizedBox(
                                  height: 200,
                                  child: Center(
                                    child: Text("Loading chart data..."),
                                  ),
                                )
                              : AttendanceChart(
                                  months: _chartMonths,
                                  maxValue: _chartMaxValue.toInt(),
                                  data: _chartData,
                                  selectedRange: _selectedTimeRange,
                                ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              DashboardLegendItem(
                                color: Colors.green,
                                label: "Present",
                              ),
                              DashboardLegendItem(
                                color: Colors.red,
                                label: "Absent",
                              ),
                              DashboardLegendItem(
                                color: Colors.amber,
                                label: "Outings",
                              ),
                              DashboardLegendItem(
                                color: Colors.blue,
                                label: "Holidays",
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ... (Rest of existing content: Hostel Attendance, Remarks, Announcements)
                  // Keeping the rest of the file layout identical for brevity in this response, but assuming direct copy.
                  // To ensure completeness, I will restore the bottom part.

                  // Hostel Attendance Chart Card
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.black.withOpacity(0.3)
                              : Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  "Hostel Attendance (Month-wise Days)",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.color,
                                  ),
                                ),
                              ),
                              PopupMenuButton<TimeRange>(
                                initialValue: _selectedHostelTimeRange,
                                onSelected: (TimeRange value) {
                                  setState(() {
                                    _selectedHostelTimeRange = value;
                                    _applyHostelTimeRangeFilter();
                                  });
                                },
                                offset: const Offset(0, 40),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.grey.shade800
                                        : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _getTimeRangeLabel(
                                          _selectedHostelTimeRange,
                                        ),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
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
                                itemBuilder: (BuildContext context) =>
                                    <PopupMenuEntry<TimeRange>>[
                                      PopupMenuItem<TimeRange>(
                                        value: TimeRange.academicYear,
                                        child: Text('Academic Year'),
                                      ),
                                      PopupMenuItem<TimeRange>(
                                        value: TimeRange.last6Months,
                                        child: Text('Last 6 Months'),
                                      ),
                                      PopupMenuItem<TimeRange>(
                                        value: TimeRange.last3Months,
                                        child: Text('Last 3 Months'),
                                      ),
                                      PopupMenuItem<TimeRange>(
                                        value: TimeRange.lastMonth,
                                        child: Text('Last Month'),
                                      ),
                                    ],
                              ),
                            ],
                          ),
                        ),
                        // Fallback or duplicate chart if needed, or static for now
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _hostelChartData.isEmpty
                              ? const SizedBox(
                                  height: 200,
                                  child: Center(
                                    child: Text(
                                      "Loading hostel attendance data...",
                                    ),
                                  ),
                                )
                              : AttendanceChart(
                                  months: _hostelChartMonths,
                                  maxValue: _hostelChartMaxValue.toInt(),
                                  data: _hostelChartData,
                                  isHostel: true,
                                  selectedRange: _selectedHostelTimeRange,
                                ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              DashboardLegendItem(
                                color: Colors.green,
                                label: "Present",
                              ),
                              DashboardLegendItem(
                                color: Colors.red,
                                label: "Absent",
                              ),
                              DashboardLegendItem(
                                color: Colors.amber,
                                label: "Outings",
                              ),
                              DashboardLegendItem(
                                color: Colors.blue,
                                label: "Holidays",
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Remarks Card
                  // Remarks Section
                  _buildRemarksSection(),
                  const SizedBox(height: 20),

                  // Announcements Card
                  DashboardSectionCard(
                    title: "Announcements",
                    emptyMessage: "No announcements found",
                    buttonText: "View All Announcements",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AnnouncementsDialog(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Upcoming Exams Card
                  DashboardSectionCard(
                    title: "Upcoming Exams",
                    emptyMessage: "No upcoming exams",
                    buttonText: "View All Exams",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const UpcomingExams()),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Student Calendar - Displayed Inline
                  const StudentCalendar(showAppBar: false, isInline: true),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRemarksSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              "Remarks",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (_remarks.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        "No remarks found",
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ),
                  )
                else
                  ..._remarks.take(2).map((r) => _buildRemarkItem(r)),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _showAllRemarksDialog,
                    icon: const Icon(Icons.visibility, size: 18),
                    label: const Text("View All Remarks"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1D68F2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 4,
                      shadowColor: Colors.blue.withOpacity(0.4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemarkItem(dynamic remark, {bool showStatus = false}) {
    final remarkText = remark['remark']?.toString() ?? 'No details available';
    final relatedTo = remark['related_to']?.toString() ?? 'General';
    final createdAt = remark['created_at']?.toString() ?? '';

    DateTime? dateTime;
    if (createdAt.isNotEmpty) {
      try {
        dateTime = DateTime.parse(createdAt);
      } catch (e) {}
    }

    String dateStr = dateTime != null
        ? DateFormat('dd MMM yyyy').format(dateTime)
        : '';
    String timeStr = dateTime != null
        ? DateFormat('hh:mm a').format(dateTime)
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Blue Icon Square
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF1D68F2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.access_time_filled,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        relatedTo,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    if (showStatus) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1D68F2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          "NEUTRAL",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                    const Spacer(),
                    Text(
                      dateStr,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  remarkText,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.person, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      "Hostel Staff",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    if (timeStr.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      Text(
                        "($timeStr)",
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF1D68F2),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAllRemarksDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              insetPadding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 600),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "All Remarks (${_remarks.length})",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    // Content
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: _remarks.isEmpty
                              ? [
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 40),
                                    child: Center(
                                      child: Text("No remarks found"),
                                    ),
                                  ),
                                ]
                              : _remarks
                                    .map(
                                      (r) =>
                                          _buildRemarkItem(r, showStatus: true),
                                    )
                                    .toList(),
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    // Footer
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          OutlinedButton(
                            onPressed: () async {
                              await _fetchDashboardData();
                              setDialogState(() {});
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF1D68F2)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: const Text("Refresh Data"),
                          ),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF64748B),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text("Close"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
