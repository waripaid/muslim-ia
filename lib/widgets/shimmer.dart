import 'package:flutter/material.dart';

class ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double radius;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerBox({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.radius = 8,
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
    _anim = Tween(begin: -2.0, end: 2.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutSine));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = widget.baseColor ?? (isDark ? const Color(0xFF2A2A3E) : const Color(0xFFEBEBEB));
    final highlight = widget.highlightColor ?? (isDark ? const Color(0xFF3A3A4E) : const Color(0xFFF5F5F5));

    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(_anim.value - 1, 0),
              end: Alignment(_anim.value, 0),
              colors: [base, highlight, base],
            ),
            borderRadius: BorderRadius.circular(widget.radius),
          ),
        );
      },
    );
  }
}

/// Skeleton qui imite une bulle de chat en chargement
class ChatLoadingSkeleton extends StatelessWidget {
  const ChatLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar + name row
          Row(children: [
            const ShimmerBox(width: 28, height: 28, radius: 8),
            const SizedBox(width: 8),
            const ShimmerBox(width: 80, height: 14, radius: 6),
          ]),
          const SizedBox(height: 12),
          // Content lines
          ShimmerBox(width: w * 0.85, height: 14, radius: 6),
          const SizedBox(height: 8),
          ShimmerBox(width: w * 0.7, height: 14, radius: 6),
          const SizedBox(height: 8),
          ShimmerBox(width: w * 0.6, height: 14, radius: 6),
          const SizedBox(height: 8),
          ShimmerBox(width: w * 0.75, height: 14, radius: 6),
          const SizedBox(height: 12),
          ShimmerBox(width: w * 0.4, height: 14, radius: 6),
        ],
      ),
    );
  }
}

/// Skeleton pour la liste de sourates
class SkeletonListTile extends StatelessWidget {
  const SkeletonListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(children: [
        const ShimmerBox(width: 36, height: 36, radius: 10),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ShimmerBox(width: MediaQuery.of(context).size.width * 0.4, height: 14, radius: 6),
            const SizedBox(height: 4),
            ShimmerBox(width: MediaQuery.of(context).size.width * 0.6, height: 11, radius: 4),
          ]),
        ),
        const ShimmerBox(width: 24, height: 24, radius: 8),
      ]),
    );
  }
}
