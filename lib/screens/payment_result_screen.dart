import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../l10n/app_localizations.dart';

/// Résultat d'action renvoyé par l'écran de résultat à la page appelante.
enum PaymentResultAction {
  /// Abonnement activé, on referme tout.
  success,

  /// L'utilisateur veut réessayer le paiement.
  retry,

  /// L'utilisateur ferme simplement l'écran (échec).
  close,
}

/// Écran de résultat d'abonnement très soigné :
/// - succès : badge or animé, halos pulsants, confettis et rappel des avantages ;
/// - échec : badge animé (secousse), tonalité chaleureuse, boutons Réessayer / Fermer.
class PaymentResultScreen extends StatefulWidget {
  final bool success;
  final String? message;

  const PaymentResultScreen({super.key, required this.success, this.message});

  @override
  State<PaymentResultScreen> createState() => _PaymentResultScreenState();
}

class _PaymentResultScreenState extends State<PaymentResultScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _badgeScale;
  late final Animation<double> _badgeFade;
  late final Animation<Offset> _contentSlide;
  late final Animation<double> _buttonsFade;
  late final Animation<double> _ringsFade;
  late final Animation<Offset> _shake;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.success ? 3600 : 2600),
    );
    final badgeCurve = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.55, curve: Curves.elasticOut),
    );
    _badgeScale = Tween(begin: 0.2, end: 1.0).animate(badgeCurve);
    _badgeFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.35, 0.8, curve: Curves.easeOutCubic),
    ));
    _buttonsFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    );
    _ringsFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    );
    _shake = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.015, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.1, 0.55, curve: Curves.easeInOut),
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final message = widget.message ?? '';

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: widget.success
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0A0E2E), Color(0xFF0F1B4C), Color(0xFF1E3A8A)],
                )
              : const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1C1030), Color(0xFF0F1B4C)],
                ),
        ),
        child: Stack(
          children: [
            if (widget.success)
              const Positioned(
                top: -120,
                right: -80,
                child: _Glow(radius: 260, color: Color(0x33D4AF37)),
              )
            else
              const Positioned(
                top: -120,
                right: -80,
                child: _Glow(radius: 260, color: Color(0x33DC2626)),
              ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 36, 28, 32),
                child: Column(
                  children: [
                    SizedBox(
                      height: 180,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          _pulsingRings(),
                          AnimatedBuilder(
                            animation: _controller,
                            builder: (context, _) {
                              final shakeValue = widget.success
                                  ? Offset.zero
                                  : Offset(
                                      math.sin(_shake.value.dx * 120) * 10,
                                      0,
                                    );
                              return Transform.translate(
                                offset: shakeValue,
                                child: FadeTransition(
                                  opacity: _badgeFade,
                                  child: ScaleTransition(
                                    scale: _badgeScale,
                                    child: _badge(),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    SlideTransition(
                      position: _contentSlide,
                      child: Column(
                        children: [
                          Text(
                            widget.success
                                ? l10n.paymentSuccessTitle
                                : l10n.paymentFailureTitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            widget.success
                                ? l10n.paymentSuccessSubtitle
                                : message.isNotEmpty
                                    ? message
                                    : l10n.paymentFailureSubtitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.45,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, _) => FadeTransition(
                        opacity: _buttonsFade,
                        child: SlideTransition(
                          position: _contentSlide,
                          child: widget.success
                              ? _successPerks(l10n)
                              : _failurePerks(l10n),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, _) => FadeTransition(
                        opacity: _buttonsFade,
                        child: Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: _goldButton(
                                icon: widget.success
                                    ? Icons.auto_awesome_rounded
                                    : Icons.refresh_rounded,
                                label: widget.success
                                    ? l10n.paymentStart
                                    : l10n.retry,
                                onTap: () => Navigator.pop(
                                  context,
                                  widget.success
                                      ? PaymentResultAction.success
                                      : PaymentResultAction.retry,
                                ),
                              ),
                            ),
                            if (!widget.success) ...[
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: OutlinedButton.icon(
                                  onPressed: () => Navigator.pop(
                                    context,
                                    PaymentResultAction.close,
                                  ),
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    size: 20,
                                    color: Colors.white70,
                                  ),
                                  label: Text(
                                    l10n.close,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: Colors.white.withValues(alpha: 0.25),
                                      width: 1.2,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (widget.success)
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) =>
                        CustomPaint(painter: _ConfettiPainter(_controller)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _goldButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppGradients.gold,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC5A028).withValues(alpha: 0.4),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: AppColors.primaryDark),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _pulsingRings() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _ringsFade.value;
        return Stack(
          alignment: Alignment.center,
          children: [
            _ring(t, 180, 0.15),
            _ring(t, 220, 0.10),
          ],
        );
      },
    );
  }

  Widget _ring(double t, double size, double opacity) {
    if (!widget.success || t <= 0) return const SizedBox.shrink();
    return Opacity(
      opacity: (1 - t) * opacity,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.accent.withValues(alpha: (1 - t)),
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _badge() {
    return Container(
      width: 132,
      height: 132,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: widget.success
            ? AppGradients.gold
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF87171), Color(0xFFDC2626)],
              ),
        boxShadow: [
          BoxShadow(
            color: widget.success
                ? const Color(0xFFC5A028).withValues(alpha: 0.45)
                : const Color(0xFFDC2626).withValues(alpha: 0.35),
            blurRadius: 34,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            margin: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.35),
                width: 1.5,
              ),
            ),
          ),
          Icon(
            widget.success
                ? Icons.check_rounded
                : Icons.close_rounded,
            size: 66,
            color: widget.success
                ? AppColors.primaryDark
                : Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _successPerks(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.22)),
      ),
      child: Column(
        children: [
          _perkRow(Icons.forum_rounded, l10n.paywallFreeChat),
          _perkRow(Icons.auto_awesome_rounded, l10n.paywallVision),
          _perkRow(Icons.memory_rounded, l10n.paywallMemorization),
        ],
      ),
    );
  }

  Widget _failurePerks(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          _perkRow(Icons.credit_card_rounded, l10n.paywallCard),
          _perkRow(Icons.lock_rounded, l10n.paywallAlreadyPaid),
        ],
      ),
    );
  }

  Widget _perkRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: widget.success
                  ? AppColors.accent.withValues(alpha: 0.15)
                  : Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 18, color: AppColors.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          Icon(
            widget.success ? Icons.check_circle_rounded : Icons.info_outline_rounded,
            size: 18,
            color: widget.success
                ? AppColors.accent
                : Colors.white.withValues(alpha: 0.45),
          ),
        ],
      ),
    );
  }
}

