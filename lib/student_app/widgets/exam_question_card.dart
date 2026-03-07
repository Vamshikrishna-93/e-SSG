import 'package:flutter/material.dart';

class ExamQuestionCard extends StatelessWidget {
  final int currentIndex;
  final Map<String, dynamic> question;
  final String strippedQuestion;

  const ExamQuestionCard({
    super.key,
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
                ),
                const SizedBox(width: 8),
                _buildBadge(
                  question['section_name'] ?? "Section A",
                  Colors.green,
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
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            Wrap(
              spacing: 4,
              children: [
                _buildTag("Single Choice", Colors.blue),
                _buildTag(
                  question['difficulty']?.toString().toLowerCase() ?? "medium",
                  Colors.orange,
                ),
                _buildTag(
                  "+ ${question['correct_marks'] ?? '0'} Marks",
                  Colors.green,
                ),
                _buildTag(
                  "- ${question['negative_marks'] ?? '0'} Negative",
                  Colors.red,
                ),
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
            style: const TextStyle(
              fontSize: 18,
              height: 1.5,
              color: Color(0xFF1E293B),
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
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(127)),
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

  Widget _buildBadge(String label, Color color) {
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
