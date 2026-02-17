import 'dart:async';
import 'package:flutter/material.dart';
import 'package:student_app/student_app/services/exams_service.dart';
import 'package:student_app/student_app/model/exam_item.dart';
import 'package:student_app/student_app/online_exam_portal_page.dart';
import 'package:student_app/theme_controllers.dart';

class ExamWritingPage extends StatefulWidget {
  final String examId;
  final String examName;
  final String subject;
  final String duration;
  final int questionsCount;
  final bool skipInstructions;

  const ExamWritingPage({
    super.key,
    required this.examId,
    required this.examName,
    this.subject = 'General',
    this.duration = 'N/A',
    this.questionsCount = 0,
    this.skipInstructions = false,
  });

  @override
  State<ExamWritingPage> createState() => _ExamWritingPageState();
}

class _ExamWritingPageState extends State<ExamWritingPage> {
  bool _hasConfirmed = false;
  bool _isAgreed = false;
  bool _isLoading = true;
  String? _errorMessage;

  List<dynamic> _questions = [];
  int _currentQuestionIndex = 0;

  Timer? _timer;
  int _secondsElapsed = 0;

  final Map<int, String> _answers = {};
  final TextEditingController _answerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.skipInstructions) {
      _startExam();
    }
  }

  void _startExam() {
    setState(() {
      _hasConfirmed = true;
      _isLoading = true;
    });
    _fetchQuestions();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _answerController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _secondsElapsed++);
      }
    });
  }

  String _formatTime(int seconds) {
    final d = Duration(seconds: seconds);
    String two(int n) => n.toString().padLeft(2, '0');
    return "${two(d.inHours)}:${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}";
  }

  Future<void> _fetchQuestions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await ExamsService.getExamQuestions(widget.examId);

      List<dynamic> flattenedQuestions = [];

      // Handle the new structure: subjects -> sections -> questions
      if (data['subjects'] != null && data['subjects'] is List) {
        final List<dynamic> subjects = data['subjects'];
        for (var subject in subjects) {
          final dynamic sectionsData = subject['sections'];
          Map<String, dynamic> sections = {};

          if (sectionsData is Map) {
            sections = Map<String, dynamic>.from(sectionsData);
          } else if (sectionsData is List) {
            // If for some reason it's a list instead of a map
            for (int i = 0; i < sectionsData.length; i++) {
              sections[i.toString()] = sectionsData[i];
            }
          }

          sections.forEach((key, sectionData) {
            final List<dynamic> qList = sectionData['questions'] ?? [];
            for (var q in qList) {
              final qMap = Map<String, dynamic>.from(q);
              qMap['subject_name'] = subject['subject_name'];
              qMap['section_name'] = sectionData['section_name'];
              qMap['section_id'] = sectionData['section_id'];
              flattenedQuestions.add(qMap);
            }
          });
        }
      } else {
        // Fallback to old structures
        if (data['data'] != null && data['data']['questions'] is List) {
          flattenedQuestions = data['data']['questions'];
        } else if (data['questions'] is List) {
          flattenedQuestions = data['questions'];
        } else if (data['exam'] != null && data['exam']['questions'] is List) {
          flattenedQuestions = data['exam']['questions'];
        }
      }

      if (mounted) {
        setState(() {
          _questions = flattenedQuestions;
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

  Future<void> _saveCurrentAnswer({bool isReview = false}) async {
    if (_questions.isEmpty) return;

    final answer = _answerController.text.trim();
    if (answer.isEmpty) return;

    final q = _questions[_currentQuestionIndex];

    _answers[_currentQuestionIndex] = answer;

    final payload = {
      "exam_id": widget.examId,
      "question_id": q['exam_question_id'] ?? q['id'] ?? q['question_id'],
      "section_id": q['section_id'] ?? 0,
      "answer": answer,
      "time_spent_total": _formatTime(_secondsElapsed),
      "is_review": isReview ? 1 : 0,
    };

    await ExamsService.saveAnswer(payload);
  }

  void _nextQuestion() async {
    await _saveCurrentAnswer();
    if (_currentQuestionIndex < _questions.length - 1) {
      if (mounted) {
        setState(() {
          _currentQuestionIndex++;
          _answerController.text = _answers[_currentQuestionIndex] ?? '';
        });
      }
    } else {
      _showFinishDialog();
    }
  }

  void _prevQuestion() async {
    await _saveCurrentAnswer();
    if (_currentQuestionIndex > 0) {
      if (mounted) {
        setState(() {
          _currentQuestionIndex--;
          _answerController.text = _answers[_currentQuestionIndex] ?? '';
        });
      }
    }
  }

  void _showFinishDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Finish Exam?'),
        content: const Text('Are you sure you want to submit your exam?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close confirmation dialog
              _submitExam();
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitExam() async {
    setState(() => _isLoading = true);
    try {
      final success = await ExamsService.submitExam(widget.examId);
      if (success) {
        final summary = await ExamsService.getExamSummary(widget.examId);
        if (mounted) {
          _showSummaryDialog(summary['data'] ?? summary['result'] ?? summary);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to submit exam. Please try again.'),
            ),
          );
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSummaryDialog(dynamic data) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final result = data is Map ? data : {};
        return AlertDialog(
          title: const Text('Exam Summary'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _summaryRow('Total Marks', '${result['total_marks'] ?? 0}'),
              _summaryRow('Correct', '${result['correct'] ?? 0}'),
              _summaryRow('Wrong', '${result['wrong'] ?? 0}'),
              _summaryRow('Skipped', '${result['skipped'] ?? 0}'),
              const Divider(),
              _summaryRow(
                'Score',
                '${result['score_percentage'] ?? result['score'] ?? 0}%',
                isBold: true,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close summary dialog
                Navigator.pop(context); // Return to list
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _summaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ThemeControllerWrapper(
      themeController: StudentThemeController.themeMode,
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final cardColor = theme.cardColor;
          final bgColor = theme.scaffoldBackgroundColor;

          if (!_hasConfirmed) {
            return _buildInstructionScreen(context);
          }

          return Scaffold(
            backgroundColor: bgColor,
            appBar: AppBar(
              title: Text(widget.examName),
              backgroundColor: bgColor,
              elevation: 0,
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(Icons.timer_outlined, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        _formatTime(_secondsElapsed),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            body: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Error: $_errorMessage"),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchQuestions,
                          child: const Text("Retry"),
                        ),
                      ],
                    ),
                  )
                : _questions.isEmpty
                ? const Center(child: Text("No questions found"))
                : Column(
                    children: [
                      // Question Palette
                      SizedBox(
                        height: 60,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _questions.length,
                          itemBuilder: (_, i) {
                            final isCurrent = i == _currentQuestionIndex;
                            final isAnswered = _answers.containsKey(i);

                            return GestureDetector(
                              onTap: () async {
                                await _saveCurrentAnswer();
                                if (mounted) {
                                  setState(() {
                                    _currentQuestionIndex = i;
                                    _answerController.text = _answers[i] ?? '';
                                  });
                                }
                              },
                              child: Container(
                                width: 40,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isCurrent
                                      ? Colors.blue
                                      : isAnswered
                                      ? Colors.green
                                      : cardColor,
                                  border: Border.all(
                                    color: isCurrent
                                        ? Colors.blue
                                        : Colors.grey.withOpacity(0.3),
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "${i + 1}",
                                  style: TextStyle(
                                    color: isCurrent || isAnswered
                                        ? Colors.white
                                        : theme.textTheme.bodyMedium?.color,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Current Question
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, -2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Question ${_currentQuestionIndex + 1} of ${_questions.length}",
                                        style: TextStyle(
                                          color:
                                              theme.textTheme.bodySmall?.color,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      if (_questions[_currentQuestionIndex]['subject_name'] !=
                                          null)
                                        Text(
                                          "${_questions[_currentQuestionIndex]['subject_name']} • ${_questions[_currentQuestionIndex]['section_name'] ?? ''}",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.blue.shade600,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                    ],
                                  ),
                                  if (_questions[_currentQuestionIndex]['is_review'] ==
                                      1)
                                    _buildTag("Review", Colors.orange),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _stripHtml(
                                  _questions[_currentQuestionIndex]['question'],
                                ),
                                style: const TextStyle(
                                  fontSize: 18,
                                  height: 1.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 24),
                              if (_questions[_currentQuestionIndex]['question_type'] ==
                                  'objective')
                                Expanded(
                                  child: ListView(
                                    children: [
                                      _buildOption(
                                        1,
                                        _questions[_currentQuestionIndex]['option1'],
                                        theme,
                                        theme.brightness == Brightness.dark,
                                      ),
                                      _buildOption(
                                        2,
                                        _questions[_currentQuestionIndex]['option2'],
                                        theme,
                                        theme.brightness == Brightness.dark,
                                      ),
                                      _buildOption(
                                        3,
                                        _questions[_currentQuestionIndex]['option3'],
                                        theme,
                                        theme.brightness == Brightness.dark,
                                      ),
                                      _buildOption(
                                        4,
                                        _questions[_currentQuestionIndex]['option4'],
                                        theme,
                                        theme.brightness == Brightness.dark,
                                      ),
                                      if (_questions[_currentQuestionIndex]['option5'] !=
                                              null &&
                                          _questions[_currentQuestionIndex]['option5']
                                              .toString()
                                              .isNotEmpty)
                                        _buildOption(
                                          5,
                                          _questions[_currentQuestionIndex]['option5'],
                                          theme,
                                          theme.brightness == Brightness.dark,
                                        ),
                                      if (_questions[_currentQuestionIndex]['option6'] !=
                                              null &&
                                          _questions[_currentQuestionIndex]['option6']
                                              .toString()
                                              .isNotEmpty)
                                        _buildOption(
                                          6,
                                          _questions[_currentQuestionIndex]['option6'],
                                          theme,
                                          theme.brightness == Brightness.dark,
                                        ),
                                    ],
                                  ),
                                )
                              else
                                Expanded(
                                  child: TextField(
                                    controller: _answerController,
                                    maxLines: 10,
                                    decoration: InputDecoration(
                                      hintText: "Type your answer here...",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: theme.dividerColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      // Bottom Actions
                      Container(
                        padding: const EdgeInsets.all(20),
                        color: cardColor,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton.icon(
                              onPressed: _currentQuestionIndex > 0
                                  ? _prevQuestion
                                  : null,
                              icon: const Icon(Icons.arrow_back),
                              label: const Text("Previous"),
                            ),
                            ElevatedButton(
                              onPressed: () =>
                                  _saveCurrentAnswer(isReview: true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text("Mark for Review"),
                            ),
                            ElevatedButton.icon(
                              onPressed: _nextQuestion,
                              icon: Icon(
                                _currentQuestionIndex == _questions.length - 1
                                    ? Icons.check
                                    : Icons.arrow_forward,
                              ),
                              label: Text(
                                _currentQuestionIndex == _questions.length - 1
                                    ? "Finish"
                                    : "Next",
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }

  String _stripHtml(String? html) {
    if (html == null) return '';
    return html.replaceAll(RegExp(r'<[^>]*>'), '').trim();
  }

  Widget _buildOption(
    int index,
    dynamic content,
    ThemeData theme,
    bool isDark,
  ) {
    if (content == null || content.toString().trim().isEmpty)
      return const SizedBox.shrink();

    final isSelected = _answerController.text == index.toString();
    final strippedContent = _stripHtml(content.toString());

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          setState(() {
            _answerController.text = index.toString();
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue.withOpacity(0.1) : theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.blue : theme.dividerColor,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? Colors.blue : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  String.fromCharCode(64 + index), // A, B, C, D...
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  strippedContent,
                  style: TextStyle(
                    fontSize: 16,
                    color: isSelected
                        ? (isDark ? Colors.white : Colors.blue.shade900)
                        : theme.textTheme.bodyLarge?.color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionScreen(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black87 : Colors.grey.shade200,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            decoration: BoxDecoration(
              color: isDark ? theme.cardColor : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Start Online Exam: ${widget.examName}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Are you ready to start the online exam?",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 24),

                  // Important Requirements Box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.withOpacity(0.2)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Important Requirements",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Ensure you have stable internet connection and webcam enabled.",
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Exam Details
                  const Text(
                    "Exam Details:",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _detailRow("Name:", widget.examName),
                  _detailRow("Subject:", widget.subject),
                  _detailRow("Duration:", widget.duration),
                  _detailRow("Questions:", "${widget.questionsCount}"),
                  _detailRow("Exam ID:", widget.examId),
                  const SizedBox(height: 24),

                  // Checkbox
                  Row(
                    children: [
                      Checkbox(
                        value: _isAgreed,
                        onChanged: (val) {
                          setState(() => _isAgreed = val ?? false);
                        },
                      ),
                      const Expanded(
                        child: Text(
                          "I have read and understood the instructions",
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Full Screen Mode Alert (Blue box)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withOpacity(0.2)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Colors.blue,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Full Screen Mode",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "The exam will open in a new full-screen window. Do not close or switch tabs during the exam.",
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          minimumSize: const Size(100, 45),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(color: Colors.black87),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _isAgreed
                            ? () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => OnlineExamPortalPage(
                                      exam: ExamModel(
                                        id: widget.examId,
                                        title: widget.examName,
                                        subject: widget.subject,
                                        duration: widget.duration,
                                        questions: widget.questionsCount,
                                        date: "", // Placeholder
                                        time: "",
                                        board: "",
                                        progress: 0,
                                        type: "Online",
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(100, 45),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text("OK"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
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

  Widget _detailRow(String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
