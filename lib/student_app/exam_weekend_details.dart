import 'package:flutter/material.dart';
import 'package:student_app/student_app/model/exam_item.dart';
import 'package:student_app/student_app/services/exams_service.dart';

class ExamWeekendDetails extends StatefulWidget {
  final String examId;
  const ExamWeekendDetails({super.key, required this.examId});

  @override
  State<ExamWeekendDetails> createState() => _ExamWeekendDetailsState();
}

class _ExamWeekendDetailsState extends State<ExamWeekendDetails> {
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic> _examData = {};

  // Fallback exam from local data
  ExamModel? _localExam;

  @override
  void initState() {
    super.initState();
    _findLocalExam();
    _fetchExamDetails();
  }

  /// Try to find the exam in local ExamModel lists as fallback
  void _findLocalExam() {
    final allExams = [
      ...ExamModel.onlineExams,
      ...ExamModel.upcomingExams,
      ...ExamModel.completedExams,
      ...ExamModel.offlineExams,
    ];
    try {
      _localExam = allExams.firstWhere((e) => e.id == widget.examId);
    } catch (_) {
      _localExam = null;
    }
  }

  Future<void> _fetchExamDetails() async {
    try {
      final data = await ExamsService.getExamDetails(widget.examId);
      if (mounted) {
        setState(() {
          _examData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  /// Safely get a value from API data with fallback
  String _getValue(String apiKey, String? localFallback) {
    // Try multiple possible keys from API response
    final student = _examData['student'] ?? {};
    final exam = _examData['exam'] ?? {};
    final data = _examData['data'] ?? {};

    // Check exam object first, then student, then top-level data, then top-level
    final value =
        exam[apiKey] ?? student[apiKey] ?? data[apiKey] ?? _examData[apiKey];

    if (value != null && value.toString().isNotEmpty) {
      return value.toString();
    }
    return localFallback ?? 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    // Loading state
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // If API failed but we have local data, use it instead of showing error
    final bool hasApiData = _errorMessage == null && _examData.isNotEmpty;
    final bool hasLocalData = _localExam != null;

    // Error state - only show if we have no data at all
    if (_errorMessage != null && !hasLocalData) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  "Failed to load exam details.\n$_errorMessage",
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });
                  _fetchExamDetails();
                },
                icon: const Icon(Icons.refresh),
                label: const Text("Retry"),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Go Back"),
              ),
            ],
          ),
        ),
      );
    }

    // Parse data — use API data with local fallback
    final examName = _getValue('exam_name', _localExam?.title) != 'N/A'
        ? _getValue('exam_name', _localExam?.title)
        : _getValue('examname', _localExam?.title);
    final studentName = _getValue('student_name', null);
    final branch = _getValue('branch', _localExam?.board) != 'N/A'
        ? _getValue('branch', _localExam?.board)
        : _getValue('branch_name', _localExam?.board);
    final examId = _getValue('exam_id', _localExam?.id) != 'N/A'
        ? _getValue('exam_id', _localExam?.id)
        : widget.examId;
    final hallticket = _getValue('hallticket', null);
    final group = _getValue('group', null);
    final examDate = _getValue('date', _localExam?.date) != 'N/A'
        ? _getValue('date', _localExam?.date)
        : _getValue('exam_date', _localExam?.date);
    final examTime = _getValue('timefrom', _localExam?.time) != 'N/A'
        ? _getValue('timefrom', _localExam?.time)
        : _getValue('exam_time', _localExam?.time);
    final duration = _getValue('duration', _localExam?.duration);
    final totalQuestions =
        _getValue('questions_count', _localExam?.questions?.toString()) != 'N/A'
        ? _getValue('questions_count', _localExam?.questions?.toString())
        : _getValue('total_questions', _localExam?.questions?.toString());
    final totalMarks =
        _getValue('exam_total_marks', _localExam?.passingMarks) != 'N/A'
        ? _getValue('exam_total_marks', _localExam?.passingMarks)
        : _getValue('total_marks', _localExam?.marks);
    final examType = _getValue('exam_type', _localExam?.type);
    final platform = _getValue(
      'platform',
      _localExam?.platform ?? 'Online Portal',
    );
    final isProctored = _localExam?.isProctored ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : 32,
            vertical: isMobile ? 20 : 40,
          ),
          child: Material(
            elevation: 24,
            shadowColor: Colors.black.withOpacity(0.45),
            borderRadius: BorderRadius.circular(14),
            color: Colors.white,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 900,
                maxHeight: MediaQuery.of(context).size.height * 0.9,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// BACK + HEADER
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Color(0xFF1E293B),
                          ),
                          onPressed: () => Navigator.pop(context),
                          tooltip: "Back",
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Details: $examName',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => Navigator.pop(context),
                          child: Icon(
                            Icons.close,
                            size: 20,
                            color: const Color(0xFF1E293B).withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    /// TAB
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Details',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF2563EB),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 50,
                          height: 2,
                          color: const Color(0xFF2563EB),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Show warning if using local data only
                    if (!hasApiData && hasLocalData)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          border: Border.all(
                            color: Colors.amber.withOpacity(0.3),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.amber.shade700,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                "Showing cached data. Some details may not be available.",
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),

                    /// DETAILS TABLE
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          if (studentName != 'N/A') ...[
                            _row('Student Name', studentName),
                            _divider(),
                          ],
                          if (hallticket != 'N/A') ...[
                            _row('Hall Ticket', hallticket),
                            _divider(),
                          ],
                          if (branch != 'N/A') ...[
                            _row('Branch', branch),
                            _divider(),
                          ],
                          if (group != 'N/A') ...[
                            _row('Group', group),
                            _divider(),
                          ],
                          _row('Exam Name', examName),
                          _divider(),
                          _row(
                            'Exam ID',
                            examId,
                            valueColor: const Color(0xFFEC4899),
                          ),
                          if (examDate != 'N/A') ...[
                            _divider(),
                            _row('Date', examDate),
                          ],
                          if (examTime != 'N/A') ...[
                            _divider(),
                            _row('Time', examTime),
                          ],
                          if (duration != 'N/A') ...[
                            _divider(),
                            _row('Duration', duration),
                          ],
                          if (totalQuestions != 'N/A') ...[
                            _divider(),
                            _row(
                              'Total Questions',
                              totalQuestions,
                            ),
                          ],
                          if (totalMarks != 'N/A') ...[
                            _divider(),
                            _row('Total Marks', totalMarks),
                          ],
                          if (platform != 'N/A') ...[
                            _divider(),
                            _row('Platform', platform),
                          ],
                          if (examType != 'N/A') ...[
                            _divider(),
                            _row('Exam Type', examType),
                          ],
                          if (isProctored) ...[
                            _divider(),
                            _row('Proctored', 'Yes', badge: true),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    /// INSTRUCTIONS
                    const Text(
                      'Instructions:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 12),

                    _bullet(
                      'Webcam must be enabled throughout the exam',
                    ),
                    _bullet('Stable internet connection required'),
                    _bullet('No external assistance allowed'),
                    _bullet(
                      'Time limits will be strictly enforced',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  /// TABLE ROW
  static Widget _row(
    String label,
    String value, {
    Color? valueColor,
    bool badge = false,
  }) {
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
          ),
          Container(width: 1, color: const Color(0xFFE2E8F0)),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: badge
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        value,
                        style: const TextStyle(
                          color: Color(0xFF16A34A),
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    )
                  : Text(
                      value,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: valueColor ?? const Color(0xFF1E293B),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _divider() {
    return const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0));
  }

  static Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  ', style: TextStyle(fontSize: 18)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
            ),
          ),
        ],
      ),
    );
  }
}
