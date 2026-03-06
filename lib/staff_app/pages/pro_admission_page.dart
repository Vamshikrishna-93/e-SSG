import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';

class ProAdmissionPage extends StatelessWidget {
  const ProAdmissionPage({super.key});

  static const List<Map<String, dynamic>> admissionsData = [
    {"pro": "SUBBARAO-HRAO", "target": 250, "achieved": 186},
    {"pro": "MEERA REDDY", "target": 200, "achieved": 137},
    {"pro": "CHIRANJEEVI - NAGARAJU", "target": 125, "achieved": 112},
    {"pro": "PARVEEN-NAGALAKSHMI", "target": 100, "achieved": 111},
    {"pro": "AO SRINIVAS-BASAVAIAH", "target": 180, "achieved": 104},
    {"pro": "RAMESH -HARI-MADDIPADU", "target": 100, "achieved": 104},
    {"pro": "N SRINU-TANGUTUR", "target": 180, "achieved": 103},
    {"pro": "B T NAIDU", "target": 125, "achieved": 100},
    {"pro": "JURI VENKATA RAO", "target": 150, "achieved": 90},
    {"pro": "ARUN KUMAR", "target": 120, "achieved": 85},
  ];

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
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Analysis Cards Grid
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildAnalysisCard(
                        "Target",
                        "5965",
                        Icons.track_changes_rounded,
                        [const Color(0xFF7079D1), const Color(0xFF5560B9)],
                        context,
                      ),
                      _buildAnalysisCard(
                        "Paid",
                        "3060",
                        Icons.monetization_on_rounded,
                        [const Color(0xFFFDB75E), const Color(0xFFF18C33)],
                        context,
                      ),
                      _buildAnalysisCard(
                        "Not Paid",
                        "14",
                        Icons.account_balance_wallet_rounded,
                        [const Color(0xFF4DBB91), const Color(0xFF13A871)],
                        context,
                      ),
                      _buildAnalysisCard(
                        "Local",
                        "698",
                        Icons.location_on_rounded,
                        [const Color(0xFF4DC4F4), const Color(0xFF1A9FD9)],
                        context,
                      ),
                      _buildAnalysisCard(
                        "Non-Local",
                        "0",
                        Icons.directions_bus_rounded,
                        [const Color(0xFFEE638F), const Color(0xFFD81B60)],
                        context,
                      ),
                    ],
                  ),
                  const SizedBox(height: 35),
                  _buildSectionHeader("Pro Admissions Analysis"),
                  const SizedBox(height: 12),
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
                  SizedBox(
                    height: 260,
                    width: double.infinity,
                    child: _buildAnalysisChart(),
                  ),
                  const SizedBox(height: 45),
                  _buildSectionHeader("Pro Year on Year Analytics"),
                  const SizedBox(height: 12),
                  _buildLegend([
                    {
                      "label": "2024-2025 Admissions",
                      "color": const Color(0xFF1A9FD9),
                    },
                    {
                      "label": "2025-2026 Admissions",
                      "color": const Color(0xFF1DB082),
                    },
                  ]),
                  const SizedBox(height: 25),
                  // Removed ScrollView
                  SizedBox(
                    height: 260,
                    width: double.infinity,
                    child: _buildYearOnYearChart(),
                  ),
                  const SizedBox(height: 45),
                  _buildSectionHeader(
                    "Admissions Month on Month\n(Session Wise)",
                  ),
                  const SizedBox(height: 35),
                  _buildMonthOnMonthChart(),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
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

  Widget _buildAnalysisChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceEvenly,
        maxY: 320,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 85,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 &&
                    value.toInt() < admissionsData.length) {
                  return SideTitleWidget(
                    meta: meta,
                    space: 5,
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: Text(
                        admissionsData[value.toInt()]['pro'],
                        style: const TextStyle(
                          fontSize: 7.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 80,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 11,
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
        barGroups: List.generate(admissionsData.length, (index) {
          final data = admissionsData[index];
          final achieved = (data['achieved'] as int).toDouble();
          final target = (data['target'] as int).toDouble();
          final remaining = (target - achieved).clamp(0, 1000).toDouble();

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: achieved + remaining,
                width: 9,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(2),
                  topRight: Radius.circular(2),
                ),
                rodStackItems: [
                  BarChartRodStackItem(0, achieved, const Color(0xFF1DB082)),
                  BarChartRodStackItem(
                    achieved,
                    achieved + remaining,
                    const Color(0xFF6371D1),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildYearOnYearChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceEvenly,
        maxY: 1500,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 85,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 &&
                    value.toInt() < admissionsData.length) {
                  return SideTitleWidget(
                    meta: meta,
                    space: 5,
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: Text(
                        admissionsData[value.toInt()]['pro'],
                        style: const TextStyle(
                          fontSize: 7.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 35,
              interval: 300,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 11,
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
        barGroups: List.generate(admissionsData.length, (index) {
          double yValue = 300.0 + (index % 5) * 200.0;
          if (index == 8) yValue = 1200;
          if (index == 15) yValue = 1100;

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: yValue,
                width: 9,
                color: const Color(0xFF1A9FD9),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(2),
                  topRight: Radius.circular(2),
                ),
              ),
            ],
          );
        }),
      ),
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 25,
        left: 16,
        right: 16,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF8147E7),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(35),
          bottomRight: Radius.circular(35),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            "Pro Admission",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisCard(
    String title,
    String value,
    IconData icon,
    List<Color> colors,
    BuildContext context,
  ) {
    double cardWidth = (MediaQuery.of(context).size.width - 44) / 2;
    return Container(
      width: cardWidth,
      height: cardWidth / 1.7,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: colors.last.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -20,
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
            top: 15,
            right: 15,
            child: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
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
