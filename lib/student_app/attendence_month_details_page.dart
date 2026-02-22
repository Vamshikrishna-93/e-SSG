import 'package:flutter/material.dart';
import 'package:student_app/student_app/services/attendance_service.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

import 'package:student_app/theme_controllers.dart';

class AttendanceMonthDetailPage extends StatefulWidget {
  final Map<String, dynamic> monthData;
  final String month;

  const AttendanceMonthDetailPage({
    super.key,
    required this.monthData,
    required this.month,
  });

  @override
  State<AttendanceMonthDetailPage> createState() =>
      _AttendanceMonthDetailPageState();
}

class _AttendanceMonthDetailPageState extends State<AttendanceMonthDetailPage> {
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  late Map<String, dynamic> _currentMonthData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentMonthData = widget.monthData;
    // synthesize if details are missing initially
    if (_isEmptyDetails(_currentMonthData)) {
      _currentMonthData = _addSynthesizedDetails(_currentMonthData);
    }
  }

  bool _isEmptyDetails(Map<String, dynamic> m) {
    final details = m['details'] ?? m['attendance_details'] ?? [];
    return details is! List || details.isEmpty;
  }

  Map<String, dynamic> _addSynthesizedDetails(Map<String, dynamic> m) {
    if (m.isEmpty) return m;
    final Map<String, dynamic> newMonthData = Map<String, dynamic>.from(m);
    final monthName = newMonthData['month'] ?? newMonthData['month_name'] ?? '';
    List<dynamic> details = [];

    for (int i = 1; i <= 31; i++) {
      final dayKey = 'Day_${i.toString().padLeft(2, '0')}';
      if (newMonthData.containsKey(dayKey) && newMonthData[dayKey] != null) {
        details.add({
          'attendance_date': '$i $monthName',
          'status': newMonthData[dayKey],
          'check_type': 'Class Attendance',
        });
      }
    }
    newMonthData['details'] = details;
    return newMonthData;
  }

  Future<void> _fetchMonthData() async {
    setState(() => _isLoading = true);
    try {
      final classAttendance = await AttendanceService.getAttendance();

      if (classAttendance.attendance.isNotEmpty) {
        final match = classAttendance.attendance.firstWhere(
          (m) => m.monthName == widget.month,
          orElse: () => classAttendance.attendance.first,
        );

        if (mounted) {
          setState(() {
            _currentMonthData = Map<String, dynamic>.from(match.rawJson);
            if (_isEmptyDetails(_currentMonthData)) {
              _currentMonthData = _addSynthesizedDetails(_currentMonthData);
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Error refreshing month details: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get attendanceDetails {
    // Extract details from the current month data
    final details =
        _currentMonthData['details'] ??
        _currentMonthData['attendance_details'] ??
        [];

    if (details is! List) return [];

    return details.map<Map<String, dynamic>>((d) {
      return {
        'date': d['attendance_date'] ?? d['date'] ?? '',
        'checkType': d['check_type'] ?? 'Class Attendance',
        'time': d['time'] ?? d['in_time'] ?? '',
        'instructor': d['instructor'] ?? d['faculty'] ?? '',
        'status': d['status'] ?? '',
        'remark': d['remarks'] ?? d['remark'] ?? '',
      };
    }).toList();
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  int _calculatePerformanceStars(double percentage) {
    if (percentage >= 90) return 5;
    if (percentage >= 80) return 4;
    if (percentage >= 70) return 3;
    if (percentage >= 60) return 2;
    return 1;
  }

  String _getPerformanceText(double percentage) {
    if (percentage >= 90) return 'Excellent';
    if (percentage >= 80) return 'Very Good';
    if (percentage >= 70) return 'Good';
    if (percentage >= 60) return 'Average';
    return 'Needs Improvement';
  }

  @override
  Widget build(BuildContext context) {
    return ThemeControllerWrapper(
      themeController: StudentThemeController.themeMode,
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;
          final monthData = _currentMonthData;

          final int totalRecordedDays = monthData['total'] ?? 0;
          final int presentDays = monthData['present'] ?? 0;
          final int absentDays = monthData['absent'] ?? 0;
          final int leaveDays = monthData['leaves'] ?? 0;
          final int outingDays = monthData['outings'] ?? 0;
          final int holidayDays = monthData['holidays'] ?? 0;
          final double attendancePercentage = monthData['percentage'] ?? 0.0;
          final int totalDays = monthData['total'] ?? 0;
          final String month =
              monthData['month'] ?? monthData['month_name'] ?? '';

          final int performanceStars = _calculatePerformanceStars(
            attendancePercentage,
          );
          final String performanceText = _getPerformanceText(
            attendancePercentage,
          );

          return Scaffold(
            backgroundColor: isDark
                ? Colors.grey.shade900.withValues(alpha: 0.95)
                : Colors.grey.shade300.withValues(alpha: 0.95),
            body: SafeArea(
              child: Center(
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(
                    maxWidth: 900,
                    maxHeight: 850,
                  ),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Header with title
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 20,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: isDark
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade200,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Day-wise attendance breakdown - $month',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.color,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: _isLoading ? null : _fetchMonthData,
                              icon: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.blue,
                                      ),
                                    )
                                  : Icon(
                                      Icons.refresh,
                                      color: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge?.color,
                                    ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: Icon(
                                Icons.close,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Scrollable content
                      Expanded(
                        child: Scrollbar(
                          controller: _verticalScrollController,
                          thumbVisibility: true,
                          thickness: 8,
                          radius: const Radius.circular(4),
                          child: SingleChildScrollView(
                            controller: _verticalScrollController,
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Attendance Summary Cards
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: [
                                    _buildSummaryCard(
                                      value: presentDays.toString(),
                                      label: 'Present Days',
                                      accent: isDark
                                          ? Colors.green.shade600
                                          : const Color(0xFF10B981),
                                      background: isDark
                                          ? Colors.green.shade900.withOpacity(
                                              0.25,
                                            )
                                          : const Color(0xFFD1FAE5),
                                      isDark: isDark,
                                    ),
                                    _buildSummaryCard(
                                      value: absentDays.toString(),
                                      label: 'Absent Days',
                                      accent: isDark
                                          ? Colors.red.shade600
                                          : const Color(0xFFEF4444),
                                      background: isDark
                                          ? Colors.red.shade900.withOpacity(
                                              0.25,
                                            )
                                          : const Color(0xFFFEE2E2),
                                      isDark: isDark,
                                    ),
                                    _buildSummaryCard(
                                      value: leaveDays.toString(),
                                      label: 'Leave Days',
                                      accent: isDark
                                          ? Colors.orange.shade600
                                          : const Color(0xFFF97316),
                                      background: isDark
                                          ? Colors.orange.shade900.withOpacity(
                                              0.25,
                                            )
                                          : const Color(0xFFFFF7ED),
                                      isDark: isDark,
                                    ),
                                    _buildSummaryCard(
                                      value: outingDays.toString(),
                                      label: 'Outings',
                                      accent: isDark
                                          ? Colors.purple.shade600
                                          : const Color(0xFF8B5CF6),
                                      background: isDark
                                          ? Colors.purple.shade900.withOpacity(
                                              0.25,
                                            )
                                          : const Color(0xFFF5F3FF),
                                      isDark: isDark,
                                    ),
                                    _buildSummaryCard(
                                      value: holidayDays.toString(),
                                      label: 'Holidays',
                                      accent: isDark
                                          ? Colors.cyan.shade600
                                          : const Color(0xFF06B6D4),
                                      background: isDark
                                          ? Colors.cyan.shade900.withOpacity(
                                              0.25,
                                            )
                                          : const Color(0xFFECFEFF),
                                      isDark: isDark,
                                    ),
                                    _buildSummaryCard(
                                      value:
                                          '${attendancePercentage.toStringAsFixed(0)}%',
                                      label: 'Attendance',
                                      accent: isDark
                                          ? Colors.blue.shade600
                                          : const Color(0xFF2563EB),
                                      background: isDark
                                          ? Colors.blue.shade900.withOpacity(
                                              0.25,
                                            )
                                          : const Color(0xFFDBEAFE),
                                      isDark: isDark,
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 20),

                                // Month Performance Card
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.grey.shade800
                                        : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Month Performance: $performanceText',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Theme.of(
                                                  context,
                                                ).textTheme.bodyLarge?.color,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Total Days: $totalDays | Recorded Days: $totalRecordedDays',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: isDark
                                                    ? Colors.grey.shade400
                                                    : const Color(0xFF64748B),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: attendancePercentage >= 90
                                              ? (isDark
                                                    ? Colors.green.shade900
                                                          .withValues(
                                                            alpha: 0.5,
                                                          )
                                                    : const Color(0xFFD1FAE5))
                                              : attendancePercentage >= 70
                                              ? (isDark
                                                    ? Colors.orange.shade900
                                                          .withValues(
                                                            alpha: 0.5,
                                                          )
                                                    : const Color(0xFFFFF7ED))
                                              : (isDark
                                                    ? Colors.red.shade900
                                                          .withValues(
                                                            alpha: 0.5,
                                                          )
                                                    : const Color(0xFFFEE2E2)),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          '${attendancePercentage.toStringAsFixed(1)}%',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: attendancePercentage >= 90
                                                ? (isDark
                                                      ? Colors.green.shade300
                                                      : const Color(0xFF10B981))
                                                : attendancePercentage >= 70
                                                ? (isDark
                                                      ? Colors.orange.shade300
                                                      : const Color(0xFFF97316))
                                                : (isDark
                                                      ? Colors.red.shade300
                                                      : const Color(
                                                          0xFFEF4444,
                                                        )),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Day-wise Attendance Details Section
                                Row(
                                  children: [
                                    Icon(
                                      Icons.description,
                                      size: 20,
                                      color: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge?.color,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Day-wise Attendance Details',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(
                                          context,
                                        ).textTheme.bodyLarge?.color,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // Show "No data" if attendance details is empty
                                if (attendanceDetails.isEmpty)
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(40),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.grey.shade800
                                          : const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isDark
                                            ? Colors.grey.shade700
                                            : const Color(0xFFE2E8F0),
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.inbox_outlined,
                                          size: 48,
                                          color: isDark
                                              ? Colors.grey.shade600
                                              : Colors.grey.shade400,
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'No data',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: isDark
                                                ? Colors.grey.shade400
                                                : const Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                else ...[
                                  // Horizontal Scrollbar (top)
                                  _buildHorizontalScrollbar(isDark),
                                  const SizedBox(height: 8),

                                  // Table with horizontal scroll
                                  Scrollbar(
                                    controller: _horizontalScrollController,
                                    thumbVisibility: true,
                                    thickness: 8,
                                    radius: const Radius.circular(4),
                                    child: SingleChildScrollView(
                                      controller: _horizontalScrollController,
                                      scrollDirection: Axis.horizontal,
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          minWidth: 800,
                                        ),
                                        child: _buildAttendanceTable(isDark),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  // Horizontal Scrollbar (bottom)
                                  _buildHorizontalScrollbar(isDark),
                                ],
                                const SizedBox(height: 24),

                                // Monthly Statistics Section
                                Text(
                                  'Monthly Statistics',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.color,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Statistics Grid
                                Container(
                                  padding: const EdgeInsets.all(20),

                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.grey.shade800
                                        : const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildStatItem(
                                              'Total Recorded Days',
                                              totalRecordedDays.toString(),
                                              null,
                                              isDark,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: _buildStatItem(
                                              'Present Days',
                                              presentDays.toString(),
                                              null,
                                              isDark,
                                              iconColor: isDark
                                                  ? Colors.green.shade400
                                                  : const Color(0xFF10B981),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildStatItem(
                                              'Absent Days',
                                              absentDays.toString(),
                                              null,
                                              isDark,
                                              iconColor: isDark
                                                  ? Colors.red.shade400
                                                  : const Color(0xFFEF4444),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: _buildStatItem(
                                              'Leave Days',
                                              leaveDays.toString(),
                                              null,
                                              isDark,
                                              iconColor: isDark
                                                  ? Colors.orange.shade400
                                                  : const Color(0xFFF97316),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildStatItem(
                                              'Attendance Percentage',
                                              '${attendancePercentage.toStringAsFixed(1)}%',
                                              null,
                                              isDark,
                                              valueColor:
                                                  attendancePercentage >= 90
                                                  ? (isDark
                                                        ? Colors.green.shade400
                                                        : const Color(
                                                            0xFF10B981,
                                                          ))
                                                  : attendancePercentage >= 70
                                                  ? (isDark
                                                        ? Colors.orange.shade400
                                                        : const Color(
                                                            0xFFF97316,
                                                          ))
                                                  : (isDark
                                                        ? Colors.red.shade400
                                                        : const Color(
                                                            0xFFEF4444,
                                                          )),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: _buildStatItem(
                                              'Performance Rating',
                                              '',
                                              null,
                                              isDark,
                                              showStars: true,
                                              starCount: performanceStars,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Action Buttons
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: isDark
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade200,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                side: BorderSide(
                                  color: isDark
                                      ? Colors.grey.shade600
                                      : Colors.grey.shade400,
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Close',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.color,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              onPressed: () async {
                                try {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Preparing report..."),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );

                                  final data =
                                      await AttendanceService.downloadAttendanceReport(
                                        year: '2024-2025',
                                      );

                                  final directory =
                                      await getTemporaryDirectory();
                                  final filePath =
                                      '${directory.path}/class_attendance_report_${widget.month}.pdf';
                                  final file = File(filePath);

                                  await file.writeAsBytes(data);

                                  if (context.mounted) {
                                    ScaffoldMessenger.of(
                                      context,
                                    ).hideCurrentSnackBar();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Report ready: class_attendance_report_${widget.month}.pdf",
                                        ),
                                        action: SnackBarAction(
                                          label: "Open",
                                          textColor: Colors.white,
                                          onPressed: () {
                                            OpenFilex.open(filePath);
                                          },
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(
                                      context,
                                    ).hideCurrentSnackBar();
                                    String errorMsg = e.toString();
                                    if (errorMsg.contains(
                                          'MissingPluginException',
                                        ) ||
                                        errorMsg.contains(
                                          'Unsupported operation',
                                        )) {
                                      errorMsg =
                                          "App restart required to activate download plugin. Please stop and re-run the app.";
                                    }
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(errorMsg),
                                        backgroundColor: Colors.red,
                                        duration: const Duration(seconds: 5),
                                      ),
                                    );
                                  }
                                }
                              },
                              icon: const Icon(Icons.download, size: 14),
                              label: const Text(
                                'Download Month Report (PDF)',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF7C3AED),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard({
    required String value,
    required String label,
    required Color accent,
    required Color background,
    required bool isDark,
  }) {
    return Container(
      width: 150, // fixed modern card width (prevents overflow)
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData? icon,
    bool isDark, {
    Color? iconColor,
    bool showStars = false,
    int starCount = 0,
    Color? valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 6),
            ],
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? Colors.grey.shade400
                      : const Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (showStars)
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < starCount ? Icons.star : Icons.star_border,
                size: 20,
                color: index < starCount
                    ? (isDark ? Colors.yellow.shade400 : Colors.amber)
                    : (isDark ? Colors.grey.shade600 : Colors.grey.shade400),
              );
            }),
          )
        else
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: valueColor ?? Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
      ],
    );
  }

  Widget _buildHorizontalScrollbar(bool isDark) {
    return Container(
      height: 20,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (_horizontalScrollController.hasClients) {
                _horizontalScrollController.animateTo(
                  (_horizontalScrollController.offset - 200).clamp(
                    0.0,
                    _horizontalScrollController.position.maxScrollExtent,
                  ),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
            child: Container(
              width: 24,
              height: 20,
              alignment: Alignment.center,
              child: Icon(
                Icons.arrow_back_ios,
                size: 12,
                color: isDark ? Colors.grey.shade400 : const Color(0xFF94A3B8),
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade700 : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              if (_horizontalScrollController.hasClients) {
                _horizontalScrollController.animateTo(
                  (_horizontalScrollController.offset + 200).clamp(
                    0.0,
                    _horizontalScrollController.position.maxScrollExtent,
                  ),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
            child: Container(
              width: 24,
              height: 20,
              alignment: Alignment.center,
              child: Icon(
                Icons.arrow_forward_ios,
                size: 12,
                color: isDark ? Colors.grey.shade400 : const Color(0xFF94A3B8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceTable(bool isDark) {
    return DataTable(
      headingRowColor: WidgetStateProperty.all(
        isDark ? Colors.grey.shade700 : const Color(0xFFF1F5F9),
      ),
      dataRowColor: WidgetStateProperty.all(
        isDark ? Colors.grey.shade800 : Colors.white,
      ),
      border: TableBorder.all(
        color: isDark ? Colors.grey.shade700 : const Color(0xFFE2E8F0),
        width: 1,
      ),
      columns: const [
        DataColumn(label: Text('Date')),
        DataColumn(label: Text('Check Type')),
        DataColumn(label: Text('Time')),
        DataColumn(label: Text('Instructor')),
        DataColumn(label: Text('Status')),
        DataColumn(label: Text('Remark')),
      ],
      rows: attendanceDetails.map((detail) {
        return DataRow(
          cells: [
            DataCell(Text(detail['date'] ?? '')),
            DataCell(Text(detail['checkType'] ?? '')),
            DataCell(Text(detail['time'] ?? '')),
            DataCell(Text(detail['instructor'] ?? '')),
            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      (detail['status'] == 'Present' || detail['status'] == 'P')
                      ? (isDark
                            ? Colors.green.shade900.withValues(alpha: 0.5)
                            : const Color(0xFFD1FAE5))
                      : (detail['status'] == 'Absent' ||
                            detail['status'] == 'A')
                      ? (isDark
                            ? Colors.red.shade900.withValues(alpha: 0.5)
                            : const Color(0xFFFEE2E2))
                      : (detail['status'] == 'Outing' ||
                            detail['status'] == 'O')
                      ? (isDark
                            ? Colors.purple.shade900.withValues(alpha: 0.5)
                            : const Color(0xFFF5F3FF))
                      : (detail['status'] == 'Holiday' ||
                            detail['status'] == 'H')
                      ? (isDark
                            ? Colors.cyan.shade900.withValues(alpha: 0.5)
                            : const Color(0xFFECFEFF))
                      : (isDark
                            ? Colors.orange.shade900.withValues(alpha: 0.5)
                            : const Color(0xFFFFF7ED)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  detail['status'] ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color:
                        (detail['status'] == 'Present' ||
                            detail['status'] == 'P')
                        ? (isDark
                              ? Colors.green.shade300
                              : const Color(0xFF10B981))
                        : (detail['status'] == 'Absent' ||
                              detail['status'] == 'A')
                        ? (isDark
                              ? Colors.red.shade300
                              : const Color(0xFFEF4444))
                        : (detail['status'] == 'Outing' ||
                              detail['status'] == 'O')
                        ? (isDark
                              ? Colors.purple.shade300
                              : const Color(0xFF8B5CF6))
                        : (detail['status'] == 'Holiday' ||
                              detail['status'] == 'H')
                        ? (isDark
                              ? Colors.cyan.shade300
                              : const Color(0xFF06B6D4))
                        : (isDark
                              ? Colors.orange.shade300
                              : const Color(0xFFF97316)),
                  ),
                ),
              ),
            ),
            DataCell(Text(detail['remark'] ?? '')),
          ],
        );
      }).toList(),
    );
  }
}
