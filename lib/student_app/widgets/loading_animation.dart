import 'package:flutter/material.dart';
import 'dart:math' as math;

class StudentLoadingAnimation extends StatefulWidget {
  final double size;
  const StudentLoadingAnimation({super.key, this.size = 50});

  @override
  State<StudentLoadingAnimation> createState() => _StudentLoadingAnimationState();
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
    final dotSize = widget.size * 0.25;
    final spacing = widget.size * 0.1;

    // Colors matching the image
    final colors = [
      const Color(0xFF4285F4), // Blue
      const Color(0xFF63B3ED), // Light Blue
      const Color(0xFF14B8A6), // Teal
      const Color(0xFF7C3AED), // Indigo/Purple
      const Color(0xFFA78BFA), // Light Purple
    ];

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: 2 dots
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDot(0, dotSize, colors[0]),
              SizedBox(width: spacing),
              _buildDot(1, dotSize, colors[1]),
              // Empty space to align with 3 dots below if needed
              SizedBox(width: dotSize + spacing), 
            ],
          ),
          SizedBox(height: spacing),
          // Row 2: 3 dots
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDot(2, dotSize, colors[2]),
              SizedBox(width: spacing),
              _buildDot(3, dotSize, colors[3]),
              SizedBox(width: spacing),
              _buildDot(4, dotSize, colors[4]),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index, double size, Color color) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Create a staggered effect
        final start = index * 0.15;
        final end = start + 0.6;
        
        double value = 0.0;
        if (_controller.value >= start && _controller.value <= end) {
          value = (_controller.value - start) / 0.6;
        } else if (_controller.value > end) {
          value = 1.0 - (_controller.value - end) / (1.0 - end);
        } else {
          // Wrap around for the beginning of the next cycle or end of previous
          value = 0.0;
        }

        // Smooth curve
        final curveValue = math.sin(value * math.pi);
        
        final opacity = 0.3 + (curveValue * 0.7);
        final scale = 0.8 + (curveValue * 0.4);

        return Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
