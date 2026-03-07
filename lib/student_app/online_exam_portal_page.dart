import 'dart:async';
import 'package:flutter/material.dart';
import 'package:student_app/student_app/model/exam_item.dart';
import 'package:student_app/student_app/services/student_profile_service.dart';
import 'package:student_app/student_app/exam_portal_writing_page.dart';

class OnlineExamPortalPage extends StatefulWidget {
  final ExamModel exam;

  const OnlineExamPortalPage({super.key, required this.exam});

  @override
  State<OnlineExamPortalPage> createState() => _OnlineExamPortalPageState();
}

class _OnlineExamPortalPageState extends State<OnlineExamPortalPage> {
  int _secondsRemaining = 30;
  Timer? _timer;
  Map<String, dynamic>? _studentData;
  // ignore: unused_field
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _fetchStudentProfile();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer?.cancel();
        _navigateToExam();
      }
    });
  }

  void _navigateToExam() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ExamPortalWritingPage(exam: widget.exam),
        ),
      );
    }
  }

  Future<void> _fetchStudentProfile() async {
    try {
      final profile = await StudentProfileService.getProfile();
      if (mounted) {
        setState(() {
          _studentData = profile['data'];
          _isLoadingProfile = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const scaffoldBackgroundColor = Colors.white;

    // Extract student info
    final studentName = _studentData != null
        ? "${_studentData!['sfname'] ?? ''} ${_studentData!['slname'] ?? ''}"
              .trim()
        : "Loading...";
    final hallTicketNo = _studentData != null
        ? (_studentData!['admno']?.toString() ?? "N/A")
        : "N/A";
    final groupName = _studentData != null
        ? (_studentData!['course_name'] ?? "N/A")
        : "N/A";
    final branchName = _studentData != null
        ? (_studentData!['branch_name'] ?? "N/A")
        : "N/A";

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 32,
                  horizontal: 20,
                ),
                decoration: const BoxDecoration(color: Color(0xFF007BFF)),
                child: Column(
                  children: [
                    Text(
                      widget.exam.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Online Examination Portal",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Student Information Card
                    _buildInfoCard(
                      title: "Student Information",
                      children: [
                        _buildInfoRow(
                          "Student Name",
                          studentName,
                          iconColor: Colors.blue,
                        ),
                        _buildInfoRow(
                          "Hall Ticket No",
                          hallTicketNo,
                          iconColor: Colors.blue,
                        ),
                        _buildInfoRow(
                          "Group",
                          groupName,
                          iconColor: Colors.blue,
                        ),
                        _buildInfoRow(
                          "Branch",
                          branchName,
                          iconColor: Colors.blue,
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Timer Text
                    Text(
                      "Instructions will disappear in: $_secondsRemaining seconds",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: _secondsRemaining > 15
                            ? Colors.black87
                            : Colors.orange.shade700,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // General Instructions Card
                    if (_secondsRemaining > 0)
                      _buildInfoCard(
                        title: "General Instructions",
                        titleIcon: Icons.assignment_outlined,
                        children: [
                          _buildDetailRow(
                            "Total Duration:",
                            widget.exam.duration ?? "3 hours",
                          ),
                          _buildDetailRow(
                            "Total Questions:",
                            "${widget.exam.questions ?? 0} questions",
                          ),
                          _buildDetailRow(
                            "Subjects:",
                            "1 subjects",
                          ), // Assuming 1 for simplicity or derive from data
                          _buildDetailRow(
                            "Full Screen Policy:",
                            "Fullscreen mode is required",
                          ),
                          _buildDetailRow(
                            "Security:",
                            "Do not switch tabs or windows",
                          ),
                        ],
                      ),

                    const SizedBox(height: 48),

                    // Start Test Button
                    SizedBox(
                      width: 220,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ExamPortalWritingPage(exam: widget.exam),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF28A745),
                          foregroundColor: Colors.white,
                          elevation: 8,
                          shadowColor: Colors.green.withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.play_arrow, size: 24),
                            SizedBox(width: 12),
                            Text(
                              "START TEST",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    IconData? titleIcon,
    required List<Widget> children,
  }) {
    const cardColor = Colors.white;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: titleIcon != null
                ? const BoxDecoration(
                    color: Color(0xFF007BFF),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  )
                : null,
            child: Row(
              children: [
                if (titleIcon != null) ...[
                  Icon(titleIcon, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: titleIcon != null
                        ? Colors.white
                        : const Color(0xFF007BFF),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {required Color iconColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                width: 4,
                height: 32,
                decoration: BoxDecoration(
                  color: iconColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Divider(color: Colors.grey.withOpacity(0.2), height: 1),
        ],
      ),
    );
  }
}
