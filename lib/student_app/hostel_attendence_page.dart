import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import 'package:student_app/student_app/student_app_bar.dart';
import 'package:student_app/student_app/hostel_month_detail_page.dart';
import 'package:student_app/student_app/model/hostel_attendance.dart';
import 'package:student_app/student_app/services/hostel_attendance_service.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class HostelAttendancePage extends StatefulWidget {
  const HostelAttendancePage({super.key});

  @override
  State<HostelAttendancePage> createState() => _HostelAttendancePageState();
}

class _HostelAttendancePageState extends State<HostelAttendancePage> {
  String selectedPeriod = "All Months";
  int currentPage = 1;
  final int itemsPerPage = 10;
  final ScrollController _horizontalScrollController = ScrollController();

  bool _isLoading = true;
  HostelAttendance? _attendanceData;

  String hostelName = "VRB CAMPUS";
  String floor = "4-florr";
  String room = "408";
  String warden = "V.Dhana Lakshmi";

  // Added missing variables
  int currentStreak = 0;
  int bestStreak = 0;
  int leavesTaken = 0;
  int nightOuts = 0;
  double overallAttendance = 0.0;
  int nightsInHostel = 0;
  int nightsAbsent = 0;

  // Track full dataset for filtering
  List<String> _allTrendMonths = [];
  List<double> _allTrendData = [];

