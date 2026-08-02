import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../l10n/app_localizations.dart';
import '../models/arabic_letter.dart';
import '../widgets/speak_button.dart';

class WritingTab extends StatefulWidget {
  const WritingTab({super.key});
  @override
  State<WritingTab> createState() => _WritingTabState();
}

class _WritingTabState extends State<WritingTab> {
  ArabicLetter _current = ArabicLetter.alphabet[0];
  final List<Offset> _points = [];
  final List<List<Offset>> _strokes = [];
  final Color _inkColor = AppColors.textPrimary;
  double _strokeWidth = 5;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildLetterGuide(),
        Expanded(child: _buildCanvas()),
        _buildToolbar(),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFC5A028), Color(0xFF9B7B1C)]),
      ),
      child: Column(children: [
        const Text('Écrire l\'arabe', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
        const SizedBox(height: 4),
        Text('Pratiquez l\'écriture manuscrite', style: const TextStyle(fontSize: 12, color: Color(0xFFFFF8E1))),
        const SizedBox(height: 14),
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: ArabicLetter.alphabet.length,
            separatorBuilder: (_, __) => const SizedBox(width: 4),
            itemBuilder: (context, i) {
              final l = ArabicLetter.alphabet[i];
              final sel = _current.letter == l.letter;
              return GestureDetector(
                onTap: () => setState(() { _current = l; _strokes.clear(); _points.clear(); }),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: sel ? Colors.white : Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(child: Text(l.letter, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: sel ? AppColors.primary : Colors.white))),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }

  Widget _buildLetterGuide() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: AppColors.surface,
      child: Row(children: [
        Text('Lettre : ${_current.name}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
        const Spacer(),
        SpeakButton(text: _current.letter, size: 20, color: AppColors.accent),
        const SizedBox(width: 10),
        Text('Prononcé : ${_current.transliteration}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      ]),
    );
  }

  Widget _buildCanvas() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.15)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12)],
      ),
      child: Stack(
        children: [
          // Guide letter (faded in background)
          Center(
            child: Opacity(
              opacity: 0.12,
              child: Text(_current.letter, style: TextStyle(fontSize: 180, fontWeight: FontWeight.w700, color: AppColors.primary)),
            ),
          ),
          // Drawing area
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: GestureDetector(
              onPanStart: (d) {
                setState(() { _points.add(d.localPosition); _points.clear(); _points.add(d.localPosition); });
              },
              onPanUpdate: (d) {
                setState(() { _points.add(d.localPosition); _strokes.last.add(d.localPosition); });
              },
              onPanEnd: (_) => setState(() { _strokes.add([]); }),
              onPanDown: (d) {
                setState(() { _strokes.add([]); _points.add(d.localPosition); });
              },
              child: CustomPaint(
                painter: _StrokePainter(_strokes, _inkColor, _strokeWidth),
                size: Size.infinite,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: AppColors.surface, border: const Border(top: BorderSide(color: Color(0xFFEBE5D7)))),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        _toolBtn(l10n.writingStrokeThin, Icons.circle_outlined, () => setState(() => _strokeWidth = 3)),
        _toolBtn(l10n.writingStrokeMedium, Icons.circle, () => setState(() => _strokeWidth = 5)),
        _toolBtn(l10n.writingStrokeThick, Icons.circle_rounded, () => setState(() => _strokeWidth = 8)),
        _toolBtn(l10n.writingClear, Icons.undo_rounded, () { if (_strokes.isNotEmpty) setState(() => _strokes.removeLast()); }),
        _toolBtn(l10n.writingClearAll, Icons.delete_outline_rounded, () => setState(() { _strokes.clear(); _points.clear(); })),
        _toolBtn(l10n.writingNextLetter, Icons.arrow_forward_rounded, () {
          setState(() {
            final idx = ArabicLetter.alphabet.indexOf(_current);
            _current = idx < ArabicLetter.alphabet.length - 1 ? ArabicLetter.alphabet[idx + 1] : ArabicLetter.alphabet[0];
            _strokes.clear(); _points.clear();
          });
        }),
      ]),
    );
  }

  Widget _toolBtn(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, size: 20, color: AppColors.primary)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
      ]),
    );
  }
}

class _StrokePainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final Color color;
  final double strokeWidth;
  _StrokePainter(this.strokes, this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      if (stroke.length < 2) continue;
      final paint = Paint()
        ..color = color
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      final path = Path();
      path.moveTo(stroke[0].dx, stroke[0].dy);
      for (int i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
