import 'dart:math';
import 'package:flutter/material.dart';

class ShakeWidget extends StatefulWidget {
  final Widget child;
  final bool shake;

  const ShakeWidget({super.key, required this.child, this.shake = false});

  @override
  State<ShakeWidget> createState() => _ShakeWidgetState();
}

class _ShakeWidgetState extends State<ShakeWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  bool _wasShaking = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
  }

  @override
  void didUpdateWidget(ShakeWidget old) {
    super.didUpdateWidget(old);
    if (widget.shake && !_wasShaking) {
      _ctrl.forward(from: 0);
    }
    _wasShaking = widget.shake;
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        final shake = (0.5 - (_ctrl.value - 0.5).abs()) * 2;
        final offset = 8 * sin(_ctrl.value * 8 * 3.14159) * shake;
        return Transform.translate(offset: Offset(offset, 0), child: child);
      },
      child: widget.child,
    );
  }
}
