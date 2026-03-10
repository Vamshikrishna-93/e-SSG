import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:student_app/student_app/upcoming_exams_page.dart';
import 'package:student_app/student_app/widgets/dashboard_widgets.dart';
import 'package:student_app/student_app/student_calendar.dart';
import 'package:student_app/student_app/announcement_page.dart';
import 'package:student_app/student_app/studentdrawer.dart';
import 'package:student_app/student_app/widgets/loading_animation.dart';
import 'package:student_app/student_app/services/dashboard_controller.dart';
import 'package:student_app/staff_app/controllers/auth_controller.dart';
import 'package:student_app/student_app/widgets/student_bottom_nav.dart';
import 'package:student_app/student_app/services/documents_controller.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final DashboardController _controller;

  final List<String> _rangeOptions = [
    "This Month",
    "3 Months",
    "6 Months",
    "Academic Year",
  ];

  // Helper to map a range string to the TimeRange enum for the chart widget
  TimeRange _toTimeRange(String rangeStr) {
    switch (rangeStr) {
      case "This Month":
        return TimeRange.lastMonth;
      case "3 Months":
        return TimeRange.last3Months;
      case "6 Months":
        return TimeRange.last6Months;
      case "Academic Year":
      default:
        return TimeRange.academicYear;
    }
  }

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<DashboardController>()) {
      Get.put(DashboardController(), permanent: true);
    }
    _controller = Get.find<DashboardController>();

    // 🏆 ONLY show the success snackbar when explicitly logging in
    final isLogin = Get.arguments?['isLogin'] ?? false;
    if (isLogin) {
      if (Get.isRegistered<DocumentsController>()) {
        Get.find<DocumentsController>().fetchDocuments(
          forceRefresh: true,
          showSnackbar: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_controller.isLoading.value) {
        return const Scaffold(body: Center(child: StudentLoadingAnimation()));
      }

      return Scaffold(
        key: _scaffoldKey,
        drawer: const StudentDrawerPage(),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF7C3FE3), // Primary color from XML
                Color(0xFF7C3FE3).withOpacity(0.8), // Smooth transition
                Color(0xFFF3F4FB), // Lightest lavender/white
                Color(0xFFF5F5FA), // Soft background tint
              ],
              stops: [0.0, 0.28, 0.45, 1.0],
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      // Wrap reactive sections in Obx so they rebuild on data changes
                      Obx(() => _buildAttendanceGrid()),
                      const SizedBox(height: 16),
                      Obx(() => _buildExamStats()),
                      const SizedBox(height: 16),
                      Obx(() => _buildRankState()),
                      const SizedBox(height: 16),
                      _buildTimeTable(),
                      const SizedBox(height: 16),
                      Obx(() => _buildClassAttendance()),
                      const SizedBox(height: 16),
                      Obx(() => _buildHostelAttendance()),
                      const SizedBox(height: 16),
                      Obx(() => _buildRemarks()),
                      const SizedBox(height: 16),
                      Obx(() => _buildAnnouncements()),
                      const SizedBox(height: 16),
                      Obx(() => _buildUpcomingExams()),
                      const SizedBox(height: 16),
                      _buildCalendar(),
                      const SizedBox(height: 16),
                      _buildEventsThisMonth(),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: const StudentBottomNav(currentIndex: 0),
        extendBody: true,
      );
    });
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 45, 16, 12),
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => _scaffoldKey.currentState?.openDrawer(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.menu_open,
                    color: Color(0xFF7C3AED), // Match dominant purple
                    size: 24,
                  ),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.search, color: Colors.white, size: 28),
                  const SizedBox(width: 16),
                  Obx(() {
                    final hasAnnouncements =
                        _controller.announcements.isNotEmpty;
                    return Stack(
                      children: [
                        const Icon(
                          Icons.notifications_none,
                          color: Colors.white,
                          size: 28,
                        ),
                        if (hasAnnouncements)
                          Positioned(
                            right: 4,
                            top: 4,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    );
                  }),
                  const SizedBox(width: 16),
                  PopupMenuButton<String>(
                    offset: const Offset(0, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    onSelected: (value) {
                      if (value == 'profile') {
                        Get.offNamed('/studentProfile');
                      } else if (value == 'logout') {
                        Get.find<AuthController>().logout();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'profile',
                        child: Row(
                          children: [
                            Icon(
                              Icons.person_outline,
                              color: Color(0xFF7C3AED),
                            ),
                            SizedBox(width: 12),
                            Text(
                              "Profile",
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(Icons.logout, color: Colors.redAccent),
                            SizedBox(width: 12),
                            Text(
                              "Logout",
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            "Student Dashboard",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceGrid() {
    // Derive totals by summing across all monthly class attendance data
    int totalDays = 0;
    int totalPresent = 0;
    int totalAbsent = 0;
    int totalOutings = 0;
    int totalHolidays = 0;

    for (final entry in _controller.classChartData) {
      totalDays += (entry['total'] ?? 0) as int;
      totalPresent += (entry['present'] ?? 0) as int;
      totalAbsent += (entry['absent'] ?? 0) as int;
      totalOutings += (entry['outings'] ?? 0) as int;
      totalHolidays += (entry['holidays'] ?? 0) as int;
    }

    // If no chart data yet, show dashes as placeholders
    final bool hasData = _controller.classChartData.isNotEmpty;

    String fmt(int v) => hasData ? v.toString() : "--";

    return DashboardSection(
      title: "Attendance",
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ModernStatCard(
                    title: "Total Days",
                    value: fmt(totalDays),
                    icon: Icons.calendar_month,
                    gradientColors: const [
                      Color(0xFF3B82F6),
                      Color(0xFF2563EB),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ModernStatCard(
                    title: "Present",
                    value: fmt(totalPresent),
                    icon: Icons.calendar_today,
                    gradientColors: const [
                      Color(0xFF22C55E),
                      Color(0xFF15803D),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ModernStatCard(
                    title: "Absent",
                    value: fmt(totalAbsent),
                    icon: Icons.calendar_today_outlined,
                    gradientColors: const [
                      Color(0xFFEF4444),
                      Color(0xFFB91C1C),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ModernStatCard(
                    title: "Outing",
                    value: fmt(totalOutings),
                    icon: Icons.directions_walk,
                    gradientColors: const [
                      Color(0xFF06B6D4),
                      Color(0xFF0E7490),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ModernStatCard(
                    title: "Holidays",
                    value: fmt(totalHolidays),
                    icon: Icons.calendar_today,
                    gradientColors: const [
                      Color(0xFFEAB308),
                      Color(0xFFB45309),
                    ],
                  ),
                ),
                const Expanded(child: SizedBox()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExamStats() {
    final stats = _controller.examStats;
    return DashboardSection(
      title: "Exam Stats",
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.6,
          children: [
            ModernStatCard(
              title: "Total Questions",
              value: stats['totalQuestions']?.toString() ?? "200",
              icon: Icons.assignment,
              gradientColors: const [Color(0xFF6366F1), Color(0xFF4338CA)],
            ),
            ModernStatCard(
              title: "Attempted",
              value: stats['attempted']?.toString() ?? "150",
              icon: Icons.check_circle,
              gradientColors: const [Color(0xFF10B981), Color(0xFF059669)],
            ),
            ModernStatCard(
              title: "Not Attempted",
              value: stats['notAttempted']?.toString() ?? "50",
              icon: Icons.cancel,
              gradientColors: const [Color(0xFFF59E0B), Color(0xFFD97706)],
            ),
            ModernStatCard(
              title: "+ve Questions",
              value: stats['positive']?.toString() ?? "120",
              icon: Icons.add_circle,
              gradientColors: const [Color(0xFF06B6D4), Color(0xFF0891B2)],
            ),
            ModernStatCard(
              title: "-ve Questions",
              value: stats['negative']?.toString() ?? "30",
              icon: Icons.remove_circle,
              gradientColors: const [Color(0xFFEF4444), Color(0xFFDC2626)],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankState() {
    final stats = _controller.examStats;
    return DashboardSection(
      title: "Rank State",
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.6,
          children: [
            ModernStatCard(
              title: "Overall Rank",
              value: stats['overallRank']?.toString() ?? "12",
              icon: Icons.emoji_events,
              gradientColors: const [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
            ),
            ModernStatCard(
              title: "Branch Rank",
              value: stats['branchRank']?.toString() ?? "3",
              icon: Icons.account_tree,
              gradientColors: const [Color(0xFFEC4899), Color(0xFFDB2777)],
            ),
            ModernStatCard(
              title: "Group Rank",
              value: stats['groupRank']?.toString() ?? "5",
              icon: Icons.groups,
              gradientColors: const [Color(0xFFF97316), Color(0xFFEA580C)],
            ),
            ModernStatCard(
              title: "Course Rank",
              value: stats['courseRank']?.toString() ?? "8",
              icon: Icons.school,
              gradientColors: const [Color(0xFF06B6D4), Color(0xFF0891B2)],
            ),
            ModernStatCard(
              title: "Batch Rank",
              value: stats['batchRank']?.toString() ?? "2",
              icon: Icons.layers,
              gradientColors: const [Color(0xFF6366F1), Color(0xFF4F46E5)],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeTable() {
    return DashboardSection(
      title: "Time Table",
      child: Column(
        children: [
          ModernTimeTableItem(
            subject: "Maths",
            time: "09:00 - 09:45",
            instructor: "Mr. Ramesh",
            accentColor: Color(0xFF3B82F6),
          ),
          ModernTimeTableItem(
            subject: "Physics",
            time: "09:50 - 10:35",
            instructor: "Ms. Anjali",
            accentColor: Color(0xFF06B6D4),
          ),
          ModernTimeTableItem(
            subject: "Chemistry",
            time: "10:40 - 11:25",
            instructor: "Dr. Suresh",
            accentColor: Color(0xFF06B6D4),
          ),
        ],
      ),
    );
  }

  Widget _buildClassAttendance() {
    return DashboardSection(
      title: "Class Attendance",
      actions: [
        _buildYearPill(_controller.classRange.value, (range) {
          _controller.updateClassRange(range);
        }),
      ],
      child: AttendanceChart(
        months: List<String>.from(_controller.classChartMonths),
        maxValue: 35,
        data: List<Map<String, dynamic>>.from(_controller.classChartData),
        selectedRange: _toTimeRange(_controller.classRange.value),
      ),
    );
  }

  Widget _buildHostelAttendance() {
    return DashboardSection(
      title: "Hostel Attendance",
      actions: [
        _buildYearPill(_controller.hostelRange.value, (range) {
          _controller.updateHostelRange(range);
        }),
      ],
      child: AttendanceChart(
        months: List<String>.from(_controller.hostelChartMonths),
        maxValue: 35,
        data: List<Map<String, dynamic>>.from(_controller.hostelChartData),
        selectedRange: _toTimeRange(_controller.hostelRange.value),
        isHostel: true,
      ),
    );
  }

  Widget _buildRemarks() {
    return DashboardSection(
      title: "Remarks",
      child: _controller.remarks.isEmpty
          ? const _EmptyState(message: "No Remarks yet")
          : Column(
              children: _controller.remarks.map((r) {
                final remark = r['remark']?.toString() ?? "No Remark";
                final relatedTo = r['related_to']?.toString() ?? "General";
                final createdAt = r['created_at']?.toString() ?? "";

                String dateStr = "";
                if (createdAt.length >= 10) {
                  dateStr = createdAt.substring(0, 10);
                }

                return DashboardListItem(
                  title: remark,
                  subtitle: "$relatedTo • $dateStr",
                  icon: Icons.comment_rounded,
                  iconBgColor: const Color(0xFFF59E0B),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildAnnouncements() {
    return DashboardSection(
      title: "Announcement",
      child: Column(
        children: [
          ..._controller.announcements.map(
            (a) => DashboardListItem(
              title: a['message'],
              subtitle: a['department'],
              icon: Icons.campaign,
              iconBgColor: a['color'],
            ),
          ),
          ViewAllButton(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AnnouncementsDialog(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingExams() {
    return DashboardSection(
      title: "Upcoming Exams",
      child: Column(
        children: [
          ..._controller.exams.map(
            (e) => DashboardListItem(
              title: e['title'],
              subtitle: e['subtitle'],
              icon: Icons.edit_note,
              iconBgColor: e['color'],
            ),
          ),
          ViewAllButton(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UpcomingExams()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const StudentCalendar(showAppBar: false, isInline: true),
    );
  }

  Widget _buildEventsThisMonth() {
    return DashboardSection(
      title: "Events This Month",
      child: const _EmptyState(message: "No events this month"),
    );
  }

  Widget _buildYearPill(String selectedYear, Function(String) onYearSelected) {
    return GestureDetector(
      onTap: () => _showYearSelector(selectedYear, onYearSelected),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selectedYear,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: Colors.black54,
            ),
          ],
        ),
      ),
    );
  }

  void _showYearSelector(String currentYear, Function(String) onSelect) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Select Time Range",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ..._rangeOptions.map(
                (range) => ListTile(
                  title: Text(range, textAlign: TextAlign.center),
                  onTap: () {
                    onSelect(range);
                    Navigator.pop(context);
                  },
                  selected: range == currentYear,
                  selectedTileColor: Colors.purple.withOpacity(0.1),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// A portable empty-state widget that uses a built-in Flutter icon instead of
/// a machine-specific file path, so it works on every device.
class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFEDE9FE),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.inbox_outlined,
              size: 56,
              color: Color(0xFF7C3AED),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