  // Variables used in the UI/Chart
  List<String> trendMonths = [];
  List<double> trendData = [];

  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAttendance();
    });
    // Refresh data every 5 minutes
    _refreshTimer = Timer.periodic(const Duration(minutes: 3), (_) {
      _fetchAttendance();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchAttendance() async {
    setState(() => _isLoading = true);

    try {
      final data = await HostelAttendanceService.getHostelAttendance(
        forceRefresh: true,
      );

      if (mounted) {
        setState(() {
          _attendanceData = data;

          hostelName = data.hostelName ?? "N/A";
          floor = data.floorName ?? "N/A";
          room = data.roomName ?? "N/A";
          warden = data.wardenName ?? "N/A";

          currentStreak = data.currentStreak ?? 0;
          bestStreak = data.bestStreak ?? 0;
          leavesTaken = data.totalLeaves ?? 0;
          nightOuts = data.totalNightOuts ?? 0;
          overallAttendance = data.overallPercentage ?? 0.0;
          nightsInHostel = data.totalPresent ?? 0;
          nightsAbsent = data.totalAbsent ?? 0;

          // Extract trend data from monthly attendance
          _allTrendMonths = data.attendance.map((m) {
            if (m.monthName.length >= 3) {
              return m.monthName.substring(0, 3);
            }
            return m.monthName;
          }).toList();
          _allTrendData = data.attendance.map((m) => m.percentage).toList();

          _applyPeriodFilter();
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

  void _applyPeriodFilter() {
    setState(() {
      if (selectedPeriod == "Last 6 Months") {
        trendMonths = _allTrendMonths.length > 6
            ? _allTrendMonths.sublist(_allTrendMonths.length - 6)
            : _allTrendMonths;
        trendData = _allTrendData.length > 6
            ? _allTrendData.sublist(_allTrendData.length - 6)
            : _allTrendData;
      } else if (selectedPeriod == "Last 3 Months") {
        trendMonths = _allTrendMonths.length > 3
            ? _allTrendMonths.sublist(_allTrendMonths.length - 3)
            : _allTrendMonths;
        trendData = _allTrendData.length > 3
            ? _allTrendData.sublist(_allTrendData.length - 3)
            : _allTrendData;
      } else {
        trendMonths = List.from(_allTrendMonths);
        trendData = List.from(_allTrendData);
      }
    });
  }

  String _getPerformanceStatus(double percentage) {
    if (percentage >= 90) return 'Excellent';
    if (percentage >= 75) return 'Good';
    if (percentage >= 60) return 'Average';
    return 'Poor';
  }

  Color _getStatusColor(double percentage) {
    if (percentage >= 90) return const Color(0xFF10B981);
    if (percentage >= 75) return const Color(0xFFF97316);
    if (percentage >= 60) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const StudentAppBar(title: ""),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            final padding = isMobile ? 12.0 : 16.0;

            if (_isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hostel Attendance Dashboard Header Card
                    _buildDashboardHeader(isMobile),
                    SizedBox(height: isMobile ? 12 : 16),

                    // Hostel Details Card
                    _buildHostelDetailsCard(isMobile),
                    SizedBox(height: isMobile ? 12 : 16),

                    // Overall Attendance Card
                    _buildOverallAttendanceCard(isMobile),
                    SizedBox(height: isMobile ? 12 : 16),

                    // Nights in Hostel Card
                    _buildNightsInHostelCard(isMobile),
                    SizedBox(height: isMobile ? 12 : 16),

                    // Current Stay Streak Card
                    _buildCurrentStayStreakCard(isMobile),
                    SizedBox(height: isMobile ? 12 : 16),

                    // Leaves Taken Card
                    _buildLeavesTakenCard(isMobile),
                    SizedBox(height: isMobile ? 12 : 16),

                    // Hostel Attendance Trend Card
                    _buildAttendanceTrendCard(isMobile),
                    SizedBox(height: isMobile ? 12 : 16),

                    // Monthly Hostel Attendance Overview Card
                    _buildMonthlyOverviewCard(isMobile),
                    SizedBox(height: isMobile ? 12 : 16),

                    _buildPerformanceSummaryCard(isMobile),
                    SizedBox(height: isMobile ? 12 : 16),

                    // Recent Activity Card
                    _buildRecentActivityCard(isMobile),
                    SizedBox(height: isMobile ? 12 : 16),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDashboardHeader(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: isMobile ? 40 : 48,
                height: isMobile ? 40 : 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFF2563EB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: isMobile ? 24 : 28,
                ),
              ),
              SizedBox(width: isMobile ? 12 : 16),
              Expanded(
                child: Text(
                  'Hostel Attendance Dashboard',
                  style: TextStyle(
                    fontSize: isMobile ? 22 : 28,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF7C3AED),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 8 : 12),
          Text(
            'Track and analyze your hostel attendance.',
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
              color: const Color(0xFF64748B),
              height: 1.5,
            ),
          ),
          SizedBox(height: isMobile ? 16 : 20),
          isMobile
              ? Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _fetchAttendance,
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text(
                          'Refresh ',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7C3AED),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _downloadAndOpenReport,
                        icon: const Icon(Icons.download, size: 18),
                        label: const Text(
                          'Download Report',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(
                            color: Color(0xFFE2E8F0),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _fetchAttendance,
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text(
                          'Refresh Data',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7C3AED),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _downloadAndOpenReport,
                        icon: const Icon(Icons.download, size: 18),
                        label: const Text(
                          'Download Report',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(
                            color: Color(0xFFE2E8F0),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Future<void> _downloadAndOpenReport() async {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Preparing report...")));

    try {
      final bytes =
          await HostelAttendanceService.downloadHostelAttendanceReport();

      // Save the file
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          "Hostel_Attendance_Report_${DateTime.now().millisecondsSinceEpoch}.pdf";
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(bytes);

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Report downloaded. Opening..."),
            backgroundColor: Colors.green,
          ),
        );

        // Open the file
        await OpenFilex.open(file.path);
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
            content: Text("Failed to download or open: $errorMsg"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Widget _buildHostelDetailsCard(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2FE),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHostelDetailRow(
            Icons.business,
            const Color(0xFF2563EB),
            'Hostel',
            hostelName,
            isMobile,
          ),
          SizedBox(height: isMobile ? 12 : 16),
          _buildHostelDetailRow(
            Icons.check_circle,
            const Color(0xFF10B981),
            'Floor',
            floor,
            isMobile,
          ),
          SizedBox(height: isMobile ? 12 : 16),
          _buildHostelDetailRow(
            Icons.home,
            const Color(0xFF7C3AED),
            'Room',
            room,
            isMobile,
          ),
          SizedBox(height: isMobile ? 12 : 16),
          _buildHostelDetailRow(
            Icons.person,
            const Color(0xFFF97316),
            'Warden',
            warden,
            isMobile,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildHostelDetailRow(
    IconData icon,
    Color iconColor,
    String label,
    String value,
    bool isMobile, {
    bool isLast = false,
  }) {
    return Row(
      children: [
        Container(
          width: isMobile ? 36 : 40,
          height: isMobile ? 36 : 40,
          decoration: BoxDecoration(
            color: iconColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: isMobile ? 20 : 24),
        ),
        SizedBox(width: isMobile ? 12 : 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: isMobile ? 11 : 12,
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: isMobile ? 2 : 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverallAttendanceCard(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overall Attendance',
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 8 : 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '%',
                  style: TextStyle(
                    fontSize: isMobile ? 24 : 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: isMobile ? 8 : 12),
              Flexible(
                child: Text(
                  '${_attendanceData?.overallPercentage ?? 0.0}',
                  style: TextStyle(
                    fontSize: isMobile ? 36 : 48,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF10B981),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 12 : 16),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 10 : 12,
              vertical: isMobile ? 6 : 8,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFD1FAE5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  size: isMobile ? 14 : 16,
                  color: const Color(0xFF10B981),
                ),
                SizedBox(width: isMobile ? 4 : 6),
                Flexible(
                  child: Text(
                    'Based on ${_attendanceData?.totalDays ?? 0} recorded nights',
                    style: TextStyle(
                      fontSize: isMobile ? 11 : 12,
                      color: const Color(0xFF059669),
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNightsInHostelCard(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: isMobile ? 36 : 40,
                height: isMobile ? 36 : 40,
                decoration: const BoxDecoration(
                  color: Color(0xFF2563EB),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: isMobile ? 20 : 24,
                ),
              ),
              SizedBox(width: isMobile ? 10 : 12),
              Text(
                'Nights in Hostel',
                style: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 12 : 16),
          Text(
            '${_attendanceData?.totalPresent ?? 0}/${_attendanceData?.totalDays ?? 0}',
            style: TextStyle(
              fontSize: isMobile ? 28 : 36,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2563EB),
            ),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 10 : 12,
              vertical: isMobile ? 6 : 8,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2FE),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.person_outline,
                  size: isMobile ? 14 : 16,
                  color: const Color(0xFF2563EB),
                ),
                SizedBox(width: isMobile ? 4 : 6),
                Flexible(
                  child: Text(
                    '${_attendanceData?.totalAbsent ?? 0} nights absent',
                    style: TextStyle(
                      fontSize: isMobile ? 11 : 12,
                      color: const Color(0xFF1E40AF),
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStayStreakCard(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: isMobile ? 36 : 40,
                height: isMobile ? 36 : 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.local_fire_department,
                  color: Colors.white,
                  size: isMobile ? 20 : 24,
                ),
              ),
              SizedBox(width: isMobile ? 10 : 12),
              Text(
                'Current Stay Streak',
                style: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 12 : 16),
          Text(
            '$currentStreak nights',
            style: TextStyle(
              fontSize: isMobile ? 28 : 36,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF7C3AED),
            ),
          ),
          SizedBox(height: isMobile ? 10 : 12),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 10 : 12,
              vertical: isMobile ? 6 : 8,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFEDE9FE),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.emoji_events,
                  size: isMobile ? 14 : 16,
                  color: const Color(0xFF7C3AED),
                ),
                SizedBox(width: isMobile ? 4 : 6),
                Flexible(
                  child: Text(
                    'Best streak: $bestStreak nights',
                    style: TextStyle(
                      fontSize: isMobile ? 11 : 12,
                      color: const Color(0xFF6D28D9),
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeavesTakenCard(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: isMobile ? 36 : 40,
                height: isMobile ? 36 : 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF97316),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.calendar_today,
                  color: Colors.white,
                  size: isMobile ? 20 : 24,
                ),
              ),
              SizedBox(width: isMobile ? 10 : 12),
              Text(
                'Leaves Taken',
                style: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 12 : 16),
          Text(
            '$leavesTaken nights',
            style: TextStyle(
              fontSize: isMobile ? 28 : 36,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFF97316),
            ),
          ),
          SizedBox(height: isMobile ? 10 : 12),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 10 : 12,
              vertical: isMobile ? 6 : 8,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.home_outlined,
                  size: isMobile ? 14 : 16,
                  color: const Color(0xFFF97316),
                ),
                SizedBox(width: isMobile ? 4 : 6),
                Flexible(
                  child: Text(
                    '$nightOuts night outs recorded',
                    style: TextStyle(
                      fontSize: isMobile ? 11 : 12,
                      color: const Color(0xFFD97706),
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceTrendCard(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.bar_chart,
                          size: 18,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Hostel Attendance Trend',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        setState(() {
                          selectedPeriod = value;
                          _applyPeriodFilter();
                        });
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: "All Months",
                          child: Text("All Months"),
                        ),
                        const PopupMenuItem(
                          value: "Last 6 Months",
                          child: Text("Last 6 Months"),
                        ),
                        const PopupMenuItem(
                          value: "Last 3 Months",
                          child: Text("Last 3 Months"),
                        ),
                      ],
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                selectedPeriod,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF1E293B),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_drop_down,
                              size: 16,
                              color: Color(0xFF1E293B),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.bar_chart,
                          size: 20,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Hostel Attendance Trend',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        setState(() {
                          selectedPeriod = value;
                          _applyPeriodFilter();
                        });
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: "All Months",
                          child: Text("All Months"),
                        ),
                        const PopupMenuItem(
                          value: "Last 6 Months",
                          child: Text("Last 6 Months"),
                        ),
                        const PopupMenuItem(
                          value: "Last 3 Months",
                          child: Text("Last 3 Months"),
                        ),
                      ],
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              selectedPeriod,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_drop_down,
                              size: 18,
                              color: Color(0xFF1E293B),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
          SizedBox(height: isMobile ? 16 : 24),
          SizedBox(
            height: isMobile ? 160 : 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 25,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: const Color(0xFFE2E8F0),
                      strokeWidth: 1,
                    );
                  },
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
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 &&
                            value.toInt() < trendMonths.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              trendMonths[value.toInt()],
                              style: TextStyle(
                                fontSize: isMobile ? 9 : 10,
                                color: const Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: isMobile ? 35 : 40,
                      interval: 25,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}%',
                          style: TextStyle(
                            fontSize: isMobile ? 9 : 10,
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: trendData.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(), e.value);
                    }).toList(),
                    isCurved: true,
                    color: const Color(0xFF2563EB),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                    ),
                  ),
                ],
                minY: 0,
                maxY: 100,
              ),
            ),
          ),
          SizedBox(height: isMobile ? 8 : 12),
          Text(
            'Showing ${trendData.length} months of hostel attendance data ($selectedPeriod)',
            style: TextStyle(
              fontSize: isMobile ? 10 : 12,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceSummaryCard(bool isMobile) {
    // Determine colors based on overall attendance
    final statusColor = _getStatusColor(overallAttendance);
    final statusText = _getPerformanceStatus(overallAttendance);

    // Status Pill Background Color (Light version of status color)
    Color statusBgColor;
    if (overallAttendance >= 90) {
      statusBgColor = const Color(0xFFD1FAE5); // Light Green
    } else if (overallAttendance >= 75) {
      statusBgColor = const Color(0xFFFFEDD5); // Light Orange
    } else if (overallAttendance >= 60) {
      statusBgColor = const Color(0xFFFEF3C7); // Light Amber
    } else {
      statusBgColor = const Color(0xFFFFE4E6); // Light Red
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(
                Icons.emoji_events,
                size: 20,
                color: Color(0xFFF59E0B),
              ),
              const SizedBox(width: 8),
              Text(
                'Performance Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Content Row (Chart + Status)
          Row(
            children: [
              // Circular Chart
              SizedBox(
                width: 140,
                height: 140,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 140,
                      height: 140,
                      child: CircularProgressIndicator(
                        value: overallAttendance / 100,
                        strokeWidth: 12,
                        backgroundColor: const Color(0xFFE5E7EB),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getStatusColor(overallAttendance),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${overallAttendance.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF7C3AED),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Attendance',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 24),

              // Status Pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText == 'Poor' ? 'Needs Improvement' : statusText,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Stats Grid (2x2)
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      label: 'Days Present',
                      value: '$nightsInHostel',
                      color: const Color(0xFF10B981), // Green
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatItem(
                      label: 'Days Absent',
                      value: '$nightsAbsent',
                      color: const Color(0xFFEF4444), // Red
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      label: 'Leaves Taken',
                      value: '$leavesTaken',
                      color: const Color(0xFFF97316), // Orange
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatItem(
                      label: 'Night Outs',
                      value: '$nightOuts',
                      color: const Color(0xFF8B5CF6), // Purple
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyOverviewCard(bool isMobile) {
    if (_attendanceData == null || _attendanceData!.attendance.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: const Center(child: Text("No monthly data available")),
      );
    }

    final dataList = _attendanceData!.attendance;
    final startIndex = (currentPage - 1) * itemsPerPage;
    final endIndex = math.min(startIndex + itemsPerPage, dataList.length);
    final currentItems = dataList.sublist(startIndex, endIndex);
    (dataList.length / itemsPerPage).ceil();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_month,
                size: 20,
                color: Color(0xFF64748B),
              ),
              const SizedBox(width: 8),
              const Text(
                'Monthly Hostel Attendance Overview',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 16 : 24),

          // Horizontal Scroll View
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: _horizontalScrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: currentItems
                  .map((data) => _buildMonthlyRow(data, isMobile))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyRow(MonthlyAttendance data, bool isMobile) {
    final percentage = data.percentage;
    final attended = data.present;
    final total = data.total;
    final progress = total > 0 ? attended / total : 0.0;
    final status = _getPerformanceStatus(percentage);

    Color color = _getStatusColor(percentage);

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 12 : 16,
        horizontal: isMobile ? 12 : 16,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: const Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: isMobile ? 14 : 16,
                  color: const Color(0xFF10B981),
                ),
                SizedBox(width: isMobile ? 4 : 8),
                Expanded(
                  child: Text(
                    data.monthName,
                    style: TextStyle(
                      fontSize: isMobile ? 10 : 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1E293B),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 140),
          SizedBox(
            width: 140,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: isMobile ? 6 : 8,
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                SizedBox(height: isMobile ? 2 : 4),
                Text(
                  '$attended/$total nights',
                  style: TextStyle(
                    fontSize: isMobile ? 10 : 11,
                    color: const Color(0xFF64748B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: 100),
          SizedBox(
            width: 140,
            child: Wrap(
              spacing: isMobile ? 4 : 6,
              runSpacing: 4,
              children: [
                _buildStatusIcon(
                  Icons.check_circle,
                  data.present,
                  const Color(0xFF10B981),
                  isMobile,
                ),
                _buildStatusIcon(
                  Icons.cancel,
                  data.absent,
                  const Color(0xFFEF4444),
                  isMobile,
                ),
                _buildStatusIcon(
                  Icons.calendar_today,
                  (data.rawJson['leaves'] ?? 0) as int,
                  const Color(0xFFF59E0B),
                  isMobile,
                ),
                _buildStatusIcon(
                  Icons.apartment,
                  (data.rawJson['holidays'] ?? 0) as int,
                  const Color(0xFF2563EB),
                  isMobile,
                ),
                _buildStatusIcon(
                  Icons.home,
                  (data.rawJson['nightOuts'] ?? 0) as int,
                  const Color(0xFF7C3AED),
                  isMobile,
                ),
              ],
            ),
          ),
          SizedBox(width: 100),
          SizedBox(
            width: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: isMobile ? 2 : 4),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: isMobile ? 10 : 12,
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: 120),
          SizedBox(
            width: 120,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HostelMonthDetailPage(
                      monthData: data,
                      overallData: _attendanceData,
                    ),
                  ),
                );
              },
              icon: Icon(
                Icons.visibility,
                size: isMobile ? 14 : 16,
                color: Colors.white,
              ),
              label: Text(
                isMobile ? 'View' : 'View Details',
                style: TextStyle(
                  fontSize: isMobile ? 10 : 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 8 : 12,
                  vertical: isMobile ? 6 : 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(
    IconData icon,
    int count,
    Color color,
    bool isMobile,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: isMobile ? 12 : 16, color: color),
        SizedBox(width: isMobile ? 2 : 4),
        Text(
          '$count',
          style: TextStyle(
            fontSize: isMobile ? 9 : 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivityCard(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: isMobile ? 18 : 20,
                color: const Color(0xFF7C3AED),
              ),
              SizedBox(width: isMobile ? 6 : 8),
              Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 12 : 16),
          _buildActivityItem(
            Icons.remove_circle,
            _getStatusColor(overallAttendance),
            'Overall Hostel Attendance',
            '$overallAttendance% attendance rate',
            'Updated just now',
            '$overallAttendance%',
            isMobile,
          ),
          _buildActivityItem(
            Icons.emoji_events,
            const Color(0xFFF97316),
            'Best Stay Streak',
            '$bestStreak consecutive nights in hostel',
            'Previous record',
            null,
            isMobile,
          ),
          _buildActivityItem(
            Icons.local_fire_department,
            const Color(0xFF7C3AED),
            'Current Stay Streak',
            '$currentStreak consecutive nights in hostel',
            'Active now',
            null,
            isMobile,
          ),
          if (_attendanceData != null &&
              _attendanceData!.attendance.isNotEmpty) ...[
            _buildActivityItem(
              Icons.trending_up,
              _getStatusColor(_attendanceData!.attendance.first.percentage),
              '${_attendanceData!.attendance.first.monthName} Hostel Attendance',
              '${_attendanceData!.attendance.first.present} present, ${_attendanceData!.attendance.first.absent} absent',
              'Monthly Summary',
              '${_attendanceData!.attendance.first.percentage.toStringAsFixed(1)}%',
              isMobile,
              showViewDetails: true,
            ),
          ],
          SizedBox(height: isMobile ? 12 : 16),
          Center(
            child: TextButton.icon(
              onPressed: () {},
              icon: Icon(
                Icons.refresh,
                size: isMobile ? 14 : 16,
                color: const Color(0xFF2563EB),
              ),
              label: Text(
                'Refresh Activities',
                style: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                  color: const Color(0xFF2563EB),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    IconData icon,
    Color color,
    String title,
    String details,
    String status,
    String? value,
    bool isMobile, {
    String? date,
    bool showViewDetails = false,
    bool isLast = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : (isMobile ? 12 : 16)),
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: isMobile ? 36 : 40,
            height: isMobile ? 36 : 40,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: isMobile ? 18 : 20),
          ),
          SizedBox(width: isMobile ? 10 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: isMobile ? 2 : 4),
                Text(
                  details,
                  style: TextStyle(
                    fontSize: isMobile ? 11 : 12,
                    color: const Color(0xFF64748B),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: isMobile ? 2 : 4),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: isMobile ? 10 : 11,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
                if (date != null) ...[
                  SizedBox(height: isMobile ? 2 : 4),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: isMobile ? 10 : 11,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
                if (showViewDetails) ...[
                  SizedBox(height: isMobile ? 6 : 8),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HostelMonthDetailPage(
                            monthData: _attendanceData!.attendance.first,
                            overallData: _attendanceData,
                          ),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'View Details',
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 12,
                        color: const Color(0xFF2563EB),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (value != null)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 8 : 12,
                vertical: isMobile ? 4 : 6,
              ),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
