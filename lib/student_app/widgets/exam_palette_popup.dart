import 'package:flutter/material.dart';

class ExamPalettePopup extends StatelessWidget {
  final bool isDark;
  final String studentName;
  final String hallTicket;
  final String group;
  final String formattedTime;
  final List<dynamic> questions;
  final Map<int, String> answers;
  final Set<int> markedForReview;
  final Set<int> visited;
  final int currentIndex;
  final Function(int) onQuestionSelected;
  final VoidCallback onSubmit;

  const ExamPalettePopup({
    super.key,
    required this.isDark,
    required this.studentName,
    required this.hallTicket,
    required this.group,
    required this.formattedTime,
    required this.questions,
    required this.answers,
    required this.markedForReview,
    required this.visited,
    required this.currentIndex,
    required this.onQuestionSelected,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.close_rounded,
                color: isDark ? Colors.black : const Color(0xFF64748B),
                size: 24,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
          const SizedBox(height: 8),
          // 1. Timer Card (Internal)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  "TIME REMAINING",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formattedTime,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),

          // 2. Student Info Card
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: const Color(0xFFFDF4FF),
                child: Text(
                  studentName.isNotEmpty ? studentName[0].toUpperCase() : "V",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD946EF),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      studentName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      "HT: $hallTicket",
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? Colors.white60
                            : const Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      group,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? Colors.white60
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 3. Legend Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(const Color(0xFF22C55E), "Answered"),
                const SizedBox(width: 10),
                _buildLegendItem(const Color(0xFFEF4444), "Visited"),
                const SizedBox(width: 10),
                _buildLegendItem(const Color(0xFFF59E0B), "Marked"),
                const SizedBox(width: 10),
                _buildLegendItem(
                  isDark ? Colors.white10 : Colors.white,
                  "Not Visited",
                  border: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Divider(
            height: 1,
            color: isDark ? Colors.white10 : Colors.grey.shade100,
          ),
          const SizedBox(height: 20),

          // 4. All Questions
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "All Questions",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 10,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: questions.length,
              itemBuilder: (context, index) {
                bool isAns = answers.containsKey(index);
                bool isMarked = markedForReview.contains(index);
                bool isVisited = visited.contains(index);
                bool isCurrent = index == currentIndex;

                Color color = isAns
                    ? const Color(0xFF22C55E)
                    : (isMarked
                          ? const Color(0xFFF59E0B)
                          : (isVisited
                                ? const Color(0xFFEF4444)
                                : (isDark
                                      ? const Color(0xFF1E293B)
                                      : const Color(0xFFF8FAFC))));

                if (isCurrent) color = const Color(0xFF3B82F6);

                return InkWell(
                  onTap: () => onQuestionSelected(index),
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                      border: (!isAns && !isMarked && !isVisited && !isCurrent)
                          ? Border.all(
                              color: isDark
                                  ? Colors.white12
                                  : Colors.grey.shade200,
                            )
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        "${index + 1}",
                        style: TextStyle(
                          color:
                              (color == const Color(0xFFF8FAFC) ||
                                  color == const Color(0xFF1E293B))
                              ? (isDark ? Colors.white30 : Colors.grey.shade400)
                              : Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // 5. Submit Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Submit Exam",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, {bool border = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
            border: border ? Border.all(color: Colors.grey.shade300) : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
