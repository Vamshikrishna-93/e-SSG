import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:student_app/staff_app/controllers/pro_dashboard_controller.dart';
import '../widgets/staff_header.dart';
import '../../student_app/widgets/skeleton_loader.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import '../utils/iconify_icons.dart';

class ProAdmissionPage extends GetView<ProDashboardController> {
  const ProAdmissionPage({super.key});

  static const List<Map<String, dynamic>> monthlyData = [
    {"month": "Jan", "current": 2, "previous": 1},
    {"month": "Feb", "current": 1, "previous": 1},
    {"month": "Mar", "current": 12, "previous": 3},
    {"month": "Apr", "current": 0, "previous": 0},
    {"month": "May", "current": 12, "previous": 3},
    {"month": "Jun", "current": 0, "previous": 0},
    {"month": "Jul", "current": 12, "previous": 3},
    {"month": "Aug", "current": 16, "previous": 3},
    {"month": "Sep", "current": 12, "previous": 3},
    {"month": "Oct", "current": 0, "previous": 0},
    {"month": "Nov", "current": 0, "previous": 0},
    {"month": "Dec", "current": 0, "previous": 0},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.dashboardData.value == null) {
          return Column(
            children: [
              const StaffHeader(title: "Pro Admission"),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: List.generate(
                          10,
                          (index) => SkeletonLoader.card(
                            height:
                                (MediaQuery.of(context).size.width - 44) /
                                2 /
                                1.7,
                            width: (MediaQuery.of(context).size.width - 44) / 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        if (controller.dashboardData.value == null) {
          return Column(
            children: [
              const StaffHeader(title: "Pro Admission"),
              Expanded(
                child: Center(
                  child: Text(
                    controller.errorMessage.value.isNotEmpty
                        ? controller.errorMessage.value
                        : "No data available",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ],
          );
        }

        final data = controller.dashboardData.value!;

        return Column(
          children: [
            const StaffHeader(title: "Pro Admission"),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Analysis Cards Grid
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _buildAnalysisCard(
                          "Total",
                          data.totalAdmissions.toString(),
                          IconifyIcons.humbleIconsUsers,
                          [const Color(0xFF7b84db), const Color(0xFF5a63ba)],
                          context,
                        ),
                        _buildAnalysisCard(
                          "Today",
                          data.today.toString(),
                          IconifyIcons.phCalendarCheckFill,
                          [const Color(0xFFffb84d), const Color(0xFFff9900)],
                          context,
                        ),
                        _buildAnalysisCard(
                          "Yesterday",
                          data.yesterday.toString(),
                          IconifyIcons.phCalendarCheckFill,
                          [const Color(0xFF2ebf8a), const Color(0xFF19a674)],
                          context,
                        ),
                        _buildAnalysisCard(
                          "This Week",
                          data.thisWeek.toString(),
                          IconifyIcons.phCalendarCheckFill,
                          [const Color(0xFFff6b6b), const Color(0xFFee5253)],
                          context,
                        ),
                        _buildAnalysisCard(
                          "This Month",
                          data.thisMonth.toString(),
                          IconifyIcons.phCalendarCheckFill,
                          [const Color(0xFF54a0ff), const Color(0xFF2e86de)],
                          context,
                        ),
                        _buildAnalysisCard(
                          "Last Month",
                          data.lastMonth.toString(),
                          IconifyIcons.phCalendarCheckFill,
                          [const Color(0xFF8b94e1), const Color(0xFF6c7cd1)],
                          context,
                        ),
                        _buildAnalysisCard(
                          "Boys",
                          data.boys.toString(),
                          IconifyIcons.account,
                          [const Color(0xFF54a0ff), const Color(0xFF2e86de)],
                          context,
                        ),
                        _buildAnalysisCard(
                          "Girls",
                          data.girls.toString(),
                          IconifyIcons.account,
                          [const Color(0xFFa2a8d3), const Color(0xFF858dbd)],
                          context,
                        ),
                        _buildAnalysisCard(
                          "Hostel",
                          data.hostel.toString(),
                          IconifyIcons.clarityBuildingLine,
                          [const Color(0xFFffca28), const Color(0xFFffb300)],
                          context,
                        ),
                        _buildAnalysisCard(
                          "Day",
                          data.day.toString(),
                          IconifyIcons.hugeIconsBus03,
                          [const Color(0xFF43a047), const Color(0xFF2e7d32)],
                          context,
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    _buildSectionHeader("Admission Analysis"),
                    const SizedBox(height: 12),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      childAspectRatio: 173 / 79,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      children: [
                        _buildAnalysisCard(
                          "Target",
                          data.target.toString(),
                          IconifyIcons.graphBarIncrease,
                          [const Color(0xFF7079D1), const Color(0xFF5560B9)],
                          context,
                        ),
                        _buildAnalysisCard(
                          "Paid",
                          data.paid.toString(),
                          IconifyIcons.feed32Filled,
                          [const Color(0xFFFDB75E), const Color(0xFFF7941D)],
                          context,
                        ),
                        _buildAnalysisCard(
                          "Not Paid",
                          data.notPaid.toString(),
                          IconifyIcons.feed32Filled,
                          [const Color(0xFF4DBB91), const Color(0xFF13A871)],
                          context,
                        ),
                        _buildAnalysisCard(
                          "Local",
                          data.local.toString(),
                          IconifyIcons.route,
                          [const Color(0xFF4DC4F4), const Color(0xFF1A9FD9)],
                          context,
                        ),
                        _buildAnalysisCard(
                          "Non-Local",
                          data.nonLocal.toString(),
                          IconifyIcons.hugeIconsBus03,
                          [const Color(0xFFE54D7E), const Color(0xFFD81B60)],
                          context,
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    _buildSectionHeader("Pro Admissions Analysis"),
                    const SizedBox(height: 10),
                    _buildLegend([
                      {
                        "label": "Total Admissions",
                        "color": const Color(0xFF1DB082),
                      },
                      {
                        "label": "Remaining Targets",
                        "color": const Color(0xFF6371D1),
                      },
                    ]),
                    const SizedBox(height: 25),

                    // Removed ScrollView - making it direct
                    _buildMonthOnMonthChart(),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.bold,
        color: Color(0xFFC62828),
        letterSpacing: -0.2,
      ),
    );
  }

  Widget _buildLegend(List<Map<String, dynamic>> items) {
    return Wrap(
      spacing: 20,
      runSpacing: 8,
      children: items.map((item) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: item['color'] as Color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              item['label'] as String,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildMonthOnMonthChart() {
    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 30,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              axisNameWidget: const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  "Months",
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value >= 0 && value < monthlyData.length) {
                    return SideTitleWidget(
                      // axisSide: meta.axisSide,
                      meta: meta,
                      child: Text(
                        monthlyData[value.toInt()]['month'],
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            leftTitles: AxisTitles(
              axisNameWidget: const Text(
                "Admissions Count",
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
              ),
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 5,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  );
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
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) =>
                FlLine(color: Colors.grey.withOpacity(0.2), strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(monthlyData.length, (index) {
            final data = monthlyData[index];
            final current = (data['current'] as int).toDouble();
            final previous = (data['previous'] as int).toDouble();

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: current + previous,
                  width: 14,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(2),
                    topRight: Radius.circular(2),
                  ),
                  rodStackItems: [
                    if (current > 0)
                      BarChartRodStackItem(0, current, const Color(0xFF4DC4F4)),
                    if (previous > 0)
                      BarChartRodStackItem(
                        current,
                        current + previous,
                        const Color(0xFF78909C),
                      ),
                  ],
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildAnalysisCard(
    String title,
    String value,
    String iconData,
    List<Color> colors,
    BuildContext context,
  ) {
    double cardWidth = (MediaQuery.of(context).size.width - 44) / 2;
    return Container(
      width: cardWidth,
      height: 79,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colors.last.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -15,
            left: -15,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
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
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        value,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 44,
                  height: 44,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Iconify(iconData, color: Colors.white, size: 28),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
