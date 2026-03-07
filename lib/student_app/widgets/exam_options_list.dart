import 'package:flutter/material.dart';

class ExamOptionsList extends StatelessWidget {
  final List<String> options;
  final List<String> optionIds;
  final String? selectedOptionId;
  final Function(String) onOptionSelected;
  final String Function(String) stripHtml;

  const ExamOptionsList({
    super.key,
    required this.options,
    required this.optionIds,
    required this.selectedOptionId,
    required this.onOptionSelected,
    required this.stripHtml,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(options.length, (index) {
        final optionId = optionIds[index];
        final isSelected = selectedOptionId == optionId;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => onOptionSelected(optionId),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.grey.shade200,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(7),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Radio Indicator
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.grey.shade400,
                        width: isSelected ? 6 : 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    "${String.fromCharCode(65 + index)}.",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      stripHtml(options[index]),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
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
}
