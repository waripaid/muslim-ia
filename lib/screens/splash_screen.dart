import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';
import '../l10n/app_localizations.dart';

/// Splash screen premium « Muslim IA » :
/// aurore nocturne animée, croissant de lune, rayons dorés rotatifs, étoile
/// islamique, anneau orbital, ondes lumineuses, particules scintillantes,
/// basmala, titre en reflet doré et barre de progression chatoyante.
class SplashScreen extends StatefulWidget {
  final VoidCallback onFinished;

  const SplashScreen({super.key, required this.onFinished});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4400),
    )..forward().whenComplete(widget.onFinished);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  double _clip(double t) => t.clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF040818),
        body: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) {
            final p = _ctrl.value;
            final fadeOut = p < 0.9 ? 1.0 : 1.0 - (p - 0.9) / 0.1;

            final t = math.sin(p * math.pi * 2); // 0..1..0
            final glow = (0.5 + 0.5 * t).toDouble();
            final orbitAngle = p * math.pi * 2 * 1.6;
            final raysRotation = p * math.pi * 2 * 0.35;

            // ── Timeline ─────────────────────────────────────────
            final moonOpacity = _clip(p / 0.3);
            final starOpacity = _clip((p - 0.08) / 0.25);
            final raysOpacity = 0.12 + 0.25 * _clip((p - 0.05) / 0.2);
            final orbitOpacity = _clip((p - 0.25) / 0.2);
            final logoScale = Curves.easeOutBack.transform(_clip(p / 0.45));
            final logoOpacity = _clip(p / 0.35);
            final rippleOpacity = _clip((p - 0.15) / 0.3);
            final bismillahOpacity = _clip((p - 0.05) / 0.3);
            final titleOpacity = _clip((p - 0.4) / 0.2);
            final taglineOpacity = _clip((p - 0.55) / 0.2);
            final progress = _clip((p - 0.15) / 0.7);

            // ── Positions d'aurore animées ───────────────────────
            final auroraX = math.sin(p * math.pi * 2) * 60;
            final auroraY = math.cos(p * math.pi * 2) * 30;

            return Opacity(
              opacity: fadeOut.clamp(0.0, 1.0),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // ── Fond nocturne profond ───────────────────────
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF030612),
                          Color(0xFF081233),
                          Color(0xFF0E2258),
                          Color(0xFF142E6B),
                        ],
                      ),
                    ),
                  ),

                  // ── Aurore dorée flottante ──────────────────────
                  Transform.translate(
                    offset: Offset(auroraX, -auroraY),
                    child: Positioned(
                      top: -100,
                      right: -60,
                      child: Container(
                        width: 320,
                        height: 320,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.accent.withValues(alpha: 0.14 + 0.06 * glow),
                              AppColors.accent.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // ── Aurore bleue flottante ──────────────────────
                  Transform.translate(
                    offset: Offset(-auroraX * 0.8, auroraY),
                    child: Positioned(
                      bottom: -110,
                      left: -90,
                      child: Container(
                        width: 340,
                        height: 340,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF4F7CFF).withValues(alpha: 0.13),
                              const Color(0xFF4F7CFF).withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // ── Aurore émeraude (centre) ───────────────────
                  Transform.translate(
                    offset: Offset(0, math.sin(p * math.pi * 2 + 1) * 40),
                    child: Center(
                      child: Container(
                        width: 420,
                        height: 420,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF2DD4BF).withValues(alpha: 0.07),
                              const Color(0xFF2DD4BF).withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Croissant de lune ───────────────────────────
                  Positioned(
                    top: 70,
                    right: 44,
                    child: Opacity(
                      opacity: moonOpacity * fadeOut,
                      child: CustomPaint(
                        size: const Size(96, 96),
                        painter: _CrescentPainter(
                          color: const Color(0xFFF7E7B4),
                          glow: glow,
                        ),
                      ),
                    ),
                  ),

                  // ── Particules scintillantes ────────────────────
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _ParticlesPainter(
                        progress: p,
                        gold: const Color(0xFFFBE9B0),
                        blue: const Color(0xFF9FC3FF),
                      ),
                    ),
                  ),

                  // ── Contenu central ─────────────────────────────
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        children: [
                          const SizedBox(height: 46),

                          // ── Basmala ─────────────────────────────
                          Opacity(
                            opacity: bismillahOpacity * fadeOut,
                            child: Text(
                              'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
                              textDirection: TextDirection.rtl,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 17,
                                height: 1.4,
                                color: const Color(0xFFF5E6B8).withValues(alpha: 0.85),
                                shadows: const [
                                  Shadow(color: Colors.black26, blurRadius: 12),
                                ],
                              ),
                            ),
                          ),

                          const Spacer(flex: 3),

                          // ── Bloc logo (rayons, étoile, anneaux, orbites) ──
                          SizedBox(
                            width: 320,
                            height: 320,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Ondes lumineuses successives
                                ...List.generate(3, (i) {
                                  final wave = ((p * 2.2) + i / 3) % 1.0;
                                  return Opacity(
                                    opacity: (1 - wave) * 0.35 * rippleOpacity * fadeOut,
                                    child: Transform.scale(
                                      scale: 0.5 + wave * 0.9,
                                      child: Container(
                                        width: 320,
                                        height: 320,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppColors.accent.withValues(alpha: 0.55),
                                            width: 1.2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),

                                // Rayons dorés rotatifs
                                Opacity(
                                  opacity: raysOpacity * fadeOut,
                                  child: CustomPaint(
                                    size: const Size(320, 320),
                                    painter: _SunburstPainter(
                                      rotation: raysRotation,
                                      rays: 16,
                                      color: AppColors.accent,
                                    ),
                                  ),
                                ),

                                // Étoile islamique
                                Opacity(
                                  opacity: starOpacity * fadeOut,
                                  child: CustomPaint(
                                    size: const Size(320, 320),
                                    painter: _StarPainter(
                                      rotation: -p * math.pi * 0.4,
                                      color: AppColors.accent,
                                    ),
                                  ),
                                ),

                                // Anneau pointillé externe
                                Opacity(
                                  opacity: 0.3 * fadeOut,
                                  child: CustomPaint(
                                    size: const Size(320, 320),
                                    painter: _DashedRingPainter(
                                      radius: 152,
                                      rotation: p * math.pi * 2 * 0.7,
                                      dashSweep: 0.05,
                                      dashCount: 52,
                                      strokeWidth: 1.1,
                                      color: AppColors.accent,
                                    ),
                                  ),
                                ),
                                // Anneau pointillé interne
                                Opacity(
                                  opacity: 0.35 * fadeOut,
                                  child: CustomPaint(
                                    size: const Size(320, 320),
                                    painter: _DashedRingPainter(
                                      radius: 132,
                                      rotation: -p * math.pi * 2 * 0.55,
                                      dashSweep: 0.11,
                                      dashCount: 28,
                                      strokeWidth: 1,
                                      color: const Color(0xFFF5E6B8),
                                    ),
                                  ),
                                ),

                                // Orbite avec gemmes
                                Opacity(
                                  opacity: orbitOpacity * fadeOut,
                                  child: CustomPaint(
                                    size: const Size(320, 320),
                                    painter: _OrbitPainter(
                                      radius: 142,
                                      angle: orbitAngle,
                                      color: const Color(0xFFF5E6B8),
                                      gemColor: AppColors.accentLight,
                                    ),
                                  ),
                                ),

                                // Halo pulsant autour du logo
                                Opacity(
                                  opacity: (0.25 + 0.35 * glow) * fadeOut,
                                  child: Container(
                                    width: 170 + 14 * glow,
                                    height: 170 + 14 * glow,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [
                                          AppColors.accent.withValues(alpha: 0.45),
                                          AppColors.accent.withValues(alpha: 0),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                // Logo
                                Transform.scale(
                                  scale: logoScale,
                                  child: Opacity(
                                    opacity: logoOpacity,
                                    child: Container(
                                      width: 116,
                                      height: 116,
                                      padding: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        gradient: AppGradients.gold,
                                        borderRadius: BorderRadius.circular(30),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.accent.withValues(alpha: 0.35 + 0.4 * glow),
                                            blurRadius: 30 + 18 * glow,
                                            spreadRadius: 2 + 4 * glow,
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(27),
                                        child: Image.asset(
                                          'assets/muslimia.jpeg',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 30),

                          // ── Titre avec double reflet doré ────────
                          Opacity(
                            opacity: titleOpacity * fadeOut,
                            child: ShaderMask(
                              shaderCallback: (bounds) {
                                final tri = (p * 2) % 1.0;
                                final begin = -1.4 + 2.8 * tri;
                                return LinearGradient(
                                  begin: Alignment(begin, 0),
                                  end: Alignment(begin + 2.8, 0),
                                  colors: const [
                                    Color(0xFF9B7B1C),
                                    Color(0xFFC5A028),
                                    Color(0xFFFDF0C2),
                                    Color(0xFFC5A028),
                                    Color(0xFF9B7B1C),
                                  ],
                                ).createShader(bounds);
                              },
                              blendMode: BlendMode.srcIn,
                              child: Text(
                                'Muslim IA',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 44,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.6,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: AppColors.accent.withValues(alpha: 0.5 + 0.3 * glow),
                                      blurRadius: 26,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // ── Fine ligne séparatrice dorée ─────────
                          Opacity(
                            opacity: taglineOpacity * fadeOut,
                            child: Container(
                              width: 180,
                              height: 2,
                              margin: const EdgeInsets.only(top: 14),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Colors.transparent, Color(0xFFC5A028), Colors.transparent],
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // ── Slogan ───────────────────────────────
                          Opacity(
                            opacity: taglineOpacity * fadeOut,
                            child: Text(
                              l10n.appTagline,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14.5,
                                height: 1.5,
                                color: Colors.white.withValues(alpha: 0.62),
                              ),
                            ),
                          ),

                          const Spacer(flex: 2),

                          // ── Barre de progression chatoyante ─────
                          ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Container(
                              width: 210,
                              height: 3.5,
                              color: Colors.white.withValues(alpha: 0.09),
                              alignment: Alignment.centerLeft,
                              child: FractionallySizedBox(
                                widthFactor: progress,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: AppGradients.gold,
                                    borderRadius: BorderRadius.circular(5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.accent.withValues(alpha: 0.7),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Croissant de lune lumineux.
class _CrescentPainter extends CustomPainter {
  final Color color;
  final double glow;

  _CrescentPainter({required this.color, required this.glow});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width * 0.42;

    final outer = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: 0.9),
          color.withValues(alpha: 0.05),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 2.4));

    // Halo
    canvas.drawCircle(
      center,
      radius * 1.9 * (1 + 0.06 * glow),
      Paint()..color = color.withValues(alpha: 0.14 + 0.05 * glow),
    );

    // Pleine lune
    canvas.drawCircle(center, radius, outer);

    // Découpe pour former le croissant (couleur = fond)
    canvas.drawCircle(
      center.translate(radius * 0.45, -radius * 0.22),
      radius * 0.82,
      Paint()..color = const Color(0xFF040818),
    );
  }

  @override
  bool shouldRepaint(_CrescentPainter old) => old.glow != glow;
}

/// Rayons lumineux rotatifs derrière l'étoile.
class _SunburstPainter extends CustomPainter {
  final double rotation;
  final int rays;
  final Color color;

  _SunburstPainter({
    required this.rotation,
    required this.rays,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final paint = Paint()
      ..color = color.withValues(alpha: 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    final base = size.width * 0.5;
    for (var i = 0; i < rays; i++) {
      final a = rotation + i * math.pi * 2 / rays;
      final inner = base * 0.52;
      final outer = base * (0.62 + 0.08 * ((i % 2) == 0 ? 1 : 0));
      canvas.drawLine(
        center + Offset(math.cos(a), math.sin(a)) * inner,
        center + Offset(math.cos(a), math.sin(a)) * outer,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_SunburstPainter old) =>
      old.rotation != rotation || old.color != color;
}

/// Étoile islamique (Rub el Hizb) : deux carrés superposés + cercles.
class _StarPainter extends CustomPainter {
  final double rotation;
  final Color color;

  _StarPainter({required this.rotation, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final side = size.width * 0.78;
    final rect = Rect.fromCenter(center: center, width: side, height: side);
    final paint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    canvas.translate(-center.dx, -center.dy);

    canvas.drawRect(rect, paint);
    canvas.drawCircle(center, size.width * 0.33, paint);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(math.pi / 4);
    canvas.translate(-center.dx, -center.dy);
    canvas.drawRect(rect, paint);
    canvas.restore();

    canvas.restore();
  }

  @override
  bool shouldRepaint(_StarPainter old) =>
      old.rotation != rotation || old.color != color;
}

/// Anneau en pointillés qui tourne lentement.
class _DashedRingPainter extends CustomPainter {
  final double radius;
  final double rotation;
  final double dashSweep;
  final int dashCount;
  final double strokeWidth;
  final Color color;

  _DashedRingPainter({
    required this.radius,
    required this.rotation,
    required this.dashSweep,
    required this.dashCount,
    required this.strokeWidth,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()
      ..color = color.withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final step = math.pi * 2 / dashCount;
    for (var i = 0; i < dashCount; i++) {
      canvas.drawArc(rect, rotation + i * step, dashSweep, false, paint);
    }
  }

  @override
  bool shouldRepaint(_DashedRingPainter old) =>
      old.rotation != rotation || old.color != color || old.radius != radius;
}

/// Orbite elliptique avec une gemme lumineuse qui circule.
class _OrbitPainter extends CustomPainter {
  final double radius;
  final double angle;
  final Color color;
  final Color gemColor;

  _OrbitPainter({
    required this.radius,
    required this.angle,
    required this.color,
    required this.gemColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);

    // Orbite inclinée
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-0.25);
    canvas.translate(-center.dx, -center.dy);

    final rect = Rect.fromCenter(
      center: center,
      width: radius * 2,
      height: radius * 0.82,
    );
    canvas.drawOval(
      rect,
      Paint()
        ..color = color.withValues(alpha: 0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // Gemme orbitante
    final gemX = center.dx + math.cos(angle) * radius;
    final gemY = center.dy + math.sin(angle) * radius * 0.82;
    canvas.drawCircle(
      Offset(gemX, gemY),
      3.2,
      Paint()
        ..color = gemColor.withValues(alpha: 0.95)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawCircle(
      Offset(gemX, gemY),
      1.4,
      Paint()..color = Colors.white,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(_OrbitPainter old) =>
      old.angle != angle || old.color != color;
}

/// Particules dorées et bleues scintillantes qui s'élèvent.
class _ParticlesPainter extends CustomPainter {
  final double progress;
  final Color gold;
  final Color blue;

  _ParticlesPainter({required this.progress, required this.gold, required this.blue});

  @override
  void paint(Canvas canvas, Size size) {
    // Petites particules dorées
    for (var i = 0; i < 34; i++) {
      final seed = ((i * 7919) % 997) / 997;
      final x = ((seed * 131) % size.width + size.width * 0.05)
          .clamp(size.width * 0.04, size.width * 0.96);
      final speed = 0.3 + seed * 0.55;
      final phase = (seed * 131) % 1.0;
      final t = (progress * speed + phase) % 1.0;
      final y = size.height - t * size.height * 1.05;
      final r = 1.1 + seed * 2.4;
      final twinkle = 0.55 + 0.45 * math.sin(progress * math.pi * 6 + i).abs();
      final opacity = (0.12 + 0.5 * (1 - t)) * twinkle;

      canvas.drawCircle(
        Offset(x, y),
        r,
        Paint()..color = gold.withValues(alpha: opacity),
      );
    }

    // Quelques orbes bleus plus grands
    for (var i = 0; i < 7; i++) {
      final seed = ((i * 3571) % 997) / 997;
      final x = ((seed * 211) % size.width + size.width * 0.08)
          .clamp(size.width * 0.06, size.width * 0.94);
      final speed = 0.18 + seed * 0.3;
      final phase = (seed * 211) % 1.0;
      final t = (progress * speed + phase) % 1.0;
      final y = size.height - t * size.height;
      final r = 2.5 + seed * 3.5;
      final opacity = 0.06 + 0.16 * (1 - t);

      canvas.drawCircle(
        Offset(x, y),
        r,
        Paint()..color = blue.withValues(alpha: opacity),
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlesPainter old) => old.progress != progress;
}
