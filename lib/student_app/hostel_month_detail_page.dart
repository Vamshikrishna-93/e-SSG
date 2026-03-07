import 'package:flutter/material.dart';
import 'package:student_app/student_app/model/hostel_attendance.dart';
import 'package:student_app/student_app/services/hostel_attendance_service.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class HostelMonthDetailPage extends StatefulWidget {
  final MonthlyAttendance monthData;
  final HostelAttendance? overallData;

  const HostelMonthDetailPage({
    super.key,
    required this.monthData,
    this.overallData,
  });

  @override
  State<HostelMonthDetailPage> createState() => _HostelMonthDetailPageState();
}

class _HostelMonthDetailPageState extends State<HostelMonthDetailPage> {
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  late MonthlyAttendance _currentMonthData;
  HostelAttendance? _overallData;

  @override
  void initState() {
    super.initState();
    _currentMonthData = widget.monthData;
    _overallData = widget.overallData;
  }

  String get hostelName => _overallData?.hostelName ?? "ADARSA";
  String get floor => _overallData?.floorName ?? "2ND FLOOR A&B BLOCKS";
  String get room => _overallData?.roomName ?? "B-204";
  String get warden => _overallData?.wardenName ?? "JENNIPOGU ABHI RAM";

  List<Map<String, dynamic>> get attendanceDetails {
    final List<DayAttendance> details = _currentMonthData.details ?? [];

    // Fallback to rawJson if details are not synthesized but exist in another format
    if (details.isEmpty && _currentMonthData.rawJson.containsKey('details')) {
      final list = _currentMonthData.rawJson['details'] as List;
      return list.map((d) => d as Map<String, dynamic>).toList();
    }

    return details
        .map(
          (d) => {
            'date': d.date,
            'checkType': 'Hostel Stay',
            'time': d.status == 'P' ? '10:00 PM' : 'N/A',
            'warden': warden,
            'status': d.status,
            'remark': d.status == 'P' ? 'In Campus' : 'Out of Campus',
          },
        )
        .toList();
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

    final int totalRecordedNights = monthData.total;
    final int presentNights = monthData.present;
    final int absentNights = monthData.absent;
    final int leaveNights = (monthData.rawJson['leaves'] ?? 0) as int;
    final int holidayNights = (monthData.rawJson['holidays'] ?? 0) as int;
    final int nightOuts =
        (monthData.rawJson['nightOuts'] ?? monthData.outings) as int;
    final double attendancePercentage = monthData.percentage;
    final int totalNights = monthData.total;

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
                  'Night-Wise',
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
                  const Text(
                    'Night-Wise hostel stay breakdown',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Hostel Information
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEBF5FB),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Hostel Information',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow('Hostel', hostelName),
                        const SizedBox(height: 8),
                        _buildInfoRow('Floor', floor),
                        const SizedBox(height: 8),
                        _buildInfoRow('Room', room),
                        const SizedBox(height: 8),
                        _buildInfoRow('Warden', warden),
                      ],
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
                        'Present Nights',
                        presentNights.toString(),
                        const Color(0xFF10B981),
                        const Color(0xFFE6F7F0),
                      ),
                      _buildSummaryCard(
                        'Absent Nights',
                        absentNights.toString(),
                        const Color(0xFFEF4444),
                        const Color(0xFFFDECEC),
                      ),
                      _buildSummaryCard(
                        'Leave Nights',
                        leaveNights.toString(),
                        const Color(0xFFF97316),
                        const Color(0xFFFEF2E4),
                      ),
                      _buildSummaryCard(
                        'Attendance',
                        '${attendancePercentage.toStringAsFixed(0)}%',
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
                                  fontSize: 14, // Adjusted for image match
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Total Nights: $totalNights | Recorded Nights: $totalRecordedNights',
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
                    'Night-Wise Attendance Details',
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
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.network(
                            'https://cdn-icons-png.flaticon.com/512/7486/7486744.png',
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

                        if (status.contains('present') || status == 'p') {
                          statusColor = const Color(0xFF10B981);
                          statusBg = const Color(0xFFE6F7F0);
                        } else if (status.contains('absent') || status == 'a') {
                          statusColor = const Color(0xFFEF4444);
                          statusBg = const Color(0xFFFDECEC);
                        } else if (status.contains('leave') || status == 'l') {
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
                                          detail['checkType'] ?? 'Hostel Stay',
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
                                    if ((detail['warden'] ?? '')
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
                                            detail['warden'],
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
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatRow(
                                'Total Recorded Nights',
                                totalRecordedNights.toString(),
                              ),
                            ),
                            Expanded(
                              child: _buildStatRow(
                                'Present Nights',
                                presentNights.toString(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatRow(
                                'Absent Nights',
                                absentNights.toString(),
                              ),
                            ),
                            Expanded(
                              child: _buildStatRow(
                                'Leave Nights',
                                leaveNights.toString(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatRow(
                                'Holiday Nights',
                                holidayNights.toString(),
                              ),
                            ),
                            Expanded(
                              child: _buildStatRow(
                                'Nights Outs',
                                nightOuts.toString(),
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
                onPressed: () async {
                  try {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Preparing report..."),
                        duration: Duration(seconds: 1),
                      ),
                    );

                    final data =
                        await HostelAttendanceService.downloadHostelAttendanceReport(
                          year: '2024-2025',
                        );

                    final directory = await getTemporaryDirectory();
                    final filePath =
                        '${directory.path}/hostel_attendance_report.pdf';
                    final file = File(filePath);

                    await file.writeAsBytes(data);

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Report ready: hostel_attendance_report.pdf",
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
                            "App restart required to activate download plugin.";
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

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
