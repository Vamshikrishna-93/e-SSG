import 'dart:async';
import 'package:flutter/material.dart';

import 'package:student_app/student_app/model/exam_item.dart';
import 'package:student_app/student_app/widgets/exam_app_bar.dart';
import 'package:student_app/student_app/widgets/exam_footer.dart';
import 'package:student_app/student_app/widgets/exam_options_list.dart';
import 'package:student_app/student_app/widgets/exam_palette_popup.dart';
import 'package:student_app/student_app/widgets/exam_question_card.dart';
import 'package:student_app/student_app/widgets/exam_timer_header.dart';

class ExamPortalWritingPage extends StatefulWidget {
  final ExamModel exam;

  const ExamPortalWritingPage({super.key, required this.exam});

  @override
  State<ExamPortalWritingPage> createState() => _ExamPortalWritingPageState();
}

class _ExamPortalWritingPageState extends State<ExamPortalWritingPage>
    with WidgetsBindingObserver {
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _questions = [];
  int _currentIndex = 0;

  Timer? _examTimer;
  int _secondsRemaining = 10800; // Default 3 hours
  int _totalSecondsElapsed = 0;

  int _warnings = 0;
  final int _maxWarnings = 2;

  final Map<int, String> _answers = {};
  final Set<int> _markedForReview = {};
  final Set<int> _visited = {0};

  Map<String, dynamic>? _studentData;
  Map<String, dynamic>? _examData;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchData();
    _startTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _examTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _handleWarning();
    }
  }

  void _handleWarning() {
    if (_warnings < _maxWarnings) {
      setState(() {
        _warnings++;
      });

      if (_warnings == 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "WARNING: Do not leave the exam! Next time the exam will be ended.",
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      } else if (_warnings >= _maxWarnings) {
        _endExamDueToWarning();
      }
    }
  }

  void _endExamDueToWarning() {
    _examTimer?.cancel();
    _submitExam(autoSubmit: true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text("Exam Terminated"),
          ],
        ),
        content: const Text(
          "You switched apps too many times. Your exam has been ended for security reasons.",
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close this dialog
              // The success dialog from _submitExam should follow or we are already moving back.
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("OK", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      // STATIC MOCK DATA
      final Map<String, dynamic> mockQuestionsData = {
        "student": {
          "student_name": "Vamshi Krishna",
          "hallticket": "2026SSJC093",
          "sfname": "Vamshi",
          "slname": "Krishna",
          "admno": "SSJC093",
        },
        "exam": {
          "exam_name": "SSJC Weekend Test - General Proficiency",
          "duration": "3 hours",
          "total_questions": 50,
        },
        "subjects": [
          {
            "subject_name": "Mathematics",
            "sections": [
              {
                "section_name": "Algebra",
                "section_id": 101,
                "questions": List.generate(
                  15,
                  (i) => {
                    "id": 1000 + i,
                    "exam_question_id": 1000 + i,
                    "question":
                        "What is the value of x in the equation 2x + ${5 + i} = ${25 + i}?",
                    "option1": "5",
                    "option2": "10",
                    "option3": "15",
                    "option4": "20",
                  },
                ),
              },
              {
                "section_name": "Geometry",
                "section_id": 102,
                "questions": List.generate(
                  10,
                  (i) => {
                    "id": 1100 + i,
                    "exam_question_id": 1100 + i,
                    "question":
                        "If the radius of a circle is ${7 + i} cm, what is its approximate area?",
                    "option1": "${((7 + i) * (7 + i) * 3.14).toInt()} sq cm",
                    "option2":
                        "${((7 + i) * (7 + i) * 3.14 + 10).toInt()} sq cm",
                    "option3":
                        "${((7 + i) * (7 + i) * 3.14 - 5).toInt()} sq cm",
                    "option4": "None of these",
                  },
                ),
              },
            ],
          },
          {
            "subject_name": "Physics",
            "sections": [
              {
                "section_name": "Mechanics",
                "section_id": 201,
                "questions": List.generate(
                  15,
                  (i) => {
                    "id": 2000 + i,
                    "exam_question_id": 2000 + i,
                    "question":
                        "A car accelerates from rest at ${2 + i} m/s². What is its velocity after ${5 + i} seconds?",
                    "option1": "${(2 + i) * (5 + i)} m/s",
                    "option2": "${(2 + i) * (5 + i) + 2} m/s",
                    "option3": "${(2 + i) * (5 + i) - 3} m/s",
                    "option4": "Insufficient data",
                  },
                ),
              },
            ],
          },
          {
            "subject_name": "Chemistry",
            "sections": [
              {
                "section_name": "Organic",
                "section_id": 301,
                "questions": List.generate(
                  10,
                  (i) => {
                    "id": 3000 + i,
                    "exam_question_id": 3000 + i,
                    "question":
                        "Identify the functional group present in Sample $i which reacts with Sodium bicarbonate.",
                    "option1": "Carboxylic Acid",
                    "option2": "Alcohol",
                    "option3": "Aldehyde",
                    "option4": "Ketone",
                  },
                ),
              },
            ],
          },
        ],
      };

      List<dynamic> flattened = [];
      final studentMeta = mockQuestionsData['student'];
      final examMeta = mockQuestionsData['exam'];

      if (mockQuestionsData['subjects'] != null &&
          mockQuestionsData['subjects'] is List) {
        for (var subject in mockQuestionsData['subjects']) {
          String subjectName = subject['subject_name']?.toString() ?? "General";
          dynamic sectionsData = subject['sections'];

          List<dynamic> sectionsList = [];
          if (sectionsData is Map) {
            sectionsList = sectionsData.values.toList();
          } else if (sectionsData is List) {
            sectionsList = sectionsData;
          }

          for (var section in sectionsList) {
            if (section == null) continue;
            String sectionName =
                section['section_name']?.toString() ?? "Section";
            dynamic sectionId = section['section_id'] ?? 0;
            dynamic qList = section['questions'];

            if (qList != null && qList is List) {
              for (var q in qList) {
                if (q is Map) {
                  final qMap = Map<String, dynamic>.from(q);
                  qMap['subject_name'] = subjectName;
                  qMap['section_name'] = sectionName;
                  qMap['section_id'] = sectionId;
                  flattened.add(qMap);
                }
              }
            }
          }
        }
      }

      if (mounted) {
        setState(() {
          _studentData = studentMeta;
          _examData = examMeta;
          _questions = flattened;
          _isLoading = false;
          _secondsRemaining = 10800; // 3 hours
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

  void _startTimer() {
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
        _submitExam(autoSubmit: true);
      }
    });
  }

  String _formatTime(int seconds) {
    if (seconds < 0) seconds = 0;
    final h = (seconds ~/ 3600).toString().padLeft(2, '0');
    final m = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return "$h:$m:$s";
  }

  Future<void> _saveAnswerToApi({bool isReview = false}) async {
    if (_questions.isEmpty || _currentIndex >= _questions.length) return;

    // Static simulation: just log the local state
    debugPrint(
      "Local Save: Question ${_currentIndex + 1}, Answer: ${_answers[_currentIndex]}, Review: $isReview, Total Time: ${_formatTime(_totalSecondsElapsed)}",
    );
  }

  void _submitExam({bool autoSubmit = false}) async {
    if (!autoSubmit) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Submit Exam?"),
          content: const Text(
            "Are you sure you want to submit your exam? This action cannot be undone.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text(
                "Submit",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
      if (confirm != true) return;
    }

    setState(() => _isLoading = true);
    // Simulate network delay for submission
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      _showFinalSuccessDialog();
    }
  }

  void _showFinalSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Icon(Icons.check_circle, color: Colors.green, size: 64),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Success!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              "Your exam has been submitted successfully.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back
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
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  "Error loading exam: $_errorMessage",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Go Back"),
                ),
              ],
            ),
          ),
        ),
      );
    }

    const backgroundColor = Color(0xFFF8FAFC);

    final studentName =
        _studentData?['student_name'] ??
        (_studentData != null
            ? "${_studentData!['sfname'] ?? ''} ${_studentData!['slname'] ?? ''}"
                  .trim()
            : "Student");
    final htNo =
        _studentData?['hallticket'] ??
        _studentData?['admno']?.toString() ??
        "N/A";
    final examName = _examData?['exam_name'] ?? widget.exam.title;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: ExamAppBar(
        examName: examName,
        studentName: studentName,
        hallTicket: htNo,
        group: _examData?['group_name'] ?? "JR MPC",
        warnings: _warnings,
        maxWarnings: _maxWarnings,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double screenWidth = constraints.maxWidth;
            final double screenHeight = constraints.maxHeight;
            final bool isSmallScreen = screenHeight < 600;
            final List<String> options = [];
            final List<String> optionIds = [];
            if (_questions.isNotEmpty) {
              final currentQuestion = _questions[_currentIndex];
              for (int i = 1; i <= 6; i++) {
                final opt = currentQuestion['option$i'];
                if (opt != null && opt.toString().isNotEmpty) {
                  options.add(opt.toString());
                  optionIds.add('option$i');
                }
              }
            }

            return Column(
              children: [
                ExamTimerHeader(
                  formattedTime: _formatTime(_secondsRemaining),
                  isCritical: _secondsRemaining < 300,
                  currentIndex: _currentIndex,
                  totalQuestions: _questions.length,
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth > 600 ? 32 : 16,
                    ),
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        SizedBox(height: isSmallScreen ? 8 : 16),
                        if (_questions.isNotEmpty)
                          ExamQuestionCard(
                            currentIndex: _currentIndex,
                            question: _questions[_currentIndex],
                            strippedQuestion: _stripHtml(
                              _questions[_currentIndex]['question'] ?? "",
                            ),
                          ),
                        SizedBox(height: isSmallScreen ? 12 : 24),
                        if (_questions.isNotEmpty)
                          ExamOptionsList(
                            options: options,
                            optionIds: optionIds,
                            selectedOptionId: _answers[_currentIndex],
                            onOptionSelected: (optionId) {
                              setState(() {
                                _answers[_currentIndex] = optionId;
                                _visited.add(_currentIndex);
                              });
                            },
                            stripHtml: _stripHtml,
                          ),
                        SizedBox(height: isSmallScreen ? 16 : 32),
                      ],
                    ),
                  ),
                ),
                ExamFooter(
                  currentIndex: _currentIndex,
                  isMarked: _markedForReview.contains(_currentIndex),
                  onToggleMark: () {
                    setState(() {
                      if (_markedForReview.contains(_currentIndex)) {
                        _markedForReview.remove(_currentIndex);
                      } else {
                        _markedForReview.add(_currentIndex);
                      }
                    });
                    _saveAnswerToApi(
                      isReview: _markedForReview.contains(_currentIndex),
                    );
                  },
                  onClearResponse: () {
                    setState(() {
                      _answers.remove(_currentIndex);
                    });
                    _saveAnswerToApi();
                  },
                  onPrevious: _currentIndex > 0
                      ? () => _changeQuestion(_currentIndex - 1)
                      : null,
                  onSaveAndNext: _saveAndMoveToNext,
                  onShowPalette: _showQuestionPalette,
                  onSubmit: _submitExam,
                  isLastQuestion:
                      _currentIndex == _questions.length - 1 ||
                      (_questions.isNotEmpty &&
                          _answers.length == _questions.length) ||
                      _secondsRemaining < 60,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _saveAndMoveToNext() async {
    await _saveAnswerToApi();
    if (_currentIndex < _questions.length - 1) {
      _changeQuestion(_currentIndex + 1);
    }
  }

  void _changeQuestion(int index) {
    if (index >= 0 && index < _questions.length) {
      setState(() {
        _currentIndex = index;
        _visited.add(index);
      });
    }
  }

  void _showQuestionPalette() {
    final studentName =
        _studentData?['student_name'] ??
        (_studentData != null
            ? "${_studentData!['sfname'] ?? ''} ${_studentData!['slname'] ?? ''}"
                  .trim()
            : "Student");
    final htNo =
        _studentData?['hallticket'] ??
        _studentData?['admno']?.toString() ??
        "N/A";

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: ExamPalettePopup(
          studentName: studentName,
          hallTicket: htNo,
          group: _examData?['group_name'] ?? "JR MPC",
          formattedTime: _formatTime(_secondsRemaining),
          questions: _questions,
          answers: _answers,
          markedForReview: _markedForReview,
          visited: _visited,
          currentIndex: _currentIndex,
          onQuestionSelected: (index) {
            _changeQuestion(index);
            Navigator.pop(context);
          },
          onSubmit: () {
            Navigator.pop(context);
            _submitExam();
          },
        ),
      ),
    );
  }

  String _stripHtml(String html) {
    return html.replaceAll(RegExp(r'<[^>]*>'), '').trim();
  }
}
