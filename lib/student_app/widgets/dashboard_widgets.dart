import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

enum TimeRange { academicYear, last3Months, last6Months, lastMonth }

class AttendanceTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final bool isLast;

  const AttendanceTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class RankTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final bool isLast;
  final bool isHighlighted;

  const RankTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    this.isLast = false,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: isHighlighted
              ? iconColor.withOpacity(0.05)
              : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 52,
            endIndent: 16,
            color: Theme.of(context).dividerColor.withOpacity(0.1),
          ),
      ],
    );
  }
}

class TimeTableCard extends StatelessWidget {
  final String subject;
  final String time;
  final String instructor;
  final bool isLast;

  const TimeTableCard({
    super.key,
    required this.subject,
    required this.time,
    required this.instructor,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$time \u2022 $instructor",
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 32,
            endIndent: 16,
            color: Theme.of(context).dividerColor.withOpacity(0.1),
          ),
      ],
    );
  }
}

class AttendanceChart extends StatelessWidget {
  final List<String> months;
  final int maxValue;
  final List<Map<String, dynamic>> data;
  final bool isHostel;
  final TimeRange selectedRange;

  const AttendanceChart({
    super.key,
    required this.months,
    required this.maxValue,
    required this.data,
    required this.selectedRange,
    this.isHostel = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1.5,
          child: Row(
            children: [
              RotatedBox(
                quarterTurns: 3,
                child: Text(
                  'No. of Days',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxValue.toDouble(),
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (group) =>
                            Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey.shade900
                            : Colors.white,
                        tooltipPadding: const EdgeInsets.all(12),
                        tooltipMargin: 8,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          if (groupIndex < 0 ||
                              groupIndex >= data.length ||
                              groupIndex >= months.length)
                            return null;

                          final monthData = data[groupIndex];
                          final monthName = months[groupIndex];

                          if (rodIndex != 0) return null;

                          final present = monthData['present'] ?? 0;
                          final absent = monthData['absent'] ?? 0;
                          final outings = monthData['outings'] ?? 0;
                          final holidays = monthData['holidays'] ?? 0;
                          final total =
                              monthData['total'] ??
                              (present + absent + outings + holidays);
                          final percentage = total > 0
                              ? ((present / total) * 100).toStringAsFixed(1)
                              : '0.0';

                          return BarTooltipItem(
                            '',
                            const TextStyle(),
                            children: [
                              TextSpan(
                                text: '$monthName 2025\n',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.color,
                                ),
                              ),
                              const TextSpan(
                                text: '\n',
                                style: TextStyle(fontSize: 4),
                              ),
                              const TextSpan(
                                text: '\u25cf ',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 16,
                                ),
                              ),
                              TextSpan(
                                text: 'Present Days : $present\n',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.color,
                                ),
                              ),
                              const TextSpan(
                                text: '\u25cf ',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                ),
                              ),
                              TextSpan(
                                text: 'Absent Days : $absent\n',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.color,
                                ),
                              ),
                              if (!isHostel) ...[
                                const TextSpan(
                                  text: '\u25cf ',
                                  style: TextStyle(
                                    color: Colors.amber,
                                    fontSize: 16,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Outing Days : $outings\n',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.color,
                                  ),
                                ),
                                const TextSpan(
                                  text: '\u25cf ',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 16,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Holidays : $holidays\n',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.color,
                                  ),
                                ),
                              ] else ...[
                                const TextSpan(
                                  text: '\ud83c\udfe8 ',
                                  style: TextStyle(fontSize: 14),
                                ),
                                TextSpan(
                                  text:
                                      'Total Hostel Days : ${monthData['totalHostelDays'] ?? (present + absent)}\n',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.color,
                                  ),
                                ),
                              ],
                              const TextSpan(
                                text: '\n',
                                style: TextStyle(fontSize: 4),
                              ),
                              const TextSpan(
                                text: '\ud83d\udcc5 ',
                                style: TextStyle(fontSize: 14),
                              ),
                              TextSpan(
                                text: 'Working Days : $total\n',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.color,
                                ),
                              ),
                              const TextSpan(
                                text: '\ud83d\udcca ',
                                style: TextStyle(fontSize: 14),
                              ),
                              TextSpan(
                                text: isHostel
                                    ? 'Hostel Attendance % : $percentage%'
                                    : 'Attendance % : $percentage%',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.color,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 || index >= months.length)
                              return const SizedBox();
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                months[index],
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.color,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.blue.shade700,
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
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Colors.grey.withOpacity(0.1),
                        strokeWidth: 1,
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                        left: BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                    ),
                    barGroups: List.generate(data.length, (index) {
                      if (index >= months.length)
                        return BarChartGroupData(x: index, barRods: []);
                      final d = data[index];
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: (d['present'] ?? 0).toDouble(),
                            color: Colors.green,
                            width: 6,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                          BarChartRodData(
                            toY: (d['absent'] ?? 0).toDouble(),
                            color: Colors.red,
                            width: 6,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                          BarChartRodData(
                            toY: (d['outings'] ?? 0).toDouble(),
                            color: Colors.amber,
                            width: 6,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                          BarChartRodData(
                            toY: (d['holidays'] ?? 0).toDouble(),
                            color: Colors.blue,
                            width: 6,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          selectedRange == TimeRange.academicYear
              ? 'Academic Year'
              : selectedRange == TimeRange.last6Months
              ? 'Last 6 Months'
              : selectedRange == TimeRange.last3Months
              ? 'Last 3 Months'
              : 'Last Month',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade900,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class DashboardLegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const DashboardLegendItem({
    super.key,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }
}

class DashboardAnnouncementItem extends StatelessWidget {
  final Color iconColor;
  final String text;
  final String source;
  final bool isLast;

  const DashboardAnnouncementItem({
    super.key,
    required this.iconColor,
    required this.text,
    required this.source,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.campaign, color: iconColor, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      source,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 48,
            endIndent: 16,
            color: Theme.of(context).dividerColor.withOpacity(0.1),
          ),
      ],
    );
  }
}

class DashboardSectionCard extends StatelessWidget {
  final String title;
  final String emptyMessage;
  final String buttonText;
  final VoidCallback onTap;

  const DashboardSectionCard({
    super.key,
    required this.title,
    required this.emptyMessage,
    required this.buttonText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                Divider(
                  height: 24,
                  thickness: 1,
                  color: Theme.of(context).dividerColor.withOpacity(0.1),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  emptyMessage,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade400
                        : Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: 250,
                  child: ElevatedButton.icon(
                    onPressed: onTap,
                    icon: const Icon(
                      Icons.visibility,
                      size: 16,
                      color: Colors.white,
                    ),
                    label: Text(
                      buttonText,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
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
}
