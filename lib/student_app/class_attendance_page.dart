import 'dart:math' as math;
import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:student_app/student_app/services/attendance_service.dart';
import 'package:student_app/student_app/model/class_attendance.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:student_app/student_app/attendence_month_details_page.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  String selectedPeriod = "All Months";
  int currentPage = 1;
  final int itemsPerPage = 10;
  bool _isLoading = true;
  String _searchQuery = "";

  // Dynamic data
  double overallAttendance = 0.0;
  int daysAttended = 0;
  int totalDays = 0;
  int daysAbsent = 0;
  int currentStreak = 0;
  int bestStreak = 0;
  int leavesTaken = 0;
  int leavesRemaining = 0;

  List<MonthlyClassAttendance> monthlyData = [];
  List<double> trendData = [];
  Timer? _refreshTimer;

  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchAttendanceData(forceRefresh: false);
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchAttendanceData({bool forceRefresh = true}) async {
    setState(() => _isLoading = true);

    try {
      // Fetch both Grid and Summary in parallel
      final results = await Future.wait([
        AttendanceService.getAttendance(forceRefresh: forceRefresh),
        AttendanceService.getAttendanceSummary(forceRefresh: forceRefresh),
      ]);

      final ClassAttendance gridData = results[0] as ClassAttendance;
      final Map<String, dynamic> summary = results[1] as Map<String, dynamic>;

      double? safeDouble(dynamic v) {
        if (v == null) return null;
        if (v is num) return v.toDouble();
        return double.tryParse(v.toString().replaceAll('%', '').trim());
      }

      int? safeInt(dynamic v) {
        if (v == null) return null;
        if (v is num) return v.toInt();
        return int.tryParse(v.toString().replaceAll('%', '').trim());
      }

      if (mounted) {
        setState(() {
          // Use summary data if available, otherwise fallback to grid's synthesized stats
          overallAttendance =
              safeDouble(
                summary['overall_attendance_percentage'] ??
                    summary['attendance_percentage'],
              ) ??
              gridData.overallPercentage ??
              0.0;
          daysAttended =
              safeInt(summary['present_days'] ?? summary['present']) ??
              gridData.totalPresent ??
              0;
          totalDays =
              safeInt(summary['total_working_days'] ?? summary['total']) ??
              gridData.totalDays ??
              0;
          daysAbsent =
              safeInt(summary['absent_days'] ?? summary['absent']) ??
              gridData.totalAbsent ??
              0;
          currentStreak =
              safeInt(summary['streak'] ?? summary['current_streak']) ??
              gridData.currentStreak ??
              0;
          bestStreak =
              safeInt(summary['best_streak'] ?? summary['highest_streak']) ??
              gridData.bestStreak ??
              0;
          leavesTaken =
              safeInt(summary['leaves'] ?? summary['leave_days']) ??
              gridData.totalLeaves ??
              0;
          leavesRemaining =
              safeInt(summary['leaves_remaining']) ??
              gridData.leavesRemaining ??
              0;

          // Process monthly data for table
          monthlyData = gridData.attendance;

          // Process trend data (last 6 months)
          trendData = gridData.attendance
              .take(6)
              .map((m) => m.percentage)
              .toList()
              .reversed
              .toList();

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load attendance: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _downloadReport() async {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Preparing report...")));
    try {
      final bytes = await AttendanceService.downloadAttendanceReport();
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/class_attendance_report.pdf';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Report ready: class_attendance_report.pdf"),
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
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        String errorMsg = e.toString();
        if (errorMsg.contains('MissingPluginException') ||
            errorMsg.contains('Unsupported operation')) {
          errorMsg =
              "App restart required to activate download plugin. Please stop and re-run the app.";
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to download: $errorMsg"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Custom Header
                      Container(
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top + 10,
                          bottom: 25,
                          left: 20,
                          right: 20,
                        ),
                        decoration: const BoxDecoration(
                          color: Color(0xFF7E49FF),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          ),
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Colors.white24,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              "Class Attendance",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(isMobile ? 16.0 : 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Attendance Dashboard Header Card
                            _buildDashboardHeader(isMobile),
                            const SizedBox(height: 20),

                            // Overall Attendance Card
                            _buildOverallAttendanceCard(isMobile),
                            const SizedBox(height: 16),

                            // Days Attended Card
                            _buildDaysAttendedCard(isMobile),
                            const SizedBox(height: 16),

                            // Current Streak Card
                            _buildCurrentStreakCard(isMobile),
                            const SizedBox(height: 16),

                            // Leaves Taken Card
                            _buildLeavesTakenCard(isMobile),
                            const SizedBox(height: 20),

                            // Attendance Trend Card
                            _buildAttendanceTrendCard(isMobile),
                            const SizedBox(height: 20),

                            // Monthly Attendance Overview Card
                            _buildMonthlyOverviewCard(isMobile),
                            const SizedBox(height: 20),

                            // Performance Summary Card
                            _buildPerformanceSummaryCard(isMobile),
                            const SizedBox(height: 20),

                            // Recent Activity Card
                            _buildRecentActivityCard(isMobile),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildDashboardHeader(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Class Attendance',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Track, analyze, and improve your attendance\nperformance',
          style: TextStyle(fontSize: 14, color: Color(0xFF4B5563), height: 1.4),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFFC084FC)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () => _fetchAttendanceData(forceRefresh: true),
                    icon: const Icon(
                      Icons.refresh,
                      size: 16,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Refresh',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4ADE80), Color(0xFFA3E635)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _downloadReport,
                    icon: const Icon(
                      Icons.print,
                      size: 16,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Download Report',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.zero,
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
      ],
    );
  }

  Widget _buildOverallAttendanceCard(bool isMobile) {
    return _buildSummaryCard(
      title: 'Overall Attendance',
      value: '${overallAttendance.toStringAsFixed(1)}%',
      valueColor: const Color(0xFF10B981),
      tagText: 'Based on $totalDays recorded days',
      tagColor: const Color(0xFF10B981),
      tagBg: const Color(0xFFE2F9F0),
      tagIcon: Icons.check_circle,
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required Color valueColor,
    required String tagText,
    required Color tagColor,
    required Color tagBg,
    required IconData tagIcon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF4B5563),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: tagBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(tagIcon, size: 14, color: tagColor),
                const SizedBox(width: 6),
                Text(
                  tagText,
                  style: TextStyle(
                    fontSize: 12,
                    color: tagColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaysAttendedCard(bool isMobile) {
    return _buildSummaryCard(
      title: 'Days Attended',
      value: '$daysAttended/$totalDays',
      valueColor: const Color(0xFF2563EB),
      tagText: '36 days left', // Placeholder from image
      tagColor: const Color(0xFF2563EB),
      tagBg: const Color(0xFFDBEAFE),
      tagIcon: Icons.person,
    );
  }

  Widget _buildCurrentStreakCard(bool isMobile) {
    return _buildSummaryCard(
      title: 'Current Streak',
      value: '$currentStreak days',
      valueColor: const Color(0xFF7E49FF),
      tagText: 'Best streak: $bestStreak days',
      tagColor: const Color(0xFF7E49FF),
      tagBg: const Color(0xFFF3E8FF),
      tagIcon: Icons.emoji_events,
    );
  }

  Widget _buildLeavesTakenCard(bool isMobile) {
    return _buildSummaryCard(
      title: 'Leaves Taken',
      value: '$leavesTaken days',
      valueColor: const Color(0xFFF97316),
      tagText: '$leavesRemaining leaves remaining',
      tagColor: const Color(0xFFD97706),
      tagBg: const Color(0xFFFFEDD5),
      tagIcon: Icons.info_outline,
    );
  }

  Widget _buildAttendanceTrendCard(bool isMobile) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFECEBFF),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Attendance Trend",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF000000),
                  ),
                ),
                PopupMenuButton<String>(
                  offset: const Offset(0, 40),
                  onSelected: (value) {
                    setState(() {
                      selectedPeriod = value;
                    });
                  },
                  itemBuilder: (context) =>
                      ["All Monthly", "Last 6 Months", "Last 3 Months"]
                          .map(
                            (p) => PopupMenuItem(
                              value: p,
                              child: Text(
                                p,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          )
                          .toList(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Text(
                          selectedPeriod == "All Months"
                              ? "All Monthly"
                              : selectedPeriod,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF4B5563),
                          ),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_down,
                          size: 16,
                          color: Color(0xFF4B5563),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 20, 10),
            child: SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) =>
                        FlLine(color: const Color(0xFFE5E7EB), strokeWidth: 1),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 35,
                        interval: 25,
                        getTitlesWidget: (value, meta) => Text(
                          '${value.toInt()}%',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: trendData
                          .asMap()
                          .entries
                          .map((e) => FlSpot(e.key.toDouble(), e.value))
                          .toList(),
                      isCurved: true,
                      color: const Color(0xFF2563EB),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: const Color(0xFF2563EB).withOpacity(0.1),
                      ),
                    ),
                  ],
                  minY: 0,
                  maxY: 100,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceSummaryCard(bool isMobile) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFFEEF0FF),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: const Text(
              "Performance Summary",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    // Circular Gauge
                    SizedBox(
                      width: 140,
                      height: 140,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 120,
                            height: 120,
                            child: CircularProgressIndicator(
                              value: overallAttendance / 100,
                              strokeWidth: 12,
                              backgroundColor: const Color(0xFFE5E7EB),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFFEF4444),
                              ),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "${overallAttendance.toStringAsFixed(1)}%",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF7E49FF),
                                ),
                              ),
                              const Text(
                                "Attendance",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEEF0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        "Needs Improvement",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Quick Stats Grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 2.0,
                  children: [
                    _buildStatBox(
                      "$daysAttended",
                      "Days Present",
                      const Color(0xFF10B981),
                    ),
                    _buildStatBox(
                      "$daysAbsent",
                      "Days Absent",
                      const Color(0xFFEF4444),
                    ),
                    _buildStatBox(
                      "$leavesTaken",
                      "Leaves Taken",
                      const Color(0xFFF97316),
                    ),
                    _buildStatBox(
                      "$leavesRemaining",
                      "Leaves Remaining",
                      const Color(0xFF7E49FF),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String val, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            val,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyOverviewCard(bool isMobile) {
    final List<MonthlyClassAttendance> filteredData = monthlyData
        .where(
          (m) => m.monthName.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();

    final int startIndex = (currentPage - 1) * itemsPerPage;
    final int endIndex = math.min(
      startIndex + itemsPerPage,
      filteredData.length,
    );
    final List<MonthlyClassAttendance> currentData = filteredData.isEmpty
        ? []
        : filteredData.sublist(startIndex, endIndex);

    final int totalItems = filteredData.length;
    final int totalPages = (totalItems / itemsPerPage).ceil();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFFEEF0FF),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: const Text(
              "Monthly class attendance overview",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSearchBar(),
                const SizedBox(height: 16),
                _buildAttendanceTable(currentData),
                const SizedBox(height: 20),
                _buildPaginationControls(
                  totalPages,
                  totalItems,
                  startIndex,
                  endIndex,
                ),
                const SizedBox(height: 20),
                _buildStatusLegend(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 20, color: Color(0xFF9CA3AF)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  currentPage = 1;
                });
              },
              decoration: const InputDecoration(
                hintText: "Search months...",
                border: InputBorder.none,
                hintStyle: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceTable(List<MonthlyClassAttendance> currentData) {
    return RawScrollbar(
      controller: _horizontalScrollController,
      thumbColor: const Color(0xFF7E49FF).withOpacity(0.5),
      radius: const Radius.circular(8),
      thickness: 4,
      child: SingleChildScrollView(
        controller: _horizontalScrollController,
        scrollDirection: Axis.horizontal,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            children: [
              _buildAttendanceTableHeader(),
              ...currentData.map((data) => _buildAttendanceTableRow(data)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceTableHeader() {
    const headerStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 13);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFFF3F4F6),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      child: Row(
        children: const [
          SizedBox(width: 120, child: Text("Month", style: headerStyle)),
          SizedBox(
            width: 180,
            child: Text("Attendance Days", style: headerStyle),
          ),
          SizedBox(width: 140, child: Text("Status", style: headerStyle)),
          SizedBox(width: 120, child: Text("Percentage", style: headerStyle)),
          SizedBox(width: 130, child: Text("Action", style: headerStyle)),
        ],
      ),
    );
  }

  Widget _buildAttendanceTableRow(MonthlyClassAttendance data) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          _buildMonthCell(data.monthName),
          _buildDaysCell(data.present, data.total),
          _buildStatusCell(data.present, data.absent),
          _buildPercentageCell(data.percentage),
          _buildActionCell(data),
        ],
      ),
    );
  }

  Widget _buildMonthCell(String name) {
    return SizedBox(
      width: 120,
      child: Row(
        children: [
          const Icon(Icons.calendar_today, size: 14, color: Color(0xFF10B981)),
          const SizedBox(width: 8),
          Text(
            name,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildDaysCell(int present, int total) {
    return SizedBox(
      width: 180,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: total > 0 ? present / total : 0,
              backgroundColor: const Color(0xFFF3F4F6),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFEF4444),
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "$present/$total days",
            style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCell(int present, int absent) {
    const textStyle = TextStyle(fontSize: 13, fontWeight: FontWeight.bold);
    return SizedBox(
      width: 140,
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 16, color: Color(0xFF10B981)),
          const SizedBox(width: 4),
          Text(
            "$present",
            style: textStyle.copyWith(color: const Color(0xFF10B981)),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.cancel, size: 16, color: Color(0xFFEF4444)),
          const SizedBox(width: 4),
          Text(
            "$absent",
            style: textStyle.copyWith(color: const Color(0xFFEF4444)),
          ),
        ],
      ),
    );
  }

  Widget _buildPercentageCell(double percentage) {
    final color = percentage >= 75
        ? const Color(0xFF10B981)
        : const Color(0xFFEF4444);
    return SizedBox(
      width: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${percentage.toStringAsFixed(1)}%",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            percentage >= 75 ? "Excellent" : "Needs Improvement",
            style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCell(MonthlyClassAttendance data) {
    return SizedBox(
      width: 130,
      child: ElevatedButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AttendanceMonthDetailPage(
              monthData: data.rawJson,
              month: data.monthName,
            ),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: const Text(
          "View Details",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildPaginationControls(
    int totalPages,
    int totalItems,
    int startIndex,
    int endIndex,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "${totalItems > 0 ? startIndex + 1 : 0}-$endIndex of $totalItems",
          style: const TextStyle(fontSize: 12, color: Color(0xFF4B5563)),
        ),
        const SizedBox(width: 12),
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_left, size: 20),
          color: currentPage > 1
              ? const Color(0xFF4B5563)
              : const Color(0xFF9CA3AF),
          onPressed: currentPage > 1
              ? () => setState(() => currentPage--)
              : null,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 8),
        ...List.generate(totalPages, (i) => _buildPageNumber(i + 1)),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_right, size: 20),
          color: currentPage < totalPages
              ? const Color(0xFF4B5563)
              : const Color(0xFF9CA3AF),
          onPressed: currentPage < totalPages
              ? () => setState(() => currentPage++)
              : null,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildPageNumber(int pageNum) {
    final active = currentPage == pageNum;
    return GestureDetector(
      onTap: () => setState(() => currentPage = pageNum),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? const Color(0xFF7E49FF) : const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          "$pageNum",
          style: TextStyle(
            color: active ? Colors.white : const Color(0xFF4B5563),
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusLegend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Status Legend",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _legendItem(const Color(0xFF10B981), "Present"),
            const SizedBox(width: 20),
            _legendItem(const Color(0xFFEF4444), "Absent"),
            const SizedBox(width: 20),
            _legendItem(const Color(0xFFF97316), "Leave"),
            const SizedBox(width: 20),
            _legendItem(const Color(0xFF94A3B8), "No Date"),
          ],
        ),
      ],
    );
  }

  Widget _legendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(fontSize: 12, color: Color(0xFF4B5563)),
        ),
      ],
    );
  }

  Widget _buildRecentActivityCard(bool isMobile) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFFEEF0FF),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: const Text(
              "Recent Activity",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _activityRow(
                  icon: Icons.check,
                  iconColor: const Color(0xFF10B981),
                  title: "Overall Attendance",
                  subtitle: "$overallAttendance%\nattendance rate",
                  time: "Updated just now",
                  percentage: "$overallAttendance%",
                ),
                const SizedBox(height: 16),
                _activityRow(
                  icon: Icons.check,
                  iconColor: const Color(0xFFF97316),
                  title: "Best Attendance Streak",
                  subtitle: "$bestStreak consecutive days present",
                  time: "Performance record",
                ),
                const SizedBox(height: 16),
                _activityRow(
                  icon: Icons.check,
                  iconColor: const Color(0xFFF97316),
                  title: "Best Attendance Streak",
                  subtitle: "$bestStreak consecutive days present",
                  time: "Performance record",
                ),
                const SizedBox(height: 24),
                Center(
                  child: TextButton(
                    onPressed: () => _fetchAttendanceData(forceRefresh: true),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.refresh, size: 20, color: Color(0xFF3B82F6)),
                        SizedBox(width: 8),
                        Text(
                          "Refresh Activities",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3B82F6),
                          ),
                        ),
                      ],
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

  Widget _activityRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String time,
    String? percentage,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle),
            child: Icon(icon, size: 16, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    if (percentage != null) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          percentage,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: iconColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF4B5563),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
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
