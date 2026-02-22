import 'package:flutter/material.dart';

class ExamQuestionCard extends StatelessWidget {
  final bool isDark;
  final int currentIndex;
  final Map<String, dynamic> question;
  final String strippedQuestion;

  const ExamQuestionCard({
    super.key,
    required this.isDark,
    required this.currentIndex,
    required this.question,
    required this.strippedQuestion,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _buildBadge(
                  question['subject_name']
                          ?.toString()
                          .substring(0, 2)
                          .toUpperCase() ??
                      "SU",
                  Colors.blue,
                  isDark,
                ),
                const SizedBox(width: 8),
                _buildBadge(
                  question['section_name'] ?? "Section A",
                  Colors.green,
                  isDark,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Question ${currentIndex + 1}",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                Text(
                  "${question['subject_name'] ?? 'Subject'} - ${question['section_name'] ?? 'Section'}",
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            Wrap(
              spacing: 4,
              children: [
                _buildTag("Single Choice", Colors.blue),
                _buildTag("medium", Colors.orange),
                _buildTag("+ 5 Marks", Colors.green),
                _buildTag("- 2 Negative", Colors.red),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            strippedQuestion,
            style: TextStyle(
              fontSize: 18,
              height: 1.5,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
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

  Widget _buildBadge(String label, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}
