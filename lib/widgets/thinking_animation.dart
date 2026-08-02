import 'package:flutter/material.dart';
import '../config/theme.dart';

class ThinkingAnimation extends StatefulWidget {
  const ThinkingAnimation({super.key});

  @override
  State<ThinkingAnimation> createState() => _ThinkingAnimationState();
}

class _ThinkingAnimationState extends State<ThinkingAnimation> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..repeat(reverse: true);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: (isDark ? Colors.white : AppColors.accent).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.accent.withValues(alpha: 0.1)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 48,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(3, (i) {
                      final delay = i * 0.2;
                      return AnimatedBuilder(
                        animation: _ctrl,
                        builder: (_, __) {
                          final t = ((_ctrl.value - delay) % 1.0).abs();
                          return Container(
                            width: 7, height: 7,
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.3 + 0.7 * (1 - (t - 0.5).abs() * 2)),
                              shape: BoxShape.circle,
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  'Réflexion en cours...',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.accent.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Transform.rotate(
                  angle: _ctrl.value * 6.28,
                  child: Icon(
                    Icons.nights_stay_rounded,
                    size: 18,
                    color: AppColors.accent.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
