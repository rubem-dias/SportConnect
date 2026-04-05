import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';

class AppLoadingSkeleton extends StatefulWidget {
  const AppLoadingSkeleton({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius,
    this.isCircle = false,
  });

  const AppLoadingSkeleton.circle({
    super.key,
    required double size,
  })  : width = size,
        height = size,
        borderRadius = null,
        isCircle = true;

  final double? width;
  final double height;
  final double? borderRadius;
  final bool isCircle;

  @override
  State<AppLoadingSkeleton> createState() => _AppLoadingSkeletonState();
}

class _AppLoadingSkeletonState extends State<AppLoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? AppColors.surfaceVariantDark
        : AppColors.surfaceVariantLight;

    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) => Opacity(
        opacity: _animation.value,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: widget.isCircle
                ? BorderRadius.circular(9999)
                : BorderRadius.circular(widget.borderRadius ?? AppRadius.xs),
          ),
        ),
      ),
    );
  }
}

/// Skeleton para um card de post no feed.
class PostCardSkeleton extends StatelessWidget {
  const PostCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AppLoadingSkeleton.circle(size: 40),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppLoadingSkeleton(width: 120, height: 14, borderRadius: 4),
                  const SizedBox(height: 4),
                  AppLoadingSkeleton(width: 80, height: 12, borderRadius: 4),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppLoadingSkeleton(width: double.infinity, height: 14, borderRadius: 4),
          const SizedBox(height: 6),
          AppLoadingSkeleton(width: double.infinity, height: 14, borderRadius: 4),
          const SizedBox(height: 6),
          AppLoadingSkeleton(width: 200, height: 14, borderRadius: 4),
          const SizedBox(height: 12),
          AppLoadingSkeleton(
            width: double.infinity,
            height: 200,
            borderRadius: 12,
          ),
        ],
      ),
    );
  }
}
