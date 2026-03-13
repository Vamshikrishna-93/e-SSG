import 'package:flutter/material.dart';

import 'package:fl_chart/fl_chart.dart';
import 'package:iconify_flutter/iconify_flutter.dart';

import '../utils/iconify_icons.dart';
import 'attendance_summary_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _activeTab = "Admissions";

  static const List<Map<String, dynamic>> branchData = [
    {"name": "SSJC-ADARSA CAMPUS", "count": 1063},
    {"name": "SSJC-VICTORY CAMPUS", "count": 324},
    {"name": "SSJC-BN GIRLS", "count": 506},
    {"name": "SSJC-BN BOYS", "count": 645},
    {"name": "SSJC-VRB CAMPUS", "count": 541},
    {"name": "SSJC-PVB CAMPUS", "count": 254},
    {"name": "SSJC-VIDHYA BHAVAN", "count": 1211},
    {"name": "SSJC-SSG EAMCET CAMPUS", "count": 478},
    {"name": "SSHS-TALLUR", "count": 1248},
    {"name": "SSJC-SSG NEET&MAINS CAMPUS", "count": 599},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF8B5CF6), // Primary Purple
              Color(0xFFC084FC), // Lighter Purple
              Colors.white, // Bottom White
            ],
            stops: [0.0, 0.3, 0.7],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                // App Bar Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => _scaffoldKey.currentState?.openDrawer(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(
                            0xFFB388FF,
                          ), // Lighter Purple as in image 2
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.menu_open,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        _buildHeaderIcon(Icons.search),
                        const SizedBox(width: 10),
                        _buildHeaderIcon(
                          Icons.notifications_none,
                          hasBadge: true,
                        ),
                        const SizedBox(width: 10),
                        const CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.white24,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Title and Dropdown
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Super Admin",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(51),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Text(
                            "2025-26",
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(
                      child: _buildTabButton(
                        "Admissions",
                        _activeTab == "Admissions",
                        icon: Icons.person_outline,
                        onTap: () => setState(() => _activeTab = "Admissions"),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTabButton(
                        "Finance",
                        _activeTab == "Finance",
                        icon: Icons.account_balance_wallet_outlined,
                        onTap: () => setState(() => _activeTab = "Finance"),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTabButton(
                        "Attendance",
                        _activeTab == "Attendance",
                        icon: Icons.person_add_alt_1_outlined,
                        onTap: () => setState(() => _activeTab = "Attendance"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                if (_activeTab == "Admissions") _buildAdmissionsBody(),
                if (_activeTab == "Attendance") _buildAttendanceBody(),
                if (_activeTab == "Finance") _buildFinanceBody(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildAdmissionsBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Statistics Grid
        _buildStatsGrid(),
        const SizedBox(height: 25),
        // Charts Section
        _buildChartCard(
          "Total Strength Male/Female",
          _buildDonutChart(
            sections: [
              PieChartSectionData(
                value: 41.8,
                color: const Color(0xFF5C6BC0),
                title: '41.8%',
                radius: 20,
                showTitle: true,
                titlePositionPercentageOffset: 1.7,
                titleStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              PieChartSectionData(
                value: 58.2,
                color: const Color(0xFF26A69A),
                title: '58.2%',
                radius: 20,
                showTitle: true,
                titlePositionPercentageOffset: 1.7,
                titleStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
            legends: [
              {"label": "Girls", "color": const Color(0xFF5C6BC0)},
              {"label": "Boys", "color": const Color(0xFF26A69A)},
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildChartCard(
          "Total Strength Hostel/Day",
          _buildDonutChart(
            sections: [
              PieChartSectionData(
                value: 29.4,
                color: const Color(0xFFEF5350),
                title: '29.4%',
                radius: 20,
                showTitle: true,
                titlePositionPercentageOffset: 1.7,
                titleStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              PieChartSectionData(
                value: 70.6,
                color: const Color(0xFF42A5F5),
                title: '70.6%',
                radius: 20,
                showTitle: true,
                titlePositionPercentageOffset: 1.7,
                titleStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
            legends: [
              {"label": "Day", "color": const Color(0xFFEF5350)},
              {"label": "Hostel", "color": const Color(0xFF42A5F5)},
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Branch Wise Chart
        _buildChartCard("Total Students Branch Wise", _buildBranchPieChart()),
        const SizedBox(height: 25),
        const Padding(
          padding: EdgeInsets.only(left: 4),
          child: Text(
            "Total Students Data Branch Wise",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 15),
        // Branch Data List
        _buildBranchDataList(),
      ],
    );
  }

  Widget _buildAttendanceBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAttendanceStatsGrid(),
        const SizedBox(height: 25),
        const Text(
          "Student Attendance",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        _buildProgressCard(const Color(0xFF7E57C2)),
        const SizedBox(height: 25),
        const Text(
          "Staff Attendance",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        _buildProgressCard(const Color(0xFF2196F3)),
        const SizedBox(height: 25),
        _buildTodaysAttendanceInfo(),
        const SizedBox(height: 25),
        _buildClassWiseSummary(),
      ],
    );
  }

  Widget _buildHeaderIcon(IconData icon, {bool hasBadge = false}) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        if (hasBadge)
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
  }

  Widget _buildTabButton(
    String label,
    bool isActive, {
    IconData? icon,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF7E57C2) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 4,
              offset: Offset.zero,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: isActive ? Colors.white : Colors.black87,
                size: 16,
              ),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceStatsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                "Todays Outing",
                "0",
                IconifyIcons.account,
                [const Color(0xFF4DE1B0), const Color(0xFF00BFA5)],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                "Home Pass",
                "0",
                IconifyIcons.hugeIconsBus03,
                [const Color(0xFFF1597E), const Color(0xFFD81B60)],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                "Out Pass",
                "0",
                IconifyIcons.clarityBuildingLine,
                [const Color(0xFFFFB755), const Color(0xFFFB8C00)],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard("Self Pass", "0", IconifyIcons.account, [
                const Color(0xFF46B1FF),
                const Color(0xFF1E88E5),
              ]),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard("Staff", "396", IconifyIcons.account, [
                const Color(0xFF4EE298),
                const Color(0xFF43A047),
              ]),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                "Student Attendance",
                "0",
                IconifyIcons.account,
                [const Color(0xFFF1597E), const Color(0xFFD81B60)],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                "Staff Attendance",
                "0",
                IconifyIcons.phStudent,
                [const Color(0xFF6B7AF5), const Color(0xFF5C6BC0)],
              ),
            ),
            const Expanded(child: SizedBox()),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressCard(Color color) {
    final List<String> branches = [
      "Pelluru",
      "VRB",
      "PVB",
      "Vidya Bhavan",
      "Padmavathi",
      "MM Road",
      "AVP",
      "Tallur",
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 4),
        ],
      ),
      child: Column(
        children: branches
            .map(
              (branch) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        branch,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: LinearProgressIndicator(
                          value: 0.75,
                          backgroundColor: color.withOpacity(0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                          minHeight: 8,
                        ),
                      ),
                    ),
                    const Expanded(
                      flex: 1,
                      child: Text(
                        " 75%",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildTodaysAttendanceInfo() {
    return _buildChartCard(
      "Todays Attendance Info",
      Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade100),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset.zero,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "S.NO: 1",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Branch :",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Divider(color: Colors.grey.shade200, height: 1),
                const SizedBox(height: 12),
                _buildInfoRow("Total", ""),
                const SizedBox(height: 8),
                _buildInfoRow("Present", ""),
                const SizedBox(height: 8),
                _buildInfoRow("Absent", ""),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFFC084FC)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Total : 0",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 8),
                Divider(color: Colors.white30, height: 1),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total : 0",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "Present : 0",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "Absent : 0",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
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

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
        ),
        Text(
          ": $value",
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildClassWiseSummary() {
    return _buildChartCard(
      "Class Wise Student Attendance Summary",
      Column(
        children: [
          _buildClassCard("SSJC-ADARSA CAMPUS", 1),
          const SizedBox(height: 15),
          _buildClassCard("SSJC-VRB CAMPUS", 2),
        ],
      ),
    );
  }

  Widget _buildClassCard(String branch, int sNo) {
    return Container(
      width: 326, // FIXED WIDTH
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: Offset.zero,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "S.NO: $sNo",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Text(
                "Branch : ",
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Expanded(
                child: Text(
                  branch,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.grey.shade200, height: 1),
          const SizedBox(height: 12),
          const Text(
            "Day Students",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildSimpleStat(
                  "Total",
                  "120",
                  const Color(0xFF9575CD),
                  Icons.group,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSimpleStat(
                  "Present",
                  "105",
                  const Color(0xFF4DB6AC),
                  Icons.person_outline,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSimpleStat(
                  "Absent",
                  "15",
                  const Color(0xFFE57373),
                  Icons.person_off_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "Hostel Students",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildSimpleStat(
                  "Total",
                  "120",
                  const Color(0xFF9575CD),
                  Icons.group,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSimpleStat(
                  "Present",
                  "105",
                  const Color(0xFF4DB6AC),
                  Icons.person_outline,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSimpleStat(
                  "Absent",
                  "15",
                  const Color(0xFFE57373),
                  Icons.person_off_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AttendanceSummaryPage(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7E57C2),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              minimumSize: const Size(100, 36),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: const Text(
              "View Details",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleStat(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: Offset.zero,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 12, color: color),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 2),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                "Students",
                "6869",
                IconifyIcons.phStudent,
                [const Color(0xFF6B7AF5), const Color(0xFF5C6BC0)],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard("Boys", "3995", IconifyIcons.account, [
                const Color(0xFFFFB755),
                const Color(0xFFFB8C00),
              ]),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard("Girls", "2874", IconifyIcons.account, [
                const Color(0xFF4EE298),
                const Color(0xFF43A047),
              ]),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                "Day",
                "2018",
                IconifyIcons.hugeIconsBus03,
                [const Color(0xFF46B1FF), const Color(0xFF1E88E5)],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                "Hostel",
                "4850",
                IconifyIcons.clarityBuildingLine,
                [const Color(0xFFF1597E), const Color(0xFFD81B60)],
              ),
            ),
            const Expanded(child: SizedBox()),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String iconData,
    List<Color> colors,
  ) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 4,
            offset: Offset.zero,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            top: -20,
            left: -10,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            right: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Iconify(iconData, color: Colors.white, size: 26),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(String title, Widget chart) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 4,
            offset: Offset.zero,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFE9EBFF), // Precise lavender header color
            ),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Padding(padding: const EdgeInsets.all(16), child: chart),
        ],
      ),
    );
  }

  Widget _buildDonutChart({
    required List<PieChartSectionData> sections,
    required List<Map<String, dynamic>> legends,
  }) {
    return Column(
      children: [
        SizedBox(
          width: 234, // Exact spec from image
          height: 156, // Exact spec from image
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 50,
              sectionsSpace: 0,
            ),
          ),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: legends
              .map(
                (l) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 15, // Specification: dot size increase
                        height: 15,
                        decoration: BoxDecoration(
                          color: l['color'],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l['label'],
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildBranchPieChart() {
    final List<Color> branchColors = [
      Colors.orange,
      Colors.amber,
      Colors.purple,
      Colors.blue,
      Colors.green,
      Colors.yellow.shade700,
      Colors.red,
      Colors.lightGreen,
      Colors.green.shade700,
      Colors.teal,
    ];

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: branchData.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 1.5),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: branchColors[entry.key % branchColors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        entry.value['name'] as String,
                        style: const TextStyle(
                          fontSize: 9,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        Expanded(
          flex: 2,
          child: Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 141, // Exact spec from image
              height: 141, // Exact spec from image
              child: PieChart(
                PieChartData(
                  sections: branchData.asMap().entries.map((entry) {
                    return PieChartSectionData(
                      value: (entry.value['count'] as int).toDouble(),
                      color: branchColors[entry.key % branchColors.length],
                      title:
                          '${((entry.value['count'] as int) / 6869 * 100).toStringAsFixed(1)}%',
                      radius: 70.5, // 141 / 2
                      showTitle: true,
                      titleStyle: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                  centerSpaceRadius: 0,
                  sectionsSpace: 0,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBranchDataList() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EDFF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: branchData.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = branchData[index];
          return Container(
            padding: const EdgeInsets.all(12),
            height: 107, // Specification: Height: 107px
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                16,
              ), // Specification: Radius: 16px
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(
                    0.25,
                  ), // Specification: BoxShadow: 25% opacity
                  blurRadius: 4,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "S.NO: ${index + 1}",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(height: 1, thickness: 1),
                Row(
                  children: [
                    const Text(
                      "Branch : ",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item['name'] as String,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text(
                      "Count : ",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      item['count'].toString(),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFFF8F7FF),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(25, 60, 20, 35),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6B7AF5), Color(0xFFB388FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      "Logo",
                      style: TextStyle(
                        color: Color(0xFF6B7AF5),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  "Ashok Reddy",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "User ID :  667021",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          // Scrollable List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              children: [
                _buildDrawerItem(Icons.grid_view_outlined, "Staff Dashboard"),
                _buildDrawerItem(
                  Icons.business_center_outlined,
                  "ADM Dashboard",
                ),
                _buildDrawerItem(
                  Icons.person_pin_outlined,
                  "Attendance",
                  hasDropdown: true,
                ),
                _buildDrawerItem(
                  Icons.assignment_outlined,
                  "Exams List",
                  hasDropdown: true,
                ),
                _buildDrawerItem(
                  Icons.groups_outlined,
                  "Hr Management",
                  hasDropdown: true,
                ),
                _buildDrawerItem(Icons.directions_walk_rounded, "Outing"),
                _buildDrawerItem(Icons.logout_rounded, "Leaves"),
                _buildDrawerItem(Icons.school_outlined, "Student View"),
                _buildDrawerItem(Icons.menu_book_outlined, "Syllabus"),
                _buildDrawerItem(Icons.table_chart_outlined, "Time Table"),
                _buildDrawerItem(Icons.edit_note_outlined, "Homework"),
                _buildDrawerItem(Icons.chat_bubble_outline_rounded, "Chat"),
                _buildDrawerItem(Icons.campaign_outlined, "Communication"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    IconData icon,
    String title, {
    bool hasDropdown = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF424242), size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF424242),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (hasDropdown)
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF757575),
              size: 20,
            ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 75,
      decoration: BoxDecoration(
        color: const Color(0xFF7E57C2),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, "Home", true),
          _buildNavItem(Icons.bar_chart, "Attendance", false),
          _buildNavItem(Icons.account_balance_wallet_outlined, "Fees", false),
          _buildNavItem(Icons.person_outline, "Profile", false),
        ],
      ),
    );
  }

  Widget _buildFinanceBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFinanceStatsGrid(),
        const SizedBox(height: 25),
        _buildFinanceChartCard(
          "Total Income Branch Wise",
          _buildTotalIncomeBranchWiseChart(),
        ),
        const SizedBox(height: 20),
        _buildFinanceChartCard(
          "Total Fee Due/Paid",
          _buildFeeDuePaidDonutChart(),
        ),
        const SizedBox(height: 20),
        _buildFeeCollectionInfoSection(),
        const SizedBox(height: 20),
        _buildFinanceChartCard(
          "Total Fee Due/Paid Branch Wise",
          _buildDuePaidBranchProgressBarList(),
        ),
        const SizedBox(height: 20),
        _buildFinanceChartCard(
          "Expense vs Income - April 24",
          _buildExpenseVsIncomeLineChart(),
        ),
        const SizedBox(height: 20),
        _buildExpensesInfoSection(),
        const SizedBox(height: 20),
        _buildCashHoldingSection(),
        const SizedBox(height: 20),
        _buildExpensesMonthSection(),
        const SizedBox(height: 20),
        _buildTodaysExpensesSection(),
      ],
    );
  }

  Widget _buildFinanceStatsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard("Today Income", "0", IconifyIcons.account, [
                const Color(0xFF6B7AF5),
                const Color(0xFF5C6BC0),
              ]),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                "Today Expense",
                "0",
                IconifyIcons.account,
                [const Color(0xFFFFB755), const Color(0xFFFB8C00)],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                "Month Income",
                "20100",
                IconifyIcons.account,
                [const Color(0xFF4EE298), const Color(0xFF43A047)],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                "Month Expense",
                "87450",
                IconifyIcons.account,
                [const Color(0xFF46B1FF), const Color(0xFF1E88E5)],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                "Total Income",
                "239640060",
                IconifyIcons.account,
                [const Color(0xFFF1597E), const Color(0xFFD81B60)],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                "Total Expense",
                "37156356",
                IconifyIcons.account,
                [const Color(0xFF26A69A), const Color(0xFF00897B)],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFinanceChartCard(
    String title,
    Widget chart, {
    bool showTabs = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE9EBFF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          if (showTabs)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSmallTab("Todays", true),
                  _buildSmallTab("Yesterdays", false),
                  _buildSmallTab("Month", false),
                  _buildSmallTab("Total", false),
                ],
              ),
            ),
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: chart,
          ),
        ],
      ),
    );
  }

  Widget _buildSmallTab(String label, bool isActive) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isActive ? const Color(0xFF8B5CF6) : Colors.black54,
          ),
        ),
        if (isActive)
          Container(
            margin: const EdgeInsets.only(top: 4),
            height: 2,
            width: 40,
            color: const Color(0xFF8B5CF6),
          ),
      ],
    );
  }

  Widget _buildTotalIncomeBranchWiseChart() {
    final List<Color> colors = [
      const Color(0xFFFF6B6B), // Coral Red
      const Color(0xFFFFBD69), // Pastel Orange
      const Color(0xFF7E57C2), // Medium Purple
      const Color(0xFF03A9F4), // Azure
      const Color(0xFF00D084), // Spring Green
      const Color(0xFFFFB900), // Amber
      const Color(0xFFFF2D55), // Strong Red
      const Color(0xFF8BC34A), // Light Moss Green
      const Color(0xFF7ED321), // Bright Lime
      const Color(0xFF009688), // Dark Teal
    ];

    return Row(
      children: [
        Expanded(
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: branchData.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: colors[entry.key % colors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        entry.value['name'].toString(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        Expanded(
          flex: 4,
          child: Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 141,
              height: 141,
              child: PieChart(
                PieChartData(
                  startDegreeOffset: 270, // Start from top (BN GIRLS)
                  sections: branchData.asMap().entries.map((entry) {
                    final List<String> picTitles = [
                      '8.7%',
                      '8.7%',
                      '8.7%',
                      '5.2%',
                      '5.2%',
                      '5.2%',
                      '8.7%',
                      '8.8%',
                      '8.7%',
                      '8.7%',
                    ];
                    return PieChartSectionData(
                      value: (entry.key >= 3 && entry.key <= 5) ? 5.2 : 10,
                      color: colors[entry.key % colors.length],
                      radius: 70.5,
                      showTitle: true,
                      title: picTitles[entry.key % picTitles.length],
                      titleStyle: const TextStyle(
                        fontSize: 9,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }).toList(),
                  centerSpaceRadius: 0,
                  sectionsSpace: 0,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeeDuePaidDonutChart() {
    return Column(
      children: [
        SizedBox(
          width: 234,
          height: 156,
          child: PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                  value: 41.8,
                  color: const Color(0xFF5C6BC0),
                  title: '41.8%',
                  radius: 30,
                  showTitle: true,
                  titlePositionPercentageOffset: 1.8,
                  titleStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                PieChartSectionData(
                  value: 58.2,
                  color: const Color(0xFF26A69A),
                  title: '58.2%',
                  radius: 30,
                  showTitle: true,
                  titlePositionPercentageOffset: 1.8,
                  titleStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
              centerSpaceRadius: 45,
              sectionsSpace: 0,
            ),
          ),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem("Paid", const Color(0xFF26A69A)),
            const SizedBox(width: 20),
            _buildLegendItem("Due", const Color(0xFF5C6BC0)),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 15,
          height: 15,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFeeCollectionInfoSection() {
    return _buildFinanceChartCard(
      "Fee collection Info",
      Column(
        children: [
          _buildInfoListCard(
            1,
            "SSJC-ADARSA CAMPUS",
            "10,000",
            "0",
            "10,000",
            "20,000",
          ),
          const SizedBox(height: 12),
          _buildInfoListCard(
            2,
            "SSJC-ADARSA CAMPUS",
            "10,000",
            "0",
            "10,000",
            "20,000",
          ),
          const SizedBox(height: 12),
          _buildFinanceSummaryCard("20,000", "10,000", "0", "10,000"),
        ],
      ),
      showTabs: true,
    );
  }

  Widget _buildInfoListCard(
    int sNo,
    String branch,
    String count,
    String upi,
    String cheque,
    String total,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 4),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "S.NO: $sNo",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Text(
                "Branch : ",
                style: TextStyle(color: Colors.black54, fontSize: 13),
              ),
              Text(
                branch,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const Divider(),
          _buildInfoRow("Count", count),
          _buildInfoRow("UPI", upi),
          _buildInfoRow("Cheque", cheque),
          const Divider(),
          _buildInfoRow("Total", total),
        ],
      ),
    );
  }

  Widget _buildFinanceSummaryCard(
    String total,
    String count,
    String upi,
    String cheque,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF9575CD),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Total : $total",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(color: Colors.white24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem("Count", count),
              _buildSummaryItem("UPI", upi),
              _buildSummaryItem("Cheque", cheque),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDuePaidBranchProgressBarList() {
    final List<String> branches = branchData
        .map((e) => e['name'].toString())
        .toList();
    return Column(
      children: branches
          .map((branch) => _buildBranchProgressRow(branch))
          .toList(),
    );
  }

  Widget _buildBranchProgressRow(String branch) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                branch,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                "75%",
                style: TextStyle(fontSize: 10, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: const LinearProgressIndicator(
              value: 0.75,
              backgroundColor: Color(0xFFF3EDFF),
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF26A69A)),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseVsIncomeLineChart() {
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            getDrawingHorizontalLine: (value) =>
                FlLine(color: Colors.grey.shade200, strokeWidth: 1),
            getDrawingVerticalLine: (value) =>
                FlLine(color: Colors.grey.shade200, strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const months = [
                    'Jun',
                    'Jul',
                    'Aug',
                    'Sep',
                    'Oct',
                    'Nov',
                    'Dec',
                    'Jan',
                    'Feb',
                    'Mar',
                    'Apr',
                    'May',
                  ];
                  if (value.toInt() >= 0 && value.toInt() < months.length) {
                    return Text(
                      months[value.toInt()],
                      style: const TextStyle(fontSize: 8),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  if (value % 4000000 == 0) {
                    return Text(
                      '${(value / 1000000).toInt()}M',
                      style: const TextStyle(fontSize: 8),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: const [
                FlSpot(0, 4000000),
                FlSpot(1, 8000000),
                FlSpot(2, 6000000),
                FlSpot(3, 9000000),
                FlSpot(4, 8000000),
                FlSpot(5, 12000000),
                FlSpot(6, 7000000),
                FlSpot(7, 10000000),
              ],
              isCurved: true,
              color: const Color(0xFF4EE298),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xFF4EE298).withAlpha(30),
              ),
            ),
            LineChartBarData(
              spots: const [
                FlSpot(0, 6000000),
                FlSpot(1, 9000000),
                FlSpot(2, 7000000),
                FlSpot(3, 11000000),
                FlSpot(4, 10000000),
                FlSpot(5, 14000000),
                FlSpot(6, 9000000),
                FlSpot(7, 12000000),
              ],
              isCurved: true,
              color: const Color(0xFF46B1FF),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xFF46B1FF).withAlpha(30),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpensesInfoSection() {
    return _buildFinanceChartCard(
      "Expenses Info",
      Column(
        children: [
          _buildInfoListCard(1, "SSJC-ADARSA CAMPUS", "", "", "", "0"),
          const SizedBox(height: 12),
          _buildFinanceSummaryCard("0", "0", "0", "0"),
        ],
      ),
      showTabs: true,
    );
  }

  Widget _buildCashHoldingSection() {
    return _buildFinanceChartCard(
      "Cash Holding",
      Column(
        children: [
          _buildCashHolderCard(1, "BAYYAVARAPU LAKSHMI PRASAD", "-5896484"),
          const SizedBox(height: 10),
          _buildCashHolderCard(2, "BAPIREDDY ANJALI", "-4379466"),
        ],
      ),
    );
  }

  Widget _buildCashHolderCard(int sNo, String name, String amount) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "S.NO: $sNo",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Text(
                "Cash Holder : ",
                style: TextStyle(color: Colors.black54, fontSize: 13),
              ),
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Text(
                "Amount : ",
                style: TextStyle(color: Colors.black54, fontSize: 13),
              ),
              Text(
                amount,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpensesMonthSection() {
    return _buildFinanceChartCard(
      "Expenses Info - March 2026",
      Column(
        children: [
          _buildExpenseItemCard(
            1,
            "SSJC-ADARSA CAMPUS",
            "GANESH REDDY SIR",
            "15000",
          ),
          const SizedBox(height: 10),
          _buildExpenseItemCard(
            2,
            "SSJC-ADARSA CAMPUS",
            "GANESH REDDY SIR",
            "15000",
          ),
          const SizedBox(height: 12),
          _buildSimpleTotalBar("87450"),
        ],
      ),
    );
  }

  Widget _buildExpenseItemCard(
    int sNo,
    String branch,
    String head,
    String amount,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "S.NO: $sNo",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          _buildInfoRow("Branch", branch),
          _buildInfoRow("Expense Head", head),
          _buildInfoRow("Amount", amount),
        ],
      ),
    );
  }

  Widget _buildSimpleTotalBar(String total) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF9575CD),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        "Total : $total",
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildTodaysExpensesSection() {
    return _buildFinanceChartCard(
      "Todays Expenses - Tue-10 Mar",
      Column(
        children: [
          _buildTodaysExpenseItemCard(1),
          const SizedBox(height: 10),
          _buildSimpleTotalBar("0"),
        ],
      ),
    );
  }

  Widget _buildTodaysExpenseItemCard(int sNo) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "S.NO: $sNo",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          _buildInfoRow("Branch", ""),
          _buildInfoRow("Expense Head", ""),
          _buildInfoRow("Amount", ""),
          _buildInfoRow("Note", ""),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isActive)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(64),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 24),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          )
        else
          Icon(icon, color: Colors.white.withAlpha(178), size: 24),
      ],
    );
  }
}