/// Lueur radiale douce en arrière-plan.
class _Glow extends StatelessWidget {
  final double radius;
  final Color color;

  const _Glow({required this.radius, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
        ),
      ),
    );
  }
}

/// Confettis dorés et émeraude qui tombent en douceur.
class _ConfettiPainter extends CustomPainter {
  final Animation<double> animation;
  late final List<_Confetti> _particles;

  static final math.Random _random = math.Random();

  _ConfettiPainter(this.animation) {
    _particles = List.generate(
      46,
      (_) => _Confetti(
        x: _random.nextDouble(),
        y: -_random.nextDouble() * 0.6,
        size: 5 + _random.nextDouble() * 5,
        speed: 0.5 + _random.nextDouble() * 0.8,
        sway: 0.5 + _random.nextDouble() * 0.9,
        phase: _random.nextDouble() * math.pi * 2,
        rotation: _random.nextDouble() * math.pi,
        color: [
          const Color(0xFFE8C547),
          const Color(0xFFD4AF37),
          const Color(0xFFFFFFFF),
          const Color(0xFF10B981),
        ][_random.nextInt(4)],
      ),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final p = animation.value;
    for (final c in _particles) {
      final fall = (c.y + p * c.speed) % 1.15;
      if (fall > 1.0) continue;
      final x = (c.x + math.sin(p * c.sway * 6 + c.phase) * 0.05) * size.width;
      final y = fall * size.height;
      final opacity = fall > 0.85 ? (1 - (fall - 0.85) / 0.3).clamp(0.0, 1.0) : 1.0;
      final paint = Paint()
        ..color = c.color.withValues(alpha: opacity * 0.85);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(c.rotation + p * 6);
      final r = c.size / 2;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: c.size, height: r),
          Radius.circular(r / 2),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) => true;
}

class _Confetti {
  final double x, y, size, speed, sway, phase, rotation;
  final Color color;

  _Confetti({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.sway,
    required this.phase,
    required this.rotation,
    required this.color,
  });
}
