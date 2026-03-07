import 'package:flutter/material.dart';

class ExamFooter extends StatelessWidget {
  final int currentIndex;
  final bool isMarked;
  final VoidCallback onToggleMark;
  final VoidCallback onClearResponse;
  final VoidCallback? onPrevious;
  final VoidCallback onSaveAndNext;
  final VoidCallback? onShowPalette;
  final VoidCallback onSubmit;

  final bool isLastQuestion;

  const ExamFooter({
    super.key,
    required this.currentIndex,
    required this.isMarked,
    required this.onToggleMark,
    required this.onClearResponse,
    required this.onPrevious,
    required this.onSaveAndNext,
    required this.onShowPalette,
    required this.onSubmit,
    this.isLastQuestion = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: Mark & Clear + Previous
          Row(
            children: [
              // Left side: Mark & Clear
              Container(
                height: 40,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextButton(
                  onPressed: onToggleMark,
                  child: Text(
                    isMarked ? "Unmark" : "Mark for Review",
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                height: 40,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextButton(
                  onPressed: onClearResponse,
                  child: Text(
                    "Clear response",
                    style: TextStyle(
                      color: Colors.red.shade400,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 80),
              // Previous
              SizedBox(
                height: 40,
                child: ElevatedButton.icon(
                  onPressed: onPrevious,
                  icon: const Icon(Icons.chevron_left, size: 18),
                  label: const Text("Previous", style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade400,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Row 2: Palette Button + Primary Action (Save & Next / Submit)
          Row(
            children: [
              if (onShowPalette != null) ...[
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    height: 40,
                    child: OutlinedButton.icon(
                      onPressed: onShowPalette,
                      icon: const Icon(Icons.grid_view_rounded, size: 16),
                      label: const Text(
                        "All questions",
                        style: TextStyle(fontSize: 12),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1D58D8),
                        side: const BorderSide(color: Color(0xFF1D58D8)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: isLastQuestion ? onSubmit : onSaveAndNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isLastQuestion
                          ? const Color(0xFF1D68F2)
                          : const Color(0xFF22C55E),
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shadowColor: (isLastQuestion ? Colors.blue : Colors.green)
                          .withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      isLastQuestion ? "Submit Exam" : "Save & Next",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
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
}
