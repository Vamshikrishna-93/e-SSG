import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;

  const SkeletonLoader({
    super.key,
    this.width = double.infinity,
    this.height = 20.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[50]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius,
        ),
      ),
    );
  }

  static Widget card({double height = 150, double width = double.infinity}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SkeletonLoader(
        height: height,
        width: width,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  static Widget listItem() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        children: [
          const SkeletonLoader(
            width: 40,
            height: 40,
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonLoader(height: 14, width: double.infinity),
                const SizedBox(height: 8),
                SkeletonLoader(height: 12, width: 150),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget section({String? title, int itemCount = 3}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SkeletonLoader(height: 20, width: 150),
          ),
        ...List.generate(itemCount, (index) => listItem()),
      ],
    );
  }
}
