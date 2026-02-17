import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:student_app/student_app/model/exam_item.dart';
import 'package:student_app/student_app/services/exams_service.dart';
import 'package:student_app/student_app/services/student_profile_service.dart';

class ExamPortalWritingPage extends StatefulWidget {
  final ExamModel exam;

  const ExamPortalWritingPage({super.key, required this.exam});

  @override
  State<ExamPortalWritingPage> createState() => _ExamPortalWritingPageState();
}

class _ExamPortalWritingPageState extends State<ExamPortalWritingPage> {
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _questions = [];
  int _currentIndex = 0;

  Timer? _examTimer;
  int _secondsRemaining = 10800; // Default 3 hours
  int _totalSecondsElapsed = 0;
  int _questionSecondsElapsed = 0;
  Timer? _questionTimer;

  final Map<int, String> _answers = {};
  final Set<int> _markedForReview = {};
  final Set<int> _visited = {};

  Map<String, dynamic>? _studentData;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _startTimers();
  }

  Future<void> _fetchData() async {
    try {
      final profile = await StudentProfileService.getProfile();
      final questionsData = await ExamsService.getExamQuestions(widget.exam.id);

      List<dynamic> flattened = [];
      if (questionsData['subjects'] != null &&
          questionsData['subjects'] is List) {
        for (var subject in questionsData['subjects']) {
          final sectionsData = subject['sections'];
          Map<String, dynamic> sections = {};

          if (sectionsData is Map) {
            sections = Map<String, dynamic>.from(sectionsData);
          } else if (sectionsData is List) {
            for (int i = 0; i < sectionsData.length; i++) {
              sections[i.toString()] = sectionsData[i];
            }
          }

          sections.forEach((k, v) {
            final qList = v['questions'] ?? [];
            for (var q in qList) {
              final qMap = Map<String, dynamic>.from(q);
              qMap['subject_name'] = subject['subject_name'];
              qMap['section_name'] = v['section_name'];
              qMap['section_id'] = v['section_id'] ?? 0;
              flattened.add(qMap);
            }
          });
        }
      } else {
        flattened =
            questionsData['data']?['questions'] ??
            questionsData['questions'] ??
            [];
      }

      if (mounted) {
        setState(() {
          _studentData = profile['data'];
          _questions = flattened;
          _isLoading = false;
          _visited.add(0);

          if (widget.exam.duration != null) {
            final durString = widget.exam.duration!.toLowerCase();
            final parts = durString.split(' ');
            if (parts.isNotEmpty) {
              final val = int.tryParse(parts[0]);
              if (val != null) {
                if (durString.contains("hour")) {
                  _secondsRemaining = val * 3600;
                } else if (durString.contains("min")) {
                  _secondsRemaining = val * 60;
                }
              }
            }
          }
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

  void _startTimers() {
    _examTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        if (mounted) {
          setState(() {
            _secondsRemaining--;
            _totalSecondsElapsed++;
          });
        }
      } else {
        _examTimer?.cancel();
        _submitExam();
      }
    });

    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() => _questionSecondsElapsed++);
    });
  }

  String _formatTime(int seconds) {
    final h = (seconds ~/ 3600).toString().padLeft(2, '0');
    final m = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return "$h:$m:$s";
  }

  @override
  void dispose() {
    _examTimer?.cancel();
    _questionTimer?.cancel();
    super.dispose();
  }

  Future<void> _saveAnswerToApi({bool isReview = false}) async {
    if (_questions.isEmpty || _currentIndex >= _questions.length) return;

    final q = _questions[_currentIndex];
    final answer = _answers[_currentIndex] ?? "";

    final payload = {
      "exam_id": widget.exam.id,
      "question_id": q['exam_question_id'] ?? q['id'] ?? q['question_id'],
      "section_id": q['section_id'] ?? 0,
      "answer": answer,
      "time_spent_total": _formatTime(_totalSecondsElapsed),
      "is_review": isReview ? 1 : 0,
    };

    try {
      await ExamsService.saveAnswer(payload);
    } catch (e) {
      debugPrint("Error saving answer: $e");
    }
  }

  void _submitExam() async {
    setState(() => _isLoading = true);
    try {
      final success = await ExamsService.submitExam(widget.exam.id);
      if (mounted) {
        if (success) {
          _showFinalSuccessDialog();
        } else {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Failed to submit exam. Please try again."),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showFinalSuccessDialog() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Icon(Icons.check_circle, color: Colors.green, size: 64),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Success!",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Your exam has been submitted successfully.",
              textAlign: TextAlign.center,
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to dashboard
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Go to Dashboard",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_errorMessage != null)
      return Scaffold(body: Center(child: Text("Error: $_errorMessage")));

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Update status bar based on theme
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    final studentName = _studentData != null
        ? "${_studentData!['sfname'] ?? ''} ${_studentData!['slname'] ?? ''}"
              .trim()
        : "Student";
    final htNo = _studentData != null
        ? (_studentData!['admno']?.toString() ?? "N/A")
        : "N/A";
    final group = _studentData != null
        ? (_studentData!['course_name'] ?? "JR MPC")
        : "JR MPC";

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F172A)
          : const Color(0xFFF8FAFC),
      appBar: _buildCompactAppBar(studentName, htNo, group, isDark),
      endDrawer: _buildQuestionPaletteDrawer(isDark),
      body: SafeArea(
        child: Column(
          children: [
            _buildTimerHeader(isDark),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    const SizedBox(height: 16),
                    _buildQuestionSection(isDark),
                    const SizedBox(height: 24),
                    _buildOptionsSection(isDark),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            _buildStickyFooter(isDark),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildCompactAppBar(
    String name,
    String ht,
    String group,
    bool isDark,
  ) {
    return AppBar(
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                : [const Color(0xFF0061FF), const Color(0xFF60EFFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      elevation: isDark ? 0 : 4,
      automaticallyImplyLeading: false,
      centerTitle: false,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.white,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: isDark
                  ? const Color(0xFF334155)
                  : const Color(0xFF0061FF),
              child: Text(
                name.isNotEmpty ? name[0] : "S",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.exam.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  name,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.grid_view_rounded, color: Colors.white),
          onPressed: () => Scaffold.of(context).openEndDrawer(),
        ),
      ],
    );
  }

  Widget _buildTimerHeader(bool isDark) {
    final isCritical = _secondsRemaining < 300;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.timer_outlined,
                size: 18,
                color: isCritical ? Colors.red : Colors.blue,
              ),
              const SizedBox(width: 6),
              Text(
                _formatTime(_secondsRemaining),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isCritical
                      ? Colors.red
                      : (isDark ? Colors.white : Colors.black87),
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.blue.withOpacity(0.2)
                  : Colors.blue.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "Q: ${_currentIndex + 1}/${_questions.length}",
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionSection(bool isDark) {
    if (_questions.isEmpty) return const SizedBox.shrink();
    final q = _questions[_currentIndex];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildBadge("MA", const Color(0xFF0061FF), isDark),
            const SizedBox(width: 6),
            _buildBadge(
              q['section_name'] ?? "Section A",
              const Color(0xFF10B981),
              isDark,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Question ${_currentIndex + 1}",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                  Wrap(
                    spacing: 4,
                    children: [
                      _buildMiniTag("+4.0", Colors.green, isDark),
                      _buildMiniTag("-1.0", Colors.red, isDark),
                    ],
                  ),
                ],
              ),
              Divider(
                height: 24,
                color: isDark ? Colors.white10 : Colors.grey.shade200,
              ),
              Text(
                _stripHtml(q['question'] ?? ""),
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: isDark ? Colors.white70 : const Color(0xFF334155),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOptionsSection(bool isDark) {
    if (_questions.isEmpty) return const SizedBox.shrink();
    final q = _questions[_currentIndex];
    final options = [];
    if (q['option1']?.toString().isNotEmpty == true) options.add(q['option1']);
    if (q['option2']?.toString().isNotEmpty == true) options.add(q['option2']);
    if (q['option3']?.toString().isNotEmpty == true) options.add(q['option3']);
    if (q['option4']?.toString().isNotEmpty == true) options.add(q['option4']);
    if (q['option5']?.toString().isNotEmpty == true) options.add(q['option5']);
    if (q['option6']?.toString().isNotEmpty == true) options.add(q['option6']);

    return Column(
      children: List.generate(options.length, (index) {
        final char = String.fromCharCode(65 + index);
        final isSelected = _answers[_currentIndex] == (index + 1).toString();

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              setState(() {
                _answers[_currentIndex] = (index + 1).toString();
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.blue.withOpacity(isDark ? 0.2 : 0.05)
                    : (isDark ? const Color(0xFF1E293B) : Colors.white),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF0061FF)
                      : (isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0)),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.blue.withOpacity(isDark ? 0.3 : 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF0061FF)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF0061FF)
                            : (isDark
                                  ? Colors.white24
                                  : const Color(0xFFCBD5E1)),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        char,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                    ? Colors.white70
                                    : const Color(0xFF64748B)),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      _stripHtml(options[index].toString()),
                      style: TextStyle(
                        fontSize: 15,
                        color: isSelected
                            ? (isDark ? Colors.white : const Color(0xFF1E293B))
                            : (isDark
                                  ? Colors.white70
                                  : const Color(0xFF475569)),
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStickyFooter(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            offset: const Offset(0, -2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSecondaryButton(
                  onPressed: () => _toggleMarkForReview(),
                  label: _markedForReview.contains(_currentIndex)
                      ? "Unmark"
                      : "Mark Review",
                  icon: Icons.bookmark_border,
                  color: Colors.orange,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSecondaryButton(
                  onPressed: () =>
                      setState(() => _answers.remove(_currentIndex)),
                  label: "Clear",
                  icon: Icons.clear_all,
                  color: Colors.red,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Material(
                color: isDark ? const Color(0xFF334155) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                child: IconButton(
                  onPressed: _currentIndex > 0
                      ? () => _changeQuestion(_currentIndex - 1)
                      : null,
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    size: 18,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _saveAndMove(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0061FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _currentIndex < _questions.length - 1
                        ? "Save & Next"
                        : "Submit Exam",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
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

  Widget _buildSecondaryButton({
    required VoidCallback onPressed,
    required String label,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16, color: color),
      label: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color.withOpacity(isDark ? 0.6 : 0.5)),
        backgroundColor: isDark ? color.withOpacity(0.05) : Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _toggleMarkForReview() async {
    setState(() {
      if (_markedForReview.contains(_currentIndex)) {
        _markedForReview.remove(_currentIndex);
      } else {
        _markedForReview.add(_currentIndex);
      }
    });
    await _saveAnswerToApi(isReview: _markedForReview.contains(_currentIndex));
  }

  void _saveAndMove() async {
    await _saveAnswerToApi();
    if (_currentIndex < _questions.length - 1) {
      _changeQuestion(_currentIndex + 1);
    } else {
      _showSubmitConfirmation();
    }
  }

  void _changeQuestion(int newIndex) {
    setState(() {
      _currentIndex = newIndex;
      _questionSecondsElapsed = 0;
      _visited.add(newIndex);
    });
  }

  Widget _buildBadge(String label, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(isDark ? 0.4 : 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildMiniTag(String label, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildQuestionPaletteDrawer(bool isDark) {
    return Drawer(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          bottomLeft: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                    : [const Color(0xFF0061FF), const Color(0xFF60EFFF)],
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.grid_view_rounded,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(width: 12),
                const Text(
                  "Question Palette",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLegend(isDark),
                  const SizedBox(height: 24),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    itemCount: _questions.length,
                    itemBuilder: (context, index) {
                      Color color = isDark
                          ? const Color(0xFF1E293B)
                          : Colors.grey.shade100;
                      Color textCol = isDark
                          ? Colors.white54
                          : Colors.grey.shade600;
                      if (_answers.containsKey(index)) {
                        color = Colors.green;
                        textCol = Colors.white;
                      } else if (_markedForReview.contains(index)) {
                        color = Colors.orange;
                        textCol = Colors.white;
                      } else if (_visited.contains(index)) {
                        color = Colors.red.shade400;
                        textCol = Colors.white;
                      }

                      bool isCurrent = index == _currentIndex;

                      return InkWell(
                        onTap: () {
                          _changeQuestion(index);
                          Navigator.pop(context);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(8),
                            border: isCurrent
                                ? Border.all(
                                    color: const Color(0xFF0061FF),
                                    width: 2,
                                  )
                                : (isDark
                                      ? Border.all(color: Colors.white10)
                                      : null),
                            boxShadow: isCurrent
                                ? [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.2),
                                      blurRadius: 4,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              "${index + 1}",
                              style: TextStyle(
                                color: textCol,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showSubmitConfirmation();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0061FF),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Submit Exam",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(bool isDark) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _buildLegendItem(Colors.green, "Answered", isDark),
        _buildLegendItem(Colors.red.shade400, "Visited", isDark),
        _buildLegendItem(Colors.orange, "Marked", isDark),
        _buildLegendItem(
          isDark ? const Color(0xFF1E293B) : Colors.grey.shade100,
          "Unvisited",
          isDark,
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: label == "Unvisited" && isDark
                ? Border.all(color: Colors.white10)
                : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.white60 : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  void _showSubmitConfirmation() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Submit Exam",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Are you sure you want to finish the exam? This action cannot be undone.",
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.blue.withOpacity(0.1)
                    : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem(
                    "Answered",
                    "${_answers.length}",
                    Colors.green,
                    isDark,
                  ),
                  _buildSummaryItem(
                    "Total",
                    "${_questions.length}",
                    Colors.blue,
                    isDark,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(color: isDark ? Colors.white60 : Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _submitExam();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text(
              "Submit Now",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    String label,
    String value,
    Color color,
    bool isDark,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isDark ? Colors.white54 : Colors.blueGrey,
          ),
        ),
      ],
    );
  }

  String _stripHtml(String html) {
    return html.replaceAll(RegExp(r'<[^>]*>'), '').trim();
  }
}
