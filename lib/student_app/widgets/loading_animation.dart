import 'dart:math';
import 'package:flutter/material.dart';

class StudentLoadingAnimation extends StatefulWidget {
  const StudentLoadingAnimation({super.key});

  @override
  State<StudentLoadingAnimation> createState() =>
      _StudentLoadingAnimationState();
}

class _StudentLoadingAnimationState extends State<StudentLoadingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0, const Color(0xFF3B82F6)),
                const SizedBox(width: 8),
                _buildDot(1, const Color(0xFF60A5FA)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(2, const Color(0xFF10B981)),
                const SizedBox(width: 8),
                _buildDot(3, const Color(0xFF6366F1)),
                const SizedBox(width: 8),
                _buildDot(4, const Color(0xFF8B5CF6)),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildDot(int index, Color color) {
    final double delay = index * 0.15;
    final double value =
        (sin((_controller.value * 2 * 3.14159) - delay) + 1) / 2;

    return Transform.scale(
      scale: 0.7 + (value * 0.5),
      child: Opacity(
        opacity: 0.6 + (value * 0.4),
        child: Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 5,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
