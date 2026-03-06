import 'package:flutter/material.dart';
import 'dart:async';
import 'package:get/get.dart';
import 'package:student_app/student_app/model/class_attendance.dart';
import 'package:student_app/student_app/model/hostel_attendance.dart';
import 'package:student_app/student_app/services/attendance_service.dart';
import 'package:student_app/student_app/services/exams_service.dart';
import 'package:student_app/student_app/services/hostel_attendance_service.dart';
import 'package:student_app/student_app/services/remarks_service.dart';
import 'package:student_app/student_app/upcoming_exams_page.dart';
import 'package:student_app/student_app/widgets/dashboard_widgets.dart';
import 'package:student_app/student_app/student_calendar.dart';
import 'package:student_app/student_app/announcement_page.dart';
import 'package:student_app/student_app/studentdrawer.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true;
  List<Map<String, dynamic>> _classChartData = [];
  List<Map<String, dynamic>> _hostelChartData = [];
  List<String> _classChartMonths = [];
  List<String> _hostelChartMonths = [];
  List<dynamic> _remarks = [];
  List<dynamic> _announcements = [];
  List<dynamic> _exams = [];

  String _classRange = "Academic Year";
  String _hostelRange = "Academic Year";
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
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    try {
      final results = await Future.wait([
        AttendanceService.getAttendance(forceRefresh: true),
        HostelAttendanceService.getHostelAttendance(forceRefresh: true),
        RemarksService.getRemarks(forceRefresh: true).catchError((_) => []),
        ExamsService.getExamStats().catchError((_) => <String, dynamic>{}),
      ]);

      final classAttendance = results[0] as ClassAttendance;
      final hostelAttendance = results[1] as HostelAttendance;
      final remarks = results[2] as List<dynamic>;

      if (mounted) {
        setState(() {
          _processAttendanceData(classAttendance, hostelAttendance);
          _remarks = remarks;
          _isLoading = false;
          _announcements = [
            {
              "message": "Unit Test-2 will be conducted from 22nd July...",
              "department": "Academic Office",
              "color": const Color(0xFF3B82F6),
            },
            {
              "message":
                  "Hostel students must return to campus before 8:00 PM...",
              "department": "Hostel Warden",
              "color": const Color(0xFF06B6D4),
            },
          ];
          _exams = [
            {
              "title": "Mathematics Unit Test",
              "subtitle": "5th August, 2024",
              "color": const Color(0xFF3B82F6),
            },
            {
              "title": "Physics Monthly Assessment",
              "subtitle": "5th August, 2024",
              "color": const Color(0xFF06B6D4),
            },
          ];
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _processAttendanceData(
    ClassAttendance classData,
    HostelAttendance hostelData,
  ) {
    _classChartData.clear();
    _classChartMonths.clear();
    _hostelChartData.clear();
    _hostelChartMonths.clear();

    // Map Class Attendance
    List<MonthlyClassAttendance> classMonths = classData.attendance;
    if (_classRange == "This Month") {
      classMonths = classMonths.isNotEmpty ? [classMonths.last] : [];
    } else if (_classRange == "3 Months") {
      classMonths = classMonths.length >= 3
          ? classMonths.sublist(classMonths.length - 3)
          : classMonths;
    } else if (_classRange == "6 Months") {
      classMonths = classMonths.length >= 6
          ? classMonths.sublist(classMonths.length - 6)
          : classMonths;
    }

    for (var m in classMonths) {
      _classChartMonths.add(m.monthName.substring(0, 3));
      _classChartData.add({
        'present': m.present,
        'absent': m.absent,
        'outings': m.outings,
        'holidays': m.holidays,
        'total': m.total,
      });
    }

    // Map Hostel Attendance
    List<MonthlyAttendance> hostelMonths = hostelData.attendance;
    if (_hostelRange == "This Month") {
      hostelMonths = hostelMonths.isNotEmpty ? [hostelMonths.last] : [];
    } else if (_hostelRange == "3 Months") {
      hostelMonths = hostelMonths.length >= 3
          ? hostelMonths.sublist(hostelMonths.length - 3)
          : hostelMonths;
    } else if (_hostelRange == "6 Months") {
      hostelMonths = hostelMonths.length >= 6
          ? hostelMonths.sublist(hostelMonths.length - 6)
          : hostelMonths;
    }

    for (var m in hostelMonths) {
      _hostelChartMonths.add(m.monthName.substring(0, 3));
      _hostelChartData.add({'present': m.present, 'absent': m.absent});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person, color: Colors.white),
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
                    gradientColors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ModernStatCard(
                    title: "Present",
                    value: "89",
                    icon: Icons.calendar_today,
                    gradientColors: [Color(0xFF22C55E), Color(0xFF15803D)],
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
                    gradientColors: [Color(0xFFEF4444), Color(0xFFB91C1C)],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ModernStatCard(
                    title: "Outing",
                    value: "6",
                    icon: Icons.directions_walk,
                    gradientColors: [Color(0xFF06B6D4), Color(0xFF0E7490)],
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
                    gradientColors: [Color(0xFFEAB308), Color(0xFFB45309)],
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
    return const DashboardSection(
      title: "Exam Stats",
      child: Column(
        children: [
          StatListItem(
            icon: Icons.assignment,
            iconColor: Color(0xFF3B82F6),
            title: "Total Exam Questions",
            value: "200",
          ),
          StatListItem(
            icon: Icons.check_circle,
            iconColor: Color(0xFF10B981),
            title: "Attempted Questions",
            value: "150",
          ),
          StatListItem(
            icon: Icons.cancel,
            iconColor: Color(0xFFF59E0B),
            title: "Not Attempted Questions",
            value: "50",
          ),
          StatListItem(
            icon: Icons.add_circle,
            iconColor: Color(0xFF06B6D4),
            title: "+ve Questions",
            value: "120",
          ),
          StatListItem(
            icon: Icons.remove_circle,
            iconColor: Color(0xFFEF4444),
            title: "-ve Questions",
            value: "30",
          ),
        ],
      ),
    );
  }

  Widget _buildRankState() {
    return const DashboardSection(
      title: "Rank State",
      child: Column(
        children: [
          StatListItem(
            icon: Icons.emoji_events,
            iconColor: Color(0xFF3B82F6),
            title: "Overall Rank",
            value: "12",
          ),
          StatListItem(
            icon: Icons.account_tree,
            iconColor: Color(0xFF10B981),
            title: "Branch Wise Rank",
            value: "3",
          ),
          StatListItem(
            icon: Icons.groups,
            iconColor: Color(0xFFF59E0B),
            title: "Group Wise Rank",
            value: "5",
          ),
          StatListItem(
            icon: Icons.school,
            iconColor: Color(0xFF06B6D4),
            title: "Course Wise Rank",
            value: "8",
          ),
          StatListItem(
            icon: Icons.layers,
            iconColor: Color(0xFFEF4444),
            title: "Batch Wise Rank",
            value: "2",
            valueColor: Color(0xFFEF4444),
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
        _buildYearPill(_classRange, (range) {
          setState(() {
            _classRange = range;
            _loadAllData();
          });
        }),
      ],
      child: AttendanceChart(
        months: _classChartMonths,
        maxValue: 35,
        data: _classChartData,
        selectedRange: TimeRange.academicYear,
      ),
    );
  }

  Widget _buildHostelAttendance() {
    return DashboardSection(
      title: "Hostel Attendance",
      actions: [
        _buildYearPill(_hostelRange, (range) {
          setState(() {
            _hostelRange = range;
            _loadAllData();
          });
        }),
      ],
      child: AttendanceChart(
        months: _hostelChartMonths,
        maxValue: 35,
        data: _hostelChartData,
        selectedRange: TimeRange.academicYear,
        isHostel: true,
      ),
    );
  }

  Widget _buildRemarks() {
    return DashboardSection(
      title: "Remarks",
      child: _remarks.isEmpty
          ? EmptyStateWidget(
              message: "No Remarks yet",
              imagePath: _emptyIllustrationPath,
            )
          : Column(
              children: _remarks.map((r) {
                // Safely extract data from the map
                final remark = r['remark']?.toString() ?? "No Remark";
                final relatedTo = r['related_to']?.toString() ?? "General";
                final createdAt = r['created_at']?.toString() ?? "";

                // Format date (simple extraction from 2026-02-18T...)
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
          ..._announcements.map(
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
          ..._exams.map(
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
