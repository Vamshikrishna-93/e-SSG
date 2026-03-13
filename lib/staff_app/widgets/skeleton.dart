import 'dart:math';
import 'package:flutter/material.dart';

class SkeletonLoader extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;

  const SkeletonLoader({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8,
    required int itemCount,
  });

  @override
  Widget build(BuildContext context) {
    return const StaffLoadingAnimation();
  }
}

class SkeletonList extends StatelessWidget {
  final int itemCount;

  const SkeletonList({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return const Center(child: StaffLoadingAnimation());
  }
}

class StaffLoadingAnimation extends StatefulWidget {
  const StaffLoadingAnimation({super.key});

  @override
  State<StaffLoadingAnimation> createState() => _StaffLoadingAnimationState();
}

class _StaffLoadingAnimationState extends State<StaffLoadingAnimation>
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

class StatCardSkeleton extends StatelessWidget {
  final Color baseColor;

  const StatCardSkeleton({super.key, required this.baseColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: baseColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Decorative arcs (matching original)
            Positioned(
              bottom: -30,
              right: -30,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: baseColor.withOpacity(0.1),
                    width: 1.2,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -45,
              right: -45,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: baseColor.withOpacity(0.1),
                    width: 1.2,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 80,
                    height: 15,
                    decoration: BoxDecoration(
                      color: baseColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 40,
                    height: 25,
                    decoration: BoxDecoration(
                      color: baseColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 100,
                    height: 12,
                    decoration: BoxDecoration(
                      color: baseColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 90,
                    height: 12,
                    decoration: BoxDecoration(
                      color: baseColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 110,
                    height: 12,
                    decoration: BoxDecoration(
                      color: baseColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
