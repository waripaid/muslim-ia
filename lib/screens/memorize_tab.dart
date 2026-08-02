import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../l10n/app_localizations.dart';
import '../providers/memorize_provider.dart';
import '../providers/learning_provider.dart';
import '../widgets/speak_button.dart';

class MemorizeTab extends StatefulWidget {
  const MemorizeTab({super.key});
  @override
  State<MemorizeTab> createState() => _MemorizeTabState();
}

class _MemorizeTabState extends State<MemorizeTab> {
  bool _reviewMode = false;
  int _verseIndex = 0;
  bool _showArabic = true;
  bool _showTranslation = false;

  String get _lang => Localizations.localeOf(context).languageCode;

  @override
  Widget build(BuildContext context) {
    final mp = context.watch<MemorizeProvider>();
    final verses = _reviewMode ? mp.toReview : mp.verses;
    final memorized = mp.memorized.length;

    if (_reviewMode && verses.isNotEmpty && _verseIndex < verses.length) {
      return _buildReviewCard(verses[_verseIndex], mp);
    }

    return _buildList(mp, memorized);
  }

  Widget _buildList(MemorizeProvider mp, int memorized) {
    return Column(children: [
      Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF1A1A1A), Color(0xFF2D2410)])),
        child: Column(children: [
          const Text('Mémorisation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.accent)),
          const SizedBox(height: 4),
          Text('${mp.verses.length} versets · $memorized mémorisés · ${mp.toReview.length} à réviser',
              style: const TextStyle(fontSize: 12, color: Colors.white60)),
          const SizedBox(height: 12),
          if (mp.toReview.isNotEmpty)
            SizedBox(width: double.infinity, height: 44, child: ElevatedButton.icon(
              onPressed: () => setState(() { _reviewMode = true; _verseIndex = 0; _showArabic = true; _showTranslation = false; }),
              icon: const Icon(Icons.replay_rounded, size: 18),
              label: Text('Réviser ${mp.toReview.length} versets', style: const TextStyle(fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            )),
        ]),
      ),
      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 32),
          itemCount: mp.verses.length,
          itemBuilder: (context, i) {
            final v = mp.verses[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.cardBorder)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
                    child: Text('${v.sourateName} ${v.reference}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.primary))),
                  const Spacer(),
                  SpeakButton(text: v.arabic, size: 18, color: AppColors.accent),
                  const SizedBox(width: 6),
                  _levelBadge(v.level),
                ]),
                const SizedBox(height: 10),
                Text(v.arabic, textDirection: TextDirection.rtl, textAlign: TextAlign.right, maxLines: 3, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, height: 1.6, color: AppColors.textPrimary)),
                if (v.translation.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(v.translationFor(_lang), maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontStyle: FontStyle.italic)),
                ],
              ]),
            );
          },
        ),
      ),
    ]);
  }

  Widget _buildReviewCard(MemorizeVerse verse, MemorizeProvider mp) {
    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            color: AppColors.surface,
            child: Row(children: [
              GestureDetector(onTap: () => setState(() => _reviewMode = false), child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.close_rounded, size: 20, color: AppColors.error))),
              const Spacer(),
              Text('${_verseIndex + 1}/${mp.toReview.length}', style: const TextStyle(fontWeight: FontWeight.w700)),
              const Spacer(),
              Text('Niv. ${verse.level + 1}/5', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.accent)),
            ]),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('${verse.sourateName} ${verse.reference}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  const SizedBox(width: 10),
                  SpeakButton(text: verse.arabic, size: 20, color: AppColors.accent),
                ]),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => setState(() => _showArabic = !_showArabic),
                  child: AnimatedCrossFade(firstChild: Text(verse.arabic,
                      textDirection: TextDirection.rtl, textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 22, height: 1.8, color: AppColors.textPrimary)),
                    secondChild: Container(height: 80, decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(14)), child: const Center(child: Text('Toucher pour révéler', style: TextStyle(color: AppColors.textLight)))),
                    crossFadeState: _showArabic ? CrossFadeState.showFirst : CrossFadeState.showSecond, duration: const Duration(milliseconds: 300)),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => setState(() => _showTranslation = !_showTranslation),
                  child: AnimatedCrossFade(firstChild: Text(verse.translationFor(_lang),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 15, color: AppColors.textSecondary, fontStyle: FontStyle.italic, height: 1.5)),
                    secondChild: Container(height: 60, decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(14)), child: Center(child: Text(AppLocalizations.of(context).memorizeTouchTranslation, style: const TextStyle(color: AppColors.textLight)))),
                    crossFadeState: _showTranslation ? CrossFadeState.showFirst : CrossFadeState.showSecond, duration: const Duration(milliseconds: 300)),
                ),
                const Spacer(),
                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                  _actionBtn(AppLocalizations.of(context).memorizeHard, Icons.replay_rounded, AppColors.error, () { mp.markWrong(verse); _nextVerse(mp); }),
                  _actionBtn(AppLocalizations.of(context).memorizeEasy, Icons.check_rounded, AppColors.success, () { mp.markCorrect(verse); _nextVerse(mp); context.read<LearningProvider>().earnXp(10); }),
                ]),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _nextVerse(MemorizeProvider mp) {
    final verses = mp.toReview;
    if (_verseIndex < verses.length - 1) {
      setState(() { _verseIndex++; _showArabic = true; _showTranslation = false; });
    } else {
      setState(() => _reviewMode = false);
    }
  }

  Widget _actionBtn(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withValues(alpha: 0.3))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 18, color: color), const SizedBox(width: 6), Text(label, style: TextStyle(fontWeight: FontWeight.w700, color: color, fontSize: 14))])),
    );
  }

  Widget _levelBadge(int level) {
    final labels = ['Nouveau', 'Appris', 'Révisé', 'Avancé', 'Maîtrisé'];
    final colors = [AppColors.textLight, AppColors.warning, AppColors.primary, Color(0xFF8E44AD), AppColors.success];
    return Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: colors[level].withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(labels[level], style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: colors[level])));
  }
}
