import 'package:shimmer/shimmer.dart';
import 'package:flutter/material.dart';

class LeadCardShimmer extends StatelessWidget {
  final bool isTablet;

  const LeadCardShimmer({super.key, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.white.withOpacity(0.2),
      highlightColor: Colors.white.withOpacity(0.4),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.20),
                  Colors.white.withOpacity(0.05),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Company & Customer shimmer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _shimmerBox(width: 150, height: isTablet ? 28 : 18),
                      _shimmerBox(width: 100, height: isTablet ? 20 : 12),
                    ],
                  ),
                  const SizedBox(height: 15),
                  // Next meeting shimmer
                  _shimmerBox(width: 120, height: isTablet ? 20 : 14),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _shimmerBox(width: 80, height: isTablet ? 20 : 14),
                      const SizedBox(width: 10),
                      _shimmerBox(width: 100, height: isTablet ? 20 : 14),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Buttons shimmer
                  Row(
                    children: List.generate(
                      4,
                      (index) => Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: _shimmerBox(width: 70, height: 30, radius: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (context, index) {
          return const SizedBox(height: 15);
        },
        itemCount: 10,
      ),
    );
  }

  Widget _shimmerBox({
    required double width,
    required double height,
    double radius = 5,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
