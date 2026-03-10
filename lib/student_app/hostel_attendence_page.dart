import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import 'package:student_app/student_app/hostel_month_detail_page.dart';
import 'package:student_app/student_app/model/hostel_attendance.dart';
import 'package:student_app/student_app/services/hostel_attendance_service.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_app/student_app/widgets/student_app_header.dart';

class HostelAttendancePage extends StatefulWidget {
  const HostelAttendancePage({super.key});

  @override
  State<HostelAttendancePage> createState() => _HostelAttendancePageState();
}

class _HostelAttendancePageState extends State<HostelAttendancePage> {
  String selectedPeriod = "All Months";
  int currentPage = 1;
  int itemsPerPage = 10;
  bool _isLoading = false;
  String _searchQuery = "";
  final ScrollController _horizontalScrollController = ScrollController();

  HostelAttendance? _attendanceData;

  String branchName = "N/A";
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
    _loadStoredUserData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAttendance();
    });
    // Refresh data every 3 minutes
    _refreshTimer = Timer.periodic(const Duration(minutes: 3), (_) {
      _fetchAttendance();
    });
  }

  Future<void> _loadStoredUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        branchName = prefs.getString('branch') ?? "N/A";
      });
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchAttendance({bool showLoading = true}) async {
    if (showLoading && mounted) {
      setState(() => _isLoading = true);
    }

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
        
        if (!showLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Hostel attendance refreshed"),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 1),
            ),
          );
        }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const StudentAppHeader(title: "Hostel Attendance"),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 20.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Hostel Attendance',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E1E1E),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Track and analyze your hostel attendance',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF666666),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildActionButtons(),
                          const SizedBox(height: 20),
                          _buildHostelInfoCard(),
                          const SizedBox(height: 16),
                          _buildStatCard(
                            title: 'Overall Attendance',
                            value: '${overallAttendance.toStringAsFixed(1)}%',
                            pillText: 'Based on 365 recorded days',
                            pillColor: const Color(0xFFE8F5E9),
                            pillTextColor: const Color(0xFF43A047),
                            valueColor: const Color(0xFF43A047),
                          ),
                          const SizedBox(height: 16),
                          _buildStatCard(
                            title: 'Night in Hostel',
                            value: '$nightsInHostel/365',
                            pillText: '$nightsAbsent nights absent',
                            pillColor: const Color(0xFFE3F2FD),
                            pillTextColor: const Color(0xFF2196F3),
                            valueColor: const Color(0xFF2196F3),
                          ),
                          const SizedBox(height: 16),
                          _buildStatCard(
                            title: 'Current Stay Streak',
                            value: '$currentStreak nights',
                            pillText: 'Best streak: $bestStreak days',
                            pillColor: const Color(0xFFF3E5F5),
                            pillTextColor: const Color(0xFF9C27B0),
                            valueColor: const Color(0xFF9C27B0),
                          ),
                          const SizedBox(height: 16),
                          _buildStatCard(
                            title: 'Leaves Taken',
                            value: '$leavesTaken nights',
                            pillText: '$nightOuts night outs recorded',
                            pillColor: const Color(0xFFFFF3E0),
                            pillTextColor: const Color(0xFFF57C00),
                            valueColor: const Color(0xFFF57C00),
                          ),
                          const SizedBox(height: 20),
                          _buildAttendanceTrendCard(context),
                          const SizedBox(height: 20),
                          _buildMonthlyOverviewCard(),
                          const SizedBox(height: 20),
                          _buildPerformanceSummaryCard(),
                          const SizedBox(height: 20),
                          _buildRecentActivityCard(),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }



  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 40,
              width: 20,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFFC084FC)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ElevatedButton.icon(
                onPressed: () => _fetchAttendance(showLoading: false),
                icon: const Icon(Icons.refresh, size: 16, color: Colors.white),
                label: const Text(
                  'Refresh',
                  style: TextStyle(
                    fontSize: 13,
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
                onPressed: _downloadAndOpenReport,
                icon: const Icon(Icons.print, size: 16, color: Colors.white),
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
    );
  }

  Widget _buildHostelInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            Icons.apartment,
            const Color(0xFF1E88E5),
            'Hostel',
            hostelName,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.check_circle,
            const Color(0xFF43A047),
            'Floor',
            floor.toUpperCase(),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.home, const Color(0xFF7E57C2), 'Room', room),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.person,
            const Color(0xFFF57C00),
            'Warden',
            warden,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    Color iconColor,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF666666),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E1E),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String pillText,
    required Color pillColor,
    required Color pillTextColor,
    required Color valueColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: pillColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, size: 14, color: pillTextColor),
                const SizedBox(width: 4),
                Text(
                  pillText,
                  style: TextStyle(
                    fontSize: 11,
                    color: pillTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
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
        await OpenFilex.open(file.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        String errorMsg = e.toString();
        if (errorMsg.contains('MissingPluginException')) {
          errorMsg = "App restart required to activate download plugin.";
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to download: $errorMsg"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildAttendanceTrendCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              color: Color(0xFFEDE7F6),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Attendance Trend',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        selectedPeriod == "All Months"
                            ? "All Monthly"
                            : selectedPeriod,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        size: 18,
                        color: Colors.black87,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              height: 220,
              width: double.infinity,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.withOpacity(0.2),
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 25,
                        getTitlesWidget: (value, meta) => Text(
                          '${value.toInt()}%',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        reservedSize: 35,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: math.max(1, (trendData.length - 1).toDouble()),
                  minY: 0,
                  maxY: 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots: trendData.isNotEmpty
                          ? trendData
                                .asMap()
                                .entries
                                .map((e) => FlSpot(e.key.toDouble(), e.value))
                                .toList()
                          : [const FlSpot(0, 0)],
                      isCurved: true,
                      curveSmoothness: 0.35,
                      color: const Color(0xFF3B82F6),
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceSummaryCard() {
    const statusBgColor = Color(0xFFFFEBEE);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEEEEEE), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: const BoxDecoration(
              color: Color(0xFFEDE7F6),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: const Row(
              children: [
                Text(
                  'Performance Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Center(
                            child: SizedBox(
                              width: 110,
                              height: 110,
                              child: CircularProgressIndicator(
                                value: 1.0,
                                strokeWidth: 12,
                                backgroundColor: Colors.transparent,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.grey.shade300,
                                ),
                              ),
                            ),
                          ),
                          Center(
                            child: SizedBox(
                              width: 110,
                              height: 110,
                              child: CircularProgressIndicator(
                                value: overallAttendance / 100,
                                strokeWidth: 12,
                                backgroundColor: Colors.transparent,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  const Color(0xFFEF5350),
                                ),
                                strokeCap: StrokeCap.round,
                              ),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${overallAttendance.toStringAsFixed(1)}%',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Color(0xFF7E57C2),
                                ),
                              ),
                              const Text(
                                'Attendance',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusBgColor,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Text(
                          'Needs Improvement',
                          style: TextStyle(
                            color: Color(0xFFEF5350),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 15,
                  childAspectRatio: 1.1,
                  children: [
                    _buildSimpleStatBox(
                      'Days Present',
                      nightsInHostel.toString(),
                      const Color(0xFF00B894),
                    ),
                    _buildSimpleStatBox(
                      'Days Absent',
                      nightsAbsent.toString(),
                      const Color(0xFFEF5350),
                    ),
                    _buildSimpleStatBox(
                      'Leaves Taken',
                      leavesTaken.toString(),
                      const Color(0xFFFB8C00),
                    ),
                    _buildSimpleStatBox(
                      'Leaves Remaining',
                      '0',
                      const Color(0xFF7E57C2),
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

  Widget _buildSimpleStatBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12), // Slightly reduced padding for safety
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFEEEEEE), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          const Spacer(),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF424242),
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyOverviewCard() {
    final List<MonthlyAttendance> dataList = _attendanceData?.attendance ?? [];
    final List<MonthlyAttendance> filteredData = dataList
        .where(
          (m) => m.monthName.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();

    final int startIndex = (currentPage - 1) * itemsPerPage;
    final int endIndex = math.min(
      startIndex + itemsPerPage,
      filteredData.length,
    );
    final List<MonthlyAttendance> currentData = filteredData.isEmpty
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
              "Monthly hostel attendance overview",
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

  Widget _buildAttendanceTable(List<MonthlyAttendance> currentData) {
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
            child: Text("Attendance Nights", style: headerStyle),
          ),
          SizedBox(width: 140, child: Text("Status", style: headerStyle)),
          SizedBox(width: 120, child: Text("Percentage", style: headerStyle)),
          SizedBox(width: 130, child: Text("Action", style: headerStyle)),
        ],
      ),
    );
  }

  Widget _buildAttendanceTableRow(MonthlyAttendance data) {
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
            "$present/$total nights",
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

  Widget _buildActionCell(MonthlyAttendance data) {
    return SizedBox(
      width: 130,
      child: ElevatedButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HostelMonthDetailPage(
              monthData: data,
              overallData: _attendanceData,
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

  Widget _buildRecentActivityCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEEEEEE), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: const BoxDecoration(
              color: Color(0xFFEDE7F6),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: const Row(
              children: [
                Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildActivityItem(
                  icon: Icons.bar_chart,
                  iconColor: const Color(0xFF00B894), // Green
                  title: 'Overall Attendance',
                  titleExtra: '${overallAttendance.toStringAsFixed(1)}%',
                  subtitle:
                      '${overallAttendance.toStringAsFixed(1)}% \nattendance rate',
                  status: 'Updated just now',
                ),
                _buildActivityItem(
                  icon: Icons.local_fire_department,
                  iconColor: const Color(0xFFFB8C00), // Orange
                  title: 'Best Attendance Streak',
                  subtitle: '$bestStreak consecutive days present',
                  status: 'Performance record',
                ),
                _buildActivityItem(
                  icon: Icons.nightlight_outlined,
                  iconColor: const Color(0xFF7E57C2), // Purple
                  title: 'Total Night Outs',
                  subtitle: '$nightOuts recorded night outs',
                  status: 'Based on attendance',
                ),
                const SizedBox(height: 10),
                Center(
                  child: TextButton.icon(
                    onPressed: _fetchAttendance,
                    icon: const Icon(
                      Icons.refresh,
                      size: 20,
                      color: Colors.blue,
                    ),
                    label: const Text(
                      'Refresh Activities',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
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

  Widget _buildActivityItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? titleExtra,
    required String subtitle,
    required String status,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFEEEEEE), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                    if (titleExtra != null) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          titleExtra,
                          style: TextStyle(
                            color: iconColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
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
                    color: Color(0xFF757575),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF757575),
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
