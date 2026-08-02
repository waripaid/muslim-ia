import 'package:flutter/material.dart';
import '../config/theme.dart';

class QuizCard extends StatefulWidget {
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String explanation;
  final VoidCallback? onComplete;

  const QuizCard({
    super.key, required this.question, required this.options,
    required this.correctAnswer, required this.explanation, this.onComplete,
  });

  @override
  State<QuizCard> createState() => _QuizCardState();
}

class _QuizCardState extends State<QuizCard> with SingleTickerProviderStateMixin {
  String? _sel;
  bool _answered = false;
  late final AnimationController _a;

  @override
  void initState() { super.initState(); _a = AnimationController(vsync: this, duration: const Duration(milliseconds: 400)); }
  @override
  void dispose() { _a.dispose(); super.dispose(); }

  void _answer() {
    if (_sel == null) return;
    setState(() => _answered = true);
    _a.forward();
    widget.onComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.quiz_rounded, color: AppColors.accent, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Quiz', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          ]),
          const SizedBox(height: 18),
          Text(widget.question, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.4)),
          const SizedBox(height: 18),
          ...widget.options.map((o) {
            final sel = _sel == o;
            final corr = o == widget.correctAnswer;
            Color? bg, border;
            if (_answered && corr) { bg = AppColors.success.withValues(alpha: 0.06); border = AppColors.success.withValues(alpha: 0.25); }
            else if (_answered && sel && !corr) { bg = AppColors.error.withValues(alpha: 0.06); border = AppColors.error.withValues(alpha: 0.25); }
            else if (sel && !_answered) { bg = AppColors.accent.withValues(alpha: 0.06); border = AppColors.accent.withValues(alpha: 0.25); }

            return GestureDetector(
              onTap: _answered ? null : () => setState(() => _sel = o),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: bg ?? AppColors.background,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: border ?? const Color(0xFFEBE5D7)),
                ),
                child: Row(children: [
                  Icon(
                    _answered && corr ? Icons.check_circle_rounded : _answered && sel && !corr ? Icons.cancel_rounded : sel ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
                    size: 20,
                    color: _answered && corr ? AppColors.success : _answered && sel && !corr ? AppColors.error : AppColors.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(o, style: const TextStyle(fontSize: 14.5, color: AppColors.textPrimary))),
                ]),
              ),
            );
          }),
          if (_answered) ...[
            const SizedBox(height: 14),
            SizeTransition(
              sizeFactor: CurvedAnimation(parent: _a, curve: Curves.easeOutCubic),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _sel == widget.correctAnswer
                      ? AppColors.success.withValues(alpha: 0.04)
                      : AppColors.warning.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _sel == widget.correctAnswer ? AppColors.success.withValues(alpha: 0.15) : AppColors.warning.withValues(alpha: 0.15),
                  ),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_sel == widget.correctAnswer ? 'Bravo !' : 'Pas tout à fait...',
                      style: TextStyle(fontWeight: FontWeight.w700, color: _sel == widget.correctAnswer ? AppColors.success : AppColors.warning)),
                  const SizedBox(height: 6),
                  Text(widget.explanation, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4)),
                ]),
              ),
            ),
          ] else ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity, height: 48,
              child: ElevatedButton(
                onPressed: _sel != null ? _answer : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Valider', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
