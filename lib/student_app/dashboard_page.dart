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

  final String _emptyIllustrationPath =
      r'C:\Users\Vamsikrishna\.gemini\antigravity\brain\bbe2a901-f8d4-4d85-92c1-4990b498ac94\empty_state_illustration_1772721945968.png';

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<DashboardController>()) {
      Get.put(DashboardController(), permanent: true);
    }
    _controller = Get.find<DashboardController>();
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
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF8B5CF6), // Deep vibrant purple
                Color(0xFFA78BFA), // Mid transition purple
                Color(0xFFF3F4FB), // Lightest lavender/white
                Color(0xFFF5F5FA), // Soft background tint
              ],
              stops: [0.0, 0.25, 0.45, 1.0],
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
                      _buildAttendanceGrid(),
                      const SizedBox(height: 16),
                      _buildExamStats(),
                      const SizedBox(height: 16),
                      _buildRankState(),
                      const SizedBox(height: 16),
                      _buildTimeTable(),
                      const SizedBox(height: 16),
                      _buildClassAttendance(),
                      const SizedBox(height: 16),
                      _buildHostelAttendance(),
                      const SizedBox(height: 16),
                      _buildRemarks(),
                      const SizedBox(height: 16),
                      _buildAnnouncements(),
                      const SizedBox(height: 16),
                      _buildUpcomingExams(),
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
        bottomNavigationBar: _buildBottomNav(),
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
                  Stack(
                    children: [
                      const Icon(
                        Icons.notifications_none,
                        color: Colors.white,
                        size: 28,
                      ),
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
                  ),
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
    // Note: These values seem static in the original code but can be mapped to real data if available
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
                    value: "334",
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
                    value: "89",
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
                    value: "39",
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
                    value: "6",
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
                    value: "0",
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
      child: Column(
        children: [
          StatListItem(
            icon: Icons.assignment,
            iconColor: const Color(0xFF3B82F6),
            title: "Total Exam Questions",
            value: stats['totalQuestions']?.toString() ?? "200",
          ),
          StatListItem(
            icon: Icons.check_circle,
            iconColor: const Color(0xFF10B981),
            title: "Attempted Questions",
            value: stats['attempted']?.toString() ?? "150",
          ),
          StatListItem(
            icon: Icons.cancel,
            iconColor: const Color(0xFFF59E0B),
            title: "Not Attempted Questions",
            value: stats['notAttempted']?.toString() ?? "50",
          ),
          StatListItem(
            icon: Icons.add_circle,
            iconColor: const Color(0xFF06B6D4),
            title: "+ve Questions",
            value: stats['positive']?.toString() ?? "120",
          ),
          StatListItem(
            icon: Icons.remove_circle,
            iconColor: const Color(0xFFEF4444),
            title: "-ve Questions",
            value: stats['negative']?.toString() ?? "30",
          ),
        ],
      ),
    );
  }

  Widget _buildRankState() {
    final stats = _controller.examStats;
    return DashboardSection(
      title: "Rank State",
      child: Column(
        children: [
          StatListItem(
            icon: Icons.emoji_events,
            iconColor: const Color(0xFF3B82F6),
            title: "Overall Rank",
            value: stats['overallRank']?.toString() ?? "12",
          ),
          StatListItem(
            icon: Icons.account_tree,
            iconColor: const Color(0xFF10B981),
            title: "Branch Wise Rank",
            value: stats['branchRank']?.toString() ?? "3",
          ),
          StatListItem(
            icon: Icons.groups,
            iconColor: const Color(0xFFF59E0B),
            title: "Group Wise Rank",
            value: stats['groupRank']?.toString() ?? "5",
          ),
          StatListItem(
            icon: Icons.school,
            iconColor: const Color(0xFF06B6D4),
            title: "Course Wise Rank",
            value: stats['courseRank']?.toString() ?? "8",
          ),
          StatListItem(
            icon: Icons.layers,
            iconColor: const Color(0xFFEF4444),
            title: "Batch Wise Rank",
            value: stats['batchRank']?.toString() ?? "2",
            valueColor: const Color(0xFFEF4444),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeTable() {
    return const DashboardSection(
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
        selectedRange: TimeRange.academicYear,
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
        selectedRange: TimeRange.academicYear,
        isHostel: true,
      ),
    );
  }

  Widget _buildRemarks() {
    return DashboardSection(
      title: "Remarks",
      child: _controller.remarks.isEmpty
          ? EmptyStateWidget(
              message: "No Remarks yet",
              imagePath: _emptyIllustrationPath,
            )
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
      child: EmptyStateWidget(
        message: "No events this month",
        imagePath: _emptyIllustrationPath,
      ),
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
            _buildNavItem(Icons.home, "Home", active: true, onTap: () {}),
            _buildNavItem(
              Icons.bar_chart,
              "Marks",
              onTap: () => Get.offNamed('/studentMarks'),
            ),
            _buildNavItem(
              Icons.assignment_outlined,
              "Exams",
              onTap: () => Get.offNamed('/studentExams'),
            ),
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
