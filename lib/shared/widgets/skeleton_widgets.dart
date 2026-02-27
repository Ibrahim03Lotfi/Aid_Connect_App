import 'package:flutter/material.dart';

/// Light of Impact - Warm Hopeful Color System
const Color backgroundOffWhite = Color(0xFFF9FAFB);
const Color softBlueTint = Color(0xFFF3F8FC);
const Color friendlyBlue = Color(0xFF1E7ABF);
const Color softTeal = Color(0xFF3BB3A9);
const Color textDark = Color(0xFF1F2937);
const Color textMedium = Color(0xFF6B7280);
const Color textLight = Color(0xFF9CA3AF);
const Color cardWhite = Color(0xFFFFFFFF);
const Color borderLight = Color(0xFFE5E7EB);

/// Shimmer effect colors
const Color shimmerBaseColor = Color(0xFFE8EDF2);
const Color shimmerHighlightColor = Color(0xFFF5F7FA);

/// Reusable skeleton card widget
class SkeletonCard extends StatelessWidget {
  final double height;
  final EdgeInsets margin;
  final BorderRadius borderRadius;

  const SkeletonCard({
    super.key,
    this.height = 100,
    this.margin = const EdgeInsets.only(bottom: 12),
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      height: height,
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: borderRadius,
        border: Border.all(color: borderLight, width: 1),
      ),
      child: const ShimmerEffect(),
    );
  }
}

/// Shimmer effect widget that creates a loading animation
class ShimmerEffect extends StatefulWidget {
  final Widget? child;
  final bool enabled;

  const ShimmerEffect({
    super.key,
    this.child,
    this.enabled = true,
  });

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: -1, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutSine,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child ?? const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                shimmerBaseColor,
                shimmerHighlightColor,
                shimmerBaseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              transform: _SlidingGradientTransform(_animation.value),
            ).createShader(bounds);
          },
          child: widget.child ??
              Container(
                color: shimmerBaseColor,
                child: const SizedBox.expand(),
              ),
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double percent;

  const _SlidingGradientTransform(this.percent);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * percent, 0, 0);
  }
}

/// Skeleton circle widget for avatar placeholders
class SkeletonCircle extends StatelessWidget {
  final double size;

  const SkeletonCircle({
    super.key,
    this.size = 64,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: shimmerBaseColor,
        shape: BoxShape.circle,
      ),
      child: const ShimmerEffect(),
    );
  }
}

/// Skeleton text widget for loading text placeholders
class SkeletonText extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;

  const SkeletonText({
    super.key,
    this.width = double.infinity,
    this.height = 14,
    this.borderRadius = const BorderRadius.all(Radius.circular(6)),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: shimmerBaseColor,
        borderRadius: borderRadius,
      ),
      child: const ShimmerEffect(),
    );
  }
}

/// Full page skeleton loader for list views
class SkeletonList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;

  const SkeletonList({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 100,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: itemCount,
      itemBuilder: (context, index) => SkeletonCard(height: itemHeight),
    );
  }
}

/// Skeleton for home screen
class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome header skeleton
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: shimmerBaseColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const ShimmerEffect(),
          ),
          const SizedBox(height: 24),
          // Categories skeleton
          const SkeletonText(width: 100, height: 20),
          const SizedBox(height: 12),
          Row(
            children: List.generate(
              4,
              (index) => Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Container(
                  width: 90,
                  height: 80,
                  decoration: BoxDecoration(
                    color: shimmerBaseColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const ShimmerEffect(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Latest cases header
          const SkeletonText(width: 120, height: 20),
          const SizedBox(height: 12),
          // Case cards skeleton
          ...List.generate(
            3,
            (index) => const SkeletonCard(height: 120),
          ),
        ],
      ),
    );
  }
}

/// Skeleton for profile screen
class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Avatar skeleton
          const SkeletonCircle(size: 100),
          const SizedBox(height: 16),
          // Name skeleton
          const SkeletonText(width: 150, height: 24),
          const SizedBox(height: 8),
          const SkeletonText(width: 120, height: 16),
          const SizedBox(height: 24),
          // Menu items skeleton
          ...List.generate(
            4,
            (index) => const SkeletonCard(height: 60),
          ),
        ],
      ),
    );
  }
}
