import 'dart:math';
import 'package:flutter/material.dart';

class AnswerKeyDialog extends StatefulWidget {
  final Map<String, dynamic> exam;

  const AnswerKeyDialog({super.key, required this.exam});

  @override
  State<AnswerKeyDialog> createState() => _AnswerKeyDialogState();
}

class _AnswerKeyDialogState extends State<AnswerKeyDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _objectiveQuestions = [
    {
      'qNo': 1,
      'type': 'MCQ',
      'yourAnswer': 'A',
      'correctAnswer': 'A',
      'isCorrect': true,
      'marks': '+5.00',
    },
  ];

  final List<Map<String, dynamic>> _fillBlankQuestions = [
    {
      'qNo': 1,
      'type': 'Fill Blank',
      'yourAnswer': '1',
      'correctAnswer': '1',
      'isCorrect': true,
      'marks': '+5.00',
    },
    {
      'qNo': 2,
      'type': 'Fill Blank',
      'yourAnswer': 'a',
      'correctAnswer': 'A',
      'isCorrect': true,
      'marks': '+5.00',
    },
  ];

  final List<Map<String, dynamic>> _trueFalseQuestions = [
    {
      'qNo': 1,
      'type': 'True/False',
      'yourAnswer': 'B',
      'correctAnswer': 'B',
      'isCorrect': true,
      'marks': '+5.00',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF007BFF);
    const surfaceColor = Colors.white;
    const onSurfaceColor = Color(0xFF1E293B);
    const secondaryTextColor = Color(0xFF64748B);
    const borderColor = Color(0xFFE2E8F0);
    const headerBgColor = Color(0xFFF1F5F9);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 40,
        vertical: isMobile ? 24 : 48,
      ),
      child: Material(
        elevation: 22,
        borderRadius: BorderRadius.circular(20),
        color: surfaceColor,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isMobile ? double.infinity : 1100,
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.vpn_key_outlined,
                        color: primaryColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Answer Key',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: onSurfaceColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Detailed analysis of questions',
                            style: TextStyle(
                              fontSize: 14,
                              color: secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          Icons.close,
                          color: secondaryTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              /// TABS
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: borderColor),
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: primaryColor,
                  unselectedLabelColor: secondaryTextColor,
                  indicatorColor: primaryColor,
                  tabs: const [
                    Tab(text: "Objectives (1)"),
                    Tab(text: "Fill Blanks (2)"),
                    Tab(text: "True/False (1)"),
                    Tab(text: "Theory (0)"),
                  ],
                ),
              ),

              /// CONTENT
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildQuestionTable(_objectiveQuestions, headerBgColor),
                      _buildQuestionTable(_fillBlankQuestions, headerBgColor),
                      _buildQuestionTable(_trueFalseQuestions, headerBgColor),
                      _buildEmptyState(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionTable(
    List<Map<String, dynamic>> questions,
    Color headerBgColor,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const double minWidth = 800;
        final double actualWidth = max(constraints.maxWidth, minWidth);

        return SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: actualWidth,
                child: Column(
                  children: [
                    _buildTableHeader(headerBgColor),
                    ...questions.map((q) => _buildTableRow(q)).toList(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// HEADER (NO DIVIDER BELOW)
  Widget _buildTableHeader(Color headerBgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: headerBgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
      ),
      child: const Row(
        children: [
          SizedBox(width: 80, child: Text("Q.No", style: TextStyle(fontWeight: FontWeight.bold))),
          SizedBox(width: 150, child: Text("Type", style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text("Your Answer", style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text("Correct Answer", style: TextStyle(fontWeight: FontWeight.bold))),
          SizedBox(width: 120, child: Text("Result", style: TextStyle(fontWeight: FontWeight.bold))),
          SizedBox(
            width: 100,
            child: Text("Marks", textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(Map<String, dynamic> question) {
    final isCorrect = question['isCorrect'] as bool;
    final rowColor = isCorrect
        ? const Color(0xFF22C55E).withOpacity(0.05)
        : const Color(0xFFEF4444).withOpacity(0.05);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: rowColor,
        border: const Border(
          bottom: BorderSide(color: Color(0xFFF1F5F9)),
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text('${question['qNo']}')),
          SizedBox(width: 150, child: Text(question['type'])),
          Expanded(child: Text(question['yourAnswer'])),
          Expanded(child: Text(question['correctAnswer'])),
          SizedBox(
            width: 120,
            child: Text(
              isCorrect ? "Correct" : "Wrong",
              style: TextStyle(
                color: isCorrect ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            width: 100,
            child: Text(question['marks'], textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            "No data",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
