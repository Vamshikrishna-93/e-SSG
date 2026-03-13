import 'package:flutter/material.dart';
import 'package:student_app/student_app/services/attendance_service.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

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

  Future<void> _downloadReport() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Preparing report..."),
          duration: Duration(seconds: 1),
        ),
      );

      final data = await AttendanceService.downloadAttendanceReport(
        year: '2024-2025',
      );

      final directory = await getTemporaryDirectory();
      final filePath =
          '${directory.path}/class_attendance_report_${widget.month}.pdf';
      final file = File(filePath);

      await file.writeAsBytes(data);

      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
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
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        String errorMsg = e.toString();
        if (errorMsg.contains('MissingPluginException') ||
            errorMsg.contains('Unsupported operation')) {
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
    final monthData = _currentMonthData;

    final int totalRecordedDays = monthData['total'] ?? 0;
    final int presentDays = monthData['present'] ?? 0;
    final int absentDays = monthData['absent'] ?? 0;
    final int leaveDays = monthData['leaves'] ?? 0;
    final double attendancePercentage = monthData['percentage'] ?? 0.0;
    final String month = monthData['month'] ?? monthData['month_name'] ?? '';

    final int performanceStars = _calculatePerformanceStars(
      attendancePercentage,
    );
    final String performanceText = _getPerformanceText(attendancePercentage);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 10,
              bottom: 25,
              left: 20,
              right: 20,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF7E49FF),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Day-Wise Attendance',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Day-wise attendance breakdown-\n($month)',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Summary Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    children: [
                      _buildSummaryCard(
                        'Present Days',
                        presentDays.toString(),
                        const Color(0xFF10B981),
                        const Color(0xFFE6F7F0),
                      ),
                      _buildSummaryCard(
                        'Absent Days',
                        absentDays.toString(),
                        const Color(0xFFEF4444),
                        const Color(0xFFFDECEC),
                      ),
                      _buildSummaryCard(
                        'Leave Days',
                        leaveDays.toString(),
                        const Color(0xFFF97316),
                        const Color(0xFFFEF2E4),
                      ),
                      _buildSummaryCard(
                        'Attendance',
                        '00:00:99', // As per image
                        const Color(0xFF3B82F6),
                        const Color(0xFFE7F0FF),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Performance Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEBF5FB),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Monthly Performance: $performanceText',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Total Days: ${monthData['total'] ?? 0} | Recorded Days: $totalRecordedDays',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFDECEC),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${attendancePercentage.toStringAsFixed(1)} %',
                            style: const TextStyle(
                              color: Color(0xFFEF4444),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Attendance Details Title
                  const Text(
                    'Day-Wise Attendance Details',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  // Attendance Details List
                  if (attendanceDetails.isEmpty)
                    Container(
                      width: double.infinity,
                      height: 150,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBF5FB),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.network(
                            'https://cdn-icons-png.flaticon.com/512/7486/7486744.png', // Placeholder for "No Data" icon
                            height: 60,
                            color: Colors.grey,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.folder_off,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'No Data',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: attendanceDetails.length,
                      padding: EdgeInsets.zero,
                      itemBuilder: (context, index) {
                        final detail = attendanceDetails[index];
                        final status = (detail['status'] ?? '')
                            .toString()
                            .toLowerCase();

                        Color statusColor = Colors.grey;
                        Color statusBg = Colors.grey.shade100;

                        if (status.contains('present')) {
                          statusColor = const Color(0xFF10B981);
                          statusBg = const Color(0xFFE6F7F0);
                        } else if (status.contains('absent')) {
                          statusColor = const Color(0xFFEF4444);
                          statusBg = const Color(0xFFFDECEC);
                        } else if (status.contains('leave')) {
                          statusColor = const Color(0xFFF97316);
                          statusBg = const Color(0xFFFEF2E4);
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      detail['date'] ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.category_outlined,
                                          size: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          detail['checkType'] ??
                                              'Class Attendance',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if ((detail['time'] ?? '')
                                        .toString()
                                        .isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            size: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            detail['time'],
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                    if ((detail['instructor'] ?? '')
                                        .toString()
                                        .isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.person_outline,
                                            size: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            detail['instructor'],
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: statusBg,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  (detail['status'] ?? '')
                                      .toString()
                                      .toUpperCase(),
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 20),

                  // Monthly Statitics
                  const Text(
                    'Monthly Statitics',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEBF5FB),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatRow(
                                'Total Recorded Days',
                                totalRecordedDays.toString(),
                              ),
                            ),
                            Expanded(
                              child: _buildStatRow(
                                'Present Days',
                                presentDays.toString(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatRow(
                                'Absent Days',
                                absentDays.toString(),
                              ),
                            ),
                            Expanded(
                              child: _buildStatRow(
                                'Leave Days',
                                leaveDays.toString(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatRow(
                                'Attendance Percentage',
                                '${attendancePercentage.toStringAsFixed(1)}%',
                                valueColor: const Color(0xFFEF4444),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Performance Rating',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: List.generate(5, (index) {
                                      return Icon(
                                        Icons.star,
                                        size: 14,
                                        color: index < performanceStars
                                            ? Colors.amber
                                            : Colors.grey,
                                      );
                                    }),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Footer Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF818CF8), Color(0xFFC084FC)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ElevatedButton(
                onPressed: _downloadReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Download Month Report (PDF)',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String label,
    String value,
    Color accentColor,
    Color bgColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black87),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.black,
          ),
        ),
      ],
    );
  }
}
