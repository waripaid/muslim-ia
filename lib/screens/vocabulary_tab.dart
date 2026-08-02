import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../l10n/app_localizations.dart';
import '../providers/chat_provider.dart';
import '../providers/vocabulary_provider.dart';
import '../widgets/speak_button.dart';

class VocabularyTab extends StatefulWidget {
  const VocabularyTab({super.key});
  @override
  State<VocabularyTab> createState() => _VocabularyTabState();
}

class _VocabularyTabState extends State<VocabularyTab> with SingleTickerProviderStateMixin {
  bool _flashcardMode = false;
  int _cardIndex = 0;
  bool _showBack = false;
  late final AnimationController _flip;
  late final Animation<double> _flipAnim;

  @override
  void initState() {
    super.initState();
    _flip = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _flipAnim = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _flip, curve: Curves.easeInOut));
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<VocabularyProvider>().init());
  }

  @override
  void dispose() { _flip.dispose(); super.dispose(); }

  void _nextCard() {
    setState(() { _showBack = false; _flip.reset(); _cardIndex++; });
  }

  @override
  Widget build(BuildContext context) {
    final vp = context.watch<VocabularyProvider>();
    final words = vp.words;

    if (_flashcardMode && words.isNotEmpty) {
      if (_cardIndex >= words.length) _cardIndex = 0;
      return _buildFlashcard(words[_cardIndex], vp);
    }

    return _buildList(words, vp);
  }

  Widget _buildFlashcard(VocabWord word, VocabularyProvider vp) {
    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          // Header with close button
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            color: AppColors.surface,
            child: Row(children: [
              GestureDetector(onTap: () => setState(() => _flashcardMode = false), child: Container(
                padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.close_rounded, size: 20, color: AppColors.error))),
              const Spacer(),
              Text('${_cardIndex + 1}/${vp.words.length}', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const Spacer(),
              Text('Niv. ${word.level + 1}/4', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.accent)),
            ]),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: GestureDetector(
                onTap: () { if (!_showBack) { _flip.forward(); setState(() => _showBack = true); } },
                child: AnimatedBuilder(
                  animation: _flipAnim,
                  builder: (context, child) {
                    final isFront = _flipAnim.value < 0.5;
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(_flipAnim.value * pi),
                      child: isFront ? _cardFront(word) : Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..rotateY(pi),
                        child: _cardBack(word, vp),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardFront(VocabWord word) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF0A0E2E), Color(0xFF152461)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: const Color(0xFF0A0E2E).withValues(alpha: 0.3), blurRadius: 20)],
      ),
      child: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
            child: Text(AppLocalizations.of(context).memorizeTouchReveal, style: const TextStyle(color: Colors.white60, fontSize: 12)),          ),
          const SizedBox(height: 32),
          Text(word.arabic, style: const TextStyle(fontSize: 52, fontWeight: FontWeight.w700, color: AppColors.accent)),
          const SizedBox(height: 8),
          SpeakButton(text: word.arabic, size: 30, color: Colors.white70),
          const SizedBox(height: 12),
          Text(word.transliteration, style: const TextStyle(fontSize: 18, color: Colors.white70)),
        ]),
      ),
    );
  }

  Widget _cardBack(VocabWord word, VocabularyProvider vp) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(word.french, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(word.arabic, style: const TextStyle(fontSize: 20, color: AppColors.accent, fontWeight: FontWeight.w600)),
          const SizedBox(width: 10),
          SpeakButton(text: word.arabic, size: 18),
        ]),
        if (word.root != null) ...[
          const SizedBox(height: 16),
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(12)),
            child: Text('Racine : ${word.root}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary))),
        ],
        if (word.type != null) ...[
          const SizedBox(height: 6),
          Text('Type : ${word.type}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        ],
        if (word.example != null) ...[
          const SizedBox(height: 12),
          Text('📖 ${word.example}', style: const TextStyle(fontSize: 12, color: AppColors.textLight, fontStyle: FontStyle.italic)),
        ],
        const Spacer(),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _actionBtn(AppLocalizations.of(context).memorizeAgain, Icons.replay_rounded, AppColors.error, () { vp.markWrong(word); _nextCard(); }),
          _actionBtn(AppLocalizations.of(context).memorizeEasy, Icons.check_rounded, AppColors.success, () { vp.markCorrect(word); _nextCard(); }),
        ]),
      ]),
    );
  }

  Widget _actionBtn(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withValues(alpha: 0.3))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 18, color: color), const SizedBox(width: 6),
          Text(label, style: TextStyle(fontWeight: FontWeight.w700, color: color, fontSize: 14)),
        ]),
      ),
    );
  }

  Widget _buildList(List<VocabWord> words, VocabularyProvider vp) {
    final reviewCount = vp.wordsToReview.length;
    return Column(children: [
      // Stats bar
      Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFC5A028), Color(0xFF9B7B1C)]),
        ),
        child: Column(children: [
          const Text('Mon Vocabulaire', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 4),
          Text('${words.length} mots · ${vp.mastered.length} maîtrisés · $reviewCount à réviser',
              style: const TextStyle(fontSize: 12, color: Color(0xFFFFF8E1))),
          const SizedBox(height: 12),
          if (reviewCount > 0)
            SizedBox(width: double.infinity, height: 44, child: ElevatedButton.icon(
              onPressed: () => setState(() { _flashcardMode = true; _cardIndex = 0; _showBack = false; }),
              icon: const Icon(Icons.style_rounded, size: 18),
              label: Text('Réviser $reviewCount mots', style: const TextStyle(fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            )),
          const SizedBox(height: 8),
          SizedBox(width: double.infinity, height: 38, child: OutlinedButton.icon(
            onPressed: () {
              context.read<ChatProvider>()
                ..setMode(ChatMode.arabic)
                ..sendMessage('Voici les mots arabes que j\'apprends : ${vp.words.map((w) => '${w.arabic} (${w.french}, racine: ${w.root ?? "?"})').join(", ")}. Regroupe-les par racine et explique les liens de sens entre les mots de même racine.');
            },
            icon: const Icon(Icons.account_tree_rounded, size: 14),
            label: const Text('Familles de racines IA', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary, side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          )),
        ]),
      ),
      Expanded(
        child: words.isEmpty
            ? const Center(child: Text('Aucun mot pour le moment', style: TextStyle(color: AppColors.textSecondary)))
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 32),
                itemCount: words.length,
                itemBuilder: (context, i) {
                  final w = words[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.cardBorder)),
                    child: Row(children: [
                      Container(width: 48, height: 48, decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [AppColors.primarySurface, AppColors.accentLight]), borderRadius: BorderRadius.circular(14)),
                        child: Center(child: Text(w.arabic, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)))),
                      const SizedBox(width: 14),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(w.french, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(w.transliteration, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
                      ])),
                      SpeakButton(text: w.arabic, size: 20, color: AppColors.accent),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          context.read<ChatProvider>().sendMessage(
                            'Analyse le mot arabe "${w.arabic}" (${w.transliteration}). Donne sa racine (3 lettres), son type grammatical, son sens détaillé, et cite un verset du Coran qui contient ce mot. Appuie-toi sur les références vérifiées mises à ta disposition.',
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.auto_awesome_rounded, size: 16, color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _levelBadge(w),
                    ]),
                  );
                },
              ),
      ),
    ]);
  }

  Widget _levelBadge(VocabWord w) {
    final labels = ['Nouveau', 'Appris', 'Révisé', 'Maîtrisé'];
    final colors = [AppColors.textLight, AppColors.warning, AppColors.primary, AppColors.success];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: colors[w.level].withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
      child: Text(labels[w.level], style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: colors[w.level])),
    );
  }
}
