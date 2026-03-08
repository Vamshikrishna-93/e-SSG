import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:student_app/student_app/studentdrawer.dart';
import 'package:student_app/student_app/widgets/marks_widgets.dart';
import 'package:student_app/student_app/widgets/student_bottom_nav.dart';

class MarksPage extends StatefulWidget {
  const MarksPage({super.key});

  @override
  State<MarksPage> createState() => _MarksPageState();
}

class _MarksPageState extends State<MarksPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String selectedSemester = "All Semesters";
  String selectedPeriod = "Monthly";

  static const Color primaryPurple = Color(0xFF7E3FF2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF9FAFB),
      drawer: const StudentDrawerPage(),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopActions(),
                  const SizedBox(height: 24),
                  _buildStatCards(),
                  const SizedBox(height: 24),
                  _buildFiltersCard(),
                  const SizedBox(height: 24),
                  _buildPerformanceTrend(),
                  const SizedBox(height: 24),
                  _buildGradeDistribution(),
                  const SizedBox(height: 24),
                  _buildSubjectPerformance(),
                  const SizedBox(height: 24),
                  _buildExamHistory(),
                  const SizedBox(height: 24),
                  _buildAchievements(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const StudentBottomNav(currentIndex: 1),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 25,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        color: primaryPurple,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(35),
          bottomRight: Radius.circular(35),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.offNamed('/studentDashboard'),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 15),
          const SizedBox(width: 8),
          const Text(
            "Marks",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Marks",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          "Academic Performance overview - 2024 batch",
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionBtn(
                label: "Print Report",
                icon: Icons.print_outlined,
                color: const Color(0xFFA78BFA),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionBtn(
                label: "Download All",
                icon: Icons.download_outlined,
                color: const Color(0xFF4ADE80),
                isGradient: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionBtn({
    required String label,
    required IconData icon,
    required Color color,
    bool isGradient = false,
  }) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: isGradient ? null : color,
        gradient: isGradient
            ? const LinearGradient(
                colors: [Color(0xFF4ADE80), Color(0xFF84CC16)],
              )
            : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards() {
    return Column(
      children: [
        _buildStatCard(
          title: "Overall Percentage",
          value: "83.40%",
          sub: "Consistent Improvement",
          valueColor: const Color(0xFF2563EB),
        ),
        const SizedBox(height: 16),
        _buildStatCard(
          title: "Current Grade",
          value: "A",
          sub: "Excellent Performance",
          valueColor: const Color(0xFF22C55E),
        ),
        const SizedBox(height: 16),
        _buildStatCard(
          title: "Class Rank",
          value: "4/85",
          sub: "Top 5% of the class",
          valueColor: const Color(0xFF8B5CF6),
        ),
        const SizedBox(height: 16),
        _buildStatCard(
          title: "Attendance in Exams",
          value: "100 %",
          sub: "Perfect attendance record",
          valueColor: const Color(0xFF14B8A6),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String sub,
    required Color valueColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
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
          const SizedBox(height: 4),
          Text(
            sub,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          _buildMiniFilterDropdown("All Semesters"),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildDatePicker("Start Date")),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: Colors.black54,
                ),
              ),
              Expanded(child: _buildDatePicker("End Date")),
            ],
          ),
          const SizedBox(height: 12),
          _buildSearchBar("Search Staff name / ID"),
        ],
      ),
    );
  }

  Widget _buildMiniFilterDropdown(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
        ],
      ),
    );
  }

  Widget _buildDatePicker(String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            hint,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const Icon(
            Icons.calendar_month_outlined,
            size: 18,
            color: Colors.black54,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            hint,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const Icon(Icons.search, size: 20, color: Colors.black54),
        ],
      ),
    );
  }

  Widget _buildPerformanceTrend() {
    return _buildSection(
      title: "Performance Trend",
      action: _buildMiniDropdown("Monthly"),
      child: const SizedBox(height: 180, child: PerformanceTrendChart()),
    );
  }

  Widget _buildGradeDistribution() {
    return _buildSection(
      title: "Grade Distribution",
      child: const SizedBox(height: 220, child: GradeDistributionChart()),
    );
  }

  Widget _buildSubjectPerformance() {
    return _buildSection(
      title: "Subject-wise Performance",
      child: Column(
        children: [
          Row(
            children: [
              _buildWhiteBtn("Filters", Icons.filter_list),
              const SizedBox(width: 12),
              _buildWhiteBtn("Export", Icons.ios_share),
            ],
          ),
          const SizedBox(height: 16),
          _buildPerformanceBanner(),
          const SizedBox(height: 16),
          _buildSubjectTableHeader(),
          const SizedBox(height: 8),
          _buildSubjectRowItem("Mathematics", "85/100", 85, "A", Colors.blue),
          _buildSubjectRowItem("Physics", "78/100", 78, "B+", Colors.orange),
          _buildSubjectRowItem(
            "Chemistry",
            "92/100",
            85,
            "A+",
            Colors.green,
            showTick: true,
          ),
          _buildSubjectRowItem("English", "72/100", 72, "B", Colors.orange),
        ],
      ),
    );
  }

  Widget _buildPerformanceBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF4CAF50)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "Your overall performance is Excellent! Keep up the good work.",
              style: TextStyle(
                fontSize: 13,
                color: Colors.green.shade900,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectTableHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: const [
          Expanded(flex: 3, child: _TableHeaderCell("Subject")),
          Expanded(flex: 2, child: _TableHeaderCell("Marks")),
          Expanded(flex: 3, child: _TableHeaderCell("Percentage")),
          SizedBox(width: 10),
          Text(
            "Grade",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          Icon(Icons.swap_vert, size: 14, color: Colors.black54),
        ],
      ),
    );
  }

  Widget _buildSubjectRowItem(
    String subject,
    String marks,
    int percentage,
    String grade,
    Color gradeColor, {
    bool showTick = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              subject,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              marks,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              children: [
                SizedBox(
                  height: 6,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Colors.grey.shade100,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF2196F3),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (showTick)
                      const Icon(
                        Icons.check_circle,
                        size: 10,
                        color: Colors.green,
                      ),
                    if (showTick) const SizedBox(width: 2),
                    Text(
                      "$percentage%",
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _buildGradeBadgeItem(grade, gradeColor),
        ],
      ),
    );
  }

  Widget _buildGradeBadgeItem(String grade, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        grade,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildExamHistory() {
    return _buildSection(
      title: "Exam History",
      action: _buildMiniDropdown("All Exams"),
      child: Column(
        children: [
          Row(
            children: [
              _buildMiniSummaryBox(
                "Best Performance:",
                "Chemistry - 92%(Rank 1)",
                const Color(0xFFE8F5E9),
                Colors.green,
              ),
              const SizedBox(width: 12),
              _buildMiniSummaryBox(
                "Need Improvement:",
                "Biology - 68%(Rank 9)",
                const Color(0xFFFFF3E0),
                Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildHistoryRow("Mid Term- Mar 2024", "580/650 89.23%", "A+", "3"),
          _buildHistoryRow("Unit Test- Feb 2024", "160/200 84%", "A+", "5"),
          _buildHistoryRow("Unit Test- Feb 2024", "160/200 84%", "A+", "5"),
          _buildHistoryRow("Unit Test- Feb 2024", "160/200 84%", "A+", "5"),
        ],
      ),
    );
  }

  Widget _buildMiniSummaryBox(
    String title,
    String sub,
    Color bg,
    Color textCol,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 10,
                color: textCol,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(sub, style: TextStyle(fontSize: 10, color: textCol)),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryRow(
    String name,
    String stats,
    String grade,
    String rank,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            stats,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 12),
          _buildGradeBadgeItem(grade, Colors.green),
          const SizedBox(width: 12),
          Text(
            "Rank: $rank",
            style: const TextStyle(
              fontSize: 11,
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements() {
    return _buildSection(
      title: "Achievements",
      child: Column(
        children: [
          _buildAchievementCardItem(
            "Top 5 Ranks",
            "Consistently in top 5 positions",
            Icons.star,
            Colors.orange,
            const Color(0xFFE3F2FD),
          ),
          const SizedBox(height: 12),
          _buildAchievementCardItem(
            "Perfect Attendance",
            "100% exam attendance record",
            Icons.show_chart,
            Colors.green,
            const Color(0xFFE8F5E9),
          ),
          const SizedBox(height: 12),
          _buildAchievementCardItem(
            "Subject Topper",
            "Chemistry & Computer Science",
            Icons.star,
            Colors.orange,
            const Color(0xFFE3F2FD),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCardItem(
    String title,
    String desc,
    IconData icon,
    Color iconCol,
    Color bg,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconCol.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconCol, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  desc,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    Widget? action,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFEBE3FF),
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                if (action != null) action,
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }

  Widget _buildMiniDropdown(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
          const Icon(Icons.keyboard_arrow_down, size: 16),
        ],
      ),
    );
  }

  Widget _buildWhiteBtn(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.black87),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _TableHeaderCell extends StatelessWidget {
  final String title;
  const _TableHeaderCell(this.title);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
        const Icon(Icons.swap_vert, size: 14, color: Colors.black54),
      ],
    );
  }
}
