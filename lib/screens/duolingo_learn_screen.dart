import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/arabic_letter.dart';
import '../models/learning.dart';
import '../providers/learning_provider.dart';
import '../widgets/alphabet_grid.dart';
import '../widgets/celebration.dart';
import '../widgets/speak_button.dart';
import '../providers/vocabulary_provider.dart';
import '../providers/memorize_provider.dart';
import '../providers/chat_provider.dart';
import 'vocabulary_tab.dart';
import 'memorize_tab.dart';
import 'writing_tab.dart';

class DuolingoLearnScreen extends StatefulWidget {
  const DuolingoLearnScreen({super.key});
  @override
  State<DuolingoLearnScreen> createState() => _DuolingoLearnScreenState();
}

class _DuolingoLearnScreenState extends State<DuolingoLearnScreen> with SingleTickerProviderStateMixin {
  late final TabController _tab;
  bool _wasActive = false;
  String? _celebrationTitle;
  int _celebrationXp = 0;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 6, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<LearningProvider>().init());
  }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Consumer<LearningProvider>(
      builder: (context, lp, _) {
        if (lp.isLessonActive) {
          _wasActive = true;
          return _ExerciseScreen(lp: lp);
        }
        if (_wasActive && !lp.isLessonActive) {
          _wasActive = false;
          final lesson = lp.lessons.firstWhere((l) => l.id == lp.currentLessonId, orElse: () => lp.lessons[0]);
          if (lesson.completed) {
            _celebrationTitle = lesson.title;
            _celebrationXp = lesson.totalXp + 30;
          }
        }
        if (_celebrationTitle != null) {
          final t = _celebrationTitle!; final x = _celebrationXp;
          _celebrationTitle = null;
          return CelebrationScreen(
            lessonTitle: t,
            xpEarned: x,
            onContinue: () => setState(() {}),
            onAiRecap: () {
              context.read<ChatProvider>()
                ..setMode(ChatMode.general)
                ..sendMessage('Je viens de terminer la leçon "$t". Fais un résumé de ce que j\'ai appris, donne les 3 mots clés à retenir, et un conseil pour la suite.');
              setState(() {});
            },
          );
        }
        return _buildTabs();
      },
    );
  }

  List<Widget> _buildTabsWithBadges() {
    try {
      final vp = context.read<VocabularyProvider>();
      final mp = context.read<MemorizeProvider>();
      final words = vp.wordsToReview.length;
      final verses = mp.toReview.length;
      return [
        _tb('Parcours', Icons.map_rounded),
        _tb('Alphabet', Icons.text_fields_rounded),
        _tb('Mots', Icons.style_rounded, badge: words),
        _tb('Écrire', Icons.draw_rounded),
        _tb('Mém.', Icons.memory_rounded, badge: verses),
        _tb('365J', Icons.local_fire_department_rounded),
      ];
    } catch (_) {
      return [_tb('Parc.', Icons.map_rounded), _tb('Alph.', Icons.text_fields_rounded), _tb('Mots', Icons.style_rounded), _tb('Écrire', Icons.draw_rounded), _tb('Mém.', Icons.memory_rounded), _tb('365J', Icons.local_fire_department_rounded)];
    }
  }

  Tab _tb(String text, IconData icon, {int? badge}) {
    return Tab(
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 16),
        const SizedBox(width: 3),
        Text(text, style: const TextStyle(fontSize: 12)),
        if (badge != null && badge > 0) ...[
          const SizedBox(width: 3),
          Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1), decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(8)),
            child: Text('$badge', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800))),
        ],
      ]),
    );
  }

  Widget _buildTabs() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF1A1A1A), Color(0xFF2D2410)]),
            border: const Border(bottom: BorderSide(color: Color(0xFF3D3020), width: 0.5)),
          ),
          child: TabBar(
            controller: _tab, labelColor: AppColors.accent,
            unselectedLabelColor: Colors.white.withValues(alpha: 0.5),
            indicatorColor: AppColors.accent, indicatorWeight: 3,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            tabs: _buildTabsWithBadges(),
          ),
        ),
        Expanded(child: TabBarView(controller: _tab, children: [
          _PathScreen(),
          const _AlphabetTab(),
          const VocabularyTab(),
          const WritingTab(),
          const MemorizeTab(),
          const _DailyChallengeTab(),
        ])),
      ],
    );
  }
}

// ─── PATH SCREEN ────────────────────────────────────────────────

class _PathScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final lp = context.watch<LearningProvider>();
    return Column(children: [
      _XpBar(xp: lp.xp),
      Expanded(child: ListView(padding: const EdgeInsets.fromLTRB(8, 12, 8, 32), children: [
        for (int i = 0; i < lp.lessons.length; i++)
          _LessonRow(node: lp.lessons[i], index: i, lp: lp),
      ])),
    ]);
  }
}

class _XpBar extends StatelessWidget {
  final XpSystem xp;
  const _XpBar({required this.xp});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      decoration: BoxDecoration(color: AppColors.surface, border: const Border(bottom: BorderSide(color: Color(0xFFEBE5D7)))),
      child: Column(children: [
        Row(children: [
          Text('🇫🇷', style: const TextStyle(fontSize: 24)),
          const Spacer(),
          Row(children: List.generate(5, (i) => Icon(i < xp.lives ? Icons.favorite : Icons.favorite_border, size: 22, color: i < xp.lives ? AppColors.error : AppColors.textLight))),
          const Spacer(),
          Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFC5A028), Color(0xFFE8C547)]), borderRadius: BorderRadius.circular(20)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.local_fire_department, color: Colors.white, size: 16), const SizedBox(width: 4),
              Text('${xp.streak}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
            ]),
          ),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
            child: Text('Niv. ${xp.level}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: AppColors.accent))),
          const SizedBox(width: 10),
          Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(5), child: LinearProgressIndicator(value: xp.levelProgress, minHeight: 10, backgroundColor: AppColors.accent.withValues(alpha: 0.1), valueColor: const AlwaysStoppedAnimation(AppColors.accent)))),
          const SizedBox(width: 8),
          Text('${xp.currentXp % (xp.level * 100)}/${xp.level * 100} XP', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
        ]),
      ]),
    );
  }
}

class _LessonRow extends StatelessWidget {
  final LessonNode node; final int index; final LearningProvider lp;
  const _LessonRow({required this.node, required this.index, required this.lp});
  @override
  Widget build(BuildContext context) {
    final isRight = index % 2 == 0;
    final colors = [const Color(0xFFC5A028), const Color(0xFFE67E22), const Color(0xFF2980B9), const Color(0xFF27AE60), const Color(0xFF8E44AD), const Color(0xFFE74C3C), const Color(0xFF1ABC9C)];
    final color = colors[index % colors.length];
    return Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(children: [
      if (!isRight) const Spacer(),
      GestureDetector(
        onTap: node.unlocked ? () => lp.startLesson(node.id) : null,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 150),
          scale: node.unlocked ? 1.0 : 0.97,
          child: AnimatedContainer(duration: const Duration(milliseconds: 300),
            width: MediaQuery.of(context).size.width * 0.65, padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: node.unlocked ? AppColors.surface : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: node.completed ? AppColors.success.withValues(alpha: 0.3) : node.unlocked ? color.withValues(alpha: 0.3) : AppColors.cardBorder),
              boxShadow: node.unlocked
                  ? [BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 15, offset: const Offset(0, 4)), BoxShadow(color: color.withValues(alpha: 0.05), blurRadius: 5)]
                  : null,
            ),
            child: Row(children: [
            Container(width: 52, height: 52, decoration: BoxDecoration(
              color: node.completed ? AppColors.success.withValues(alpha: 0.1) : node.unlocked ? color.withValues(alpha: 0.1) : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: node.completed ? AppColors.success.withValues(alpha: 0.3) : node.unlocked ? color.withValues(alpha: 0.25) : Colors.grey.shade300)),
              child: Center(child: node.completed ? const Icon(Icons.check_rounded, color: AppColors.success, size: 26) : node.unlocked ? Icon(Icons.star_rounded, color: color, size: 26) : const Icon(Icons.lock_rounded, color: Colors.grey, size: 22))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(node.title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: node.unlocked ? AppColors.textPrimary : Colors.grey)),
              const SizedBox(height: 2),
              Text(node.description, style: TextStyle(fontSize: 11, color: node.unlocked ? AppColors.textSecondary : Colors.grey.shade400)),
              if (node.unlocked && !node.completed && node.progress > 0) ...[
                const SizedBox(height: 6),
                ClipRRect(borderRadius: BorderRadius.circular(3), child: LinearProgressIndicator(value: node.progress, minHeight: 3, backgroundColor: color.withValues(alpha: 0.1), valueColor: AlwaysStoppedAnimation(color))),
              ],
            ])),
            if (node.completed) ...[const SizedBox(width: 4), Text('+${node.totalXp}', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w800, fontSize: 12))],
          ]),
        ),
      )),
      if (isRight) const Spacer(),
    ]));
  }
}

// ─── EXERCISE SCREEN ────────────────────────────────────────────

class _ExerciseScreen extends StatefulWidget {
  final LearningProvider lp;
  const _ExerciseScreen({required this.lp});
  @override
  State<_ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<_ExerciseScreen> {
  final List<OverlayEntry> _popups = [];

  void _showXp(int xp) {
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => Positioned(
        top: MediaQuery.of(context).size.height * 0.22,
        left: MediaQuery.of(context).size.width * 0.3,
        right: MediaQuery.of(context).size.width * 0.3,
        child: XpPopup(xp: xp, onDone: () { entry.remove(); _popups.remove(entry); }),
      ),
    );
    _popups.add(entry);
    Overlay.of(context).insert(entry);
  }

  @override
  void dispose() { for (final e in _popups) { e.remove(); } super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final lp = widget.lp; final ex = lp.currentExercise;
    if (ex == null) return const SizedBox();
    return Column(children: [
      _ExerciseAppBar(lp: lp),
      Expanded(child: SafeArea(child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
        const SizedBox(height: 16),
        Text('Leçon : ${lp.lessons.firstWhere((l) => l.id == lp.currentLessonId, orElse: () => lp.lessons[0]).title}', style: const TextStyle(fontSize: 13, color: AppColors.textLight, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        LinearProgressIndicator(value: lp.currentExerciseIndex / lp.currentExercises.length, minHeight: 6, borderRadius: BorderRadius.circular(3), backgroundColor: AppColors.accent.withValues(alpha: 0.1), valueColor: const AlwaysStoppedAnimation(AppColors.accent)),
        const SizedBox(height: 32),
        Expanded(child: _buildExercise(ex, lp)),
        SizedBox(width: double.infinity, height: 100, child: Center(child: _buildChoices(ex, lp))),
        if (lp.wrongInRow >= 2) _buildAiHelp(lp),
        if (lp.correctInRow >= 4) _buildTooEasy(lp),
      ])))),
    ]);
  }

  Widget _buildTooEasy(LearningProvider lp) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.15)),
      ),
      child: Row(children: [
        const Icon(Icons.trending_up_rounded, size: 16, color: AppColors.success),
        const SizedBox(width: 8),
        const Expanded(child: Text('Tu progresses vite ! Essayer un niveau plus difficile ?', style: TextStyle(fontSize: 12, color: AppColors.textSecondary))),
        GestureDetector(
          onTap: () {
            context.read<ChatProvider>()
              ..setMode(ChatMode.general)
              ..sendMessage('Ces exercices sont trop faciles pour moi. Donne-moi des questions plus difficiles sur le même thème.');
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: AppColors.success, borderRadius: BorderRadius.circular(10)),
            child: const Text('Plus dur', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
          ),
        ),
      ]),
    );
  }

  Widget _buildAiHelp(LearningProvider lp) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Row(children: [
        const Icon(Icons.auto_awesome_rounded, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        const Expanded(child: Text('Besoin d\'aide ? L\'IA peut vous expliquer.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary))),
        GestureDetector(
          onTap: () {
            final ex = lp.currentExercise;
            if (ex != null) {
              final message = 'Explique-moi la réponse à cette question : "${ex.question}". La bonne réponse est "${ex.correctAnswer}". Explique pourquoi.';
              context.read<ChatProvider>().sendMessage(message);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
            child: const Text('Demander', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
          ),
        ),
      ]),
    );
  }

  Widget _buildExercise(Exercise ex, LearningProvider lp) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      if (ex.arabicText != null) ...[
        Container(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.accent.withValues(alpha: 0.15))),
          child: Column(children: [
            Text(ex.arabicText!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            SpeakButton(text: ex.arabicText!, size: 22, color: AppColors.accent),
          ])),
        const SizedBox(height: 20),
      ],
      Text(ex.question, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.4)),
      if (ex.type == ExerciseType.matchPair) ...[const SizedBox(height: 24), _MatchPairWidget(exercise: ex, lp: lp)],
    ]);
  }

  Widget _buildChoices(Exercise ex, LearningProvider lp) {
    if (ex.type == ExerciseType.matchPair) return const SizedBox();
    final options = ex.options ?? [];
    return StatefulBuilder(builder: (context, setLocalState) {
      String? picked; bool? isCorrect;
      return Wrap(spacing: 10, runSpacing: 10, alignment: WrapAlignment.center, children: options.map((o) {
        Color? bg; Color? border;
        if (isCorrect == true && o == ex.correctAnswer) { bg = AppColors.success.withValues(alpha: 0.1); border = AppColors.success; }
        else if (isCorrect == false && picked == o) { bg = AppColors.error.withValues(alpha: 0.1); border = AppColors.error; }
        else if (picked == o) { bg = AppColors.accent.withValues(alpha: 0.1); border = AppColors.accent; }
        return GestureDetector(
          onTap: isCorrect == true ? null : () {
            final correct = lp.submitAnswer(o);
            setLocalState(() { picked = o; isCorrect = correct; });
            if (correct) {
              WidgetsBinding.instance.addPostFrameCallback((_) => _showXp(ex.xpReward));
              Future.delayed(const Duration(milliseconds: 800), () { if (mounted) setLocalState(() { picked = null; isCorrect = null; }); });
            } else if (!lp.xp.hasLives) { _showNoLives(context, lp); }
          },
          child: Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), decoration: BoxDecoration(color: bg ?? AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: border ?? AppColors.cardBorder, width: border != null ? 2 : 1)),
            child: Text(o, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: border == AppColors.success ? AppColors.success : AppColors.textPrimary))),
        );
      }).toList());
    });
  }
}

void _showNoLives(BuildContext context, LearningProvider lp) {
  showDialog(context: context, builder: (ctx) => AlertDialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    title: const Row(children: [Icon(Icons.heart_broken, color: AppColors.error), SizedBox(width: 8), Text('Plus de vies')]),
    content: const Text('Vous avez perdu toutes vos vies. Revenez plus tard ou rechargez.'),
    actions: [
      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
      ElevatedButton(onPressed: () { Navigator.pop(ctx); lp.refillLives(); }, child: const Text('Recharger ❤️❤️❤️❤️❤️')),
    ],
  ));
}

class _ExerciseAppBar extends StatelessWidget {
  final LearningProvider lp;
  const _ExerciseAppBar({required this.lp});
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.fromLTRB(16, 12, 16, 10), decoration: BoxDecoration(color: AppColors.surface, border: const Border(bottom: BorderSide(color: Color(0xFFEBE5D7)))),
      child: Row(children: [
        GestureDetector(onTap: () => lp.exitLesson(), child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.close_rounded, size: 20, color: AppColors.error))),
        const SizedBox(width: 12),
        Expanded(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (i) => Padding(padding: const EdgeInsets.symmetric(horizontal: 2), child: Icon(i < lp.xp.lives ? Icons.favorite_rounded : Icons.favorite_border_rounded, size: 24, color: i < lp.xp.lives ? AppColors.error : AppColors.textLight))))),
        const SizedBox(width: 12),
        Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFC5A028), Color(0xFFE8C547)]), borderRadius: BorderRadius.circular(20)), child: Text('${lp.xp.currentXp} XP', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12))),
      ]),
    );
  }
}

// ─── MATCH PAIR WIDGET ──────────────────────────────────────────

class _MatchPairWidget extends StatefulWidget {
  final Exercise exercise; final LearningProvider lp;
  const _MatchPairWidget({required this.exercise, required this.lp});
  @override
  State<_MatchPairWidget> createState() => _MatchPairWidgetState();
}

class _MatchPairWidgetState extends State<_MatchPairWidget> {
  String? _sel; final Set<String> _done = {};
  @override
  Widget build(BuildContext context) {
    final p = widget.exercise.matchPairs ?? {}; final left = p.keys.toList(); final right = p.values.toList()..shuffle();
    if (_done.length == p.length) WidgetsBinding.instance.addPostFrameCallback((_) => widget.lp.advanceExercisePublic());
    return Row(children: [
      Expanded(child: Column(children: left.map((l) {
        final ci = left.indexOf(l); final c = HSLColor.fromAHSL(1, (ci * 60).toDouble(), 0.6, 0.5).toColor(); final done = _done.contains(l);
        return GestureDetector(onTap: done ? null : () => setState(() => _sel = l), child: Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), decoration: BoxDecoration(color: done ? c.withValues(alpha: 0.15) : _sel == l ? c.withValues(alpha: 0.1) : AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: done ? c : _sel == l ? c : AppColors.cardBorder, width: done ? 2 : 1)), child: Text(l, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: done ? c : AppColors.textPrimary))));
      }).toList())),
      const SizedBox(width: 8),
      Expanded(child: Column(children: right.map((r) {
        final ok = p.entries.firstWhere((e) => e.value == r).key; final done = _done.contains(ok); final ci = left.indexOf(ok); final c = HSLColor.fromAHSL(1, (ci * 60).toDouble(), 0.6, 0.5).toColor();
        return GestureDetector(onTap: done || _sel == null ? null : () => setState(() { if (p[_sel!] == r) { _done.add(_sel!); widget.lp.earnXp(5); } else { widget.lp.loseLife(); } _sel = null; }), child: Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), decoration: BoxDecoration(color: done ? c.withValues(alpha: 0.15) : AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: done ? c : AppColors.cardBorder, width: done ? 2 : 1)), child: Text(r, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: done ? c : AppColors.textSecondary))));
      }).toList())),
    ]);
  }
}

// ─── ALPHABET TAB ───────────────────────────────────────────────

class _AlphabetTab extends StatefulWidget {
  const _AlphabetTab();
  @override
  State<_AlphabetTab> createState() => _AlphabetTabState();
}

class _AlphabetTabState extends State<_AlphabetTab> {
  ArabicLetter? _sel;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(children: [
        Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFC5A028), Color(0xFF9B7B1C)]), borderRadius: BorderRadius.circular(22)),
          child: const Column(children: [
            Icon(Icons.text_fields_rounded, color: Colors.white, size: 26), SizedBox(height: 8),
            Text('Alphabet arabe', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
            Text('Touchez une lettre pour ses détails', style: TextStyle(fontSize: 12, color: Color(0xFFFFF8E1))),
          ]),
        ),
        const SizedBox(height: 16),
        AlphabetGrid(onLetterTap: (l) => setState(() => _sel = l)),
        if (_sel != null) ...[const SizedBox(height: 16), _LetterCard(_sel!)],
      ]),
    );
  }
}

class _LetterCard extends StatelessWidget {
  final ArabicLetter letter;
  const _LetterCard(this.letter);
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(22), border: Border.all(color: AppColors.accent.withValues(alpha: 0.2))),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(width: 80, height: 80, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFFF8E1), Color(0xFFF5E6B8)]), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.accent.withValues(alpha: 0.25))),
            child: Center(child: Text(letter.letter, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w700, color: AppColors.textPrimary)))),
          const SizedBox(width: 18),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(letter.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Text('Prononcé : ${letter.transliteration}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.accent))),
          ])),
        ]),
        const SizedBox(height: 18),
        Row(children: [
          _form('Isolée', letter.isolated), Container(width: 1, height: 40, color: const Color(0xFFEBE5D7)),
          _form('Début', letter.initial), Container(width: 1, height: 40, color: const Color(0xFFEBE5D7)),
          _form('Milieu', letter.medial), Container(width: 1, height: 40, color: const Color(0xFFEBE5D7)),
          _form('Fin', letter.final_),
        ]),
      ]),
    );
  }
  Widget _form(String label, String form) => Expanded(child: Column(children: [
    Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textLight)),
    const SizedBox(height: 4),
    Text(form, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
  ]));
}

// ─── DAILY CHALLENGE TAB ────────────────────────────────────────

class _DailyChallengeTab extends StatelessWidget {
  const _DailyChallengeTab();
  @override
  Widget build(BuildContext context) {
    final lp = context.watch<LearningProvider>();
    final xp = lp.xp;
    return ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 32), children: [
      Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF1A1A1A), Color(0xFF2D2410)]), borderRadius: BorderRadius.circular(22)),
        child: Column(children: [
          Container(width: 70, height: 70, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFC5A028), Color(0xFFE8C547)]), shape: BoxShape.circle, boxShadow: [BoxShadow(color: const Color(0xFFC5A028).withValues(alpha: 0.3), blurRadius: 20)]),
            child: const Icon(Icons.local_fire_department_rounded, size: 36, color: Colors.white)),
          const SizedBox(height: 12),
          Text('${xp.streak} jours', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.accent)),
          const Text('de streak !', style: TextStyle(fontSize: 14, color: Colors.white70)),
        ]),
      ),
      const SizedBox(height: 20),
      _quest('Terminer 1 leçon', Icons.school_rounded, 20, lp.completedLessonsToday >= 1),
      _quest('Gagner 50 XP', Icons.star_rounded, 30, lp.xp.totalXp >= 50),
          _quest('Poser une question au Chat', Icons.chat_bubble_rounded, 15, false),
          _quest('Apprendre 5 nouvelles lettres', Icons.text_fields_rounded, 25, false),
      const SizedBox(height: 16),
      _weekStreak(xp),
      const SizedBox(height: 16),
      _ayahOfDay(),
      const SizedBox(height: 16),
      _aiDailyTip(context),
      const SizedBox(height: 16),
      _wordOfDayAi(context),
      const SizedBox(height: 16),
      _dailyMission(context),
    ]);
  }

  Widget _quest(String title, IconData icon, int xp, bool done) => Container(
    margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: done ? AppColors.success.withValues(alpha: 0.06) : AppColors.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: done ? AppColors.success.withValues(alpha: 0.2) : AppColors.cardBorder)),
    child: Row(children: [
      Container(width: 44, height: 44, decoration: BoxDecoration(color: done ? AppColors.success.withValues(alpha: 0.12) : AppColors.primarySurface, borderRadius: BorderRadius.circular(14)),
        child: Icon(icon, size: 20, color: done ? AppColors.success : AppColors.textLight)),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: done ? AppColors.success : AppColors.textPrimary, decoration: done ? TextDecoration.lineThrough : null)),
        const SizedBox(height: 2),
        Text('+$xp XP', style: TextStyle(fontSize: 12, color: done ? AppColors.success : AppColors.accent, fontWeight: FontWeight.w600)),
      ])),
      if (done) const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 24),
    ]),
  );

  Widget _weekStreak(XpSystem xp) {
    final days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    final today = DateTime.now().weekday - 1;
    return Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.cardBorder)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Cette semaine', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 14),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: List.generate(7, (i) {
          final active = i < (xp.streak - 1).clamp(0, 6) || (xp.streak > 0 && i <= today);
          return Column(children: [
            Container(width: 32, height: 32, decoration: BoxDecoration(color: active ? AppColors.accent : AppColors.background, shape: BoxShape.circle, border: Border.all(color: active ? AppColors.accent : AppColors.cardBorder)),
              child: Center(child: active ? const Icon(Icons.check, size: 16, color: Colors.white) : Text(days[i], style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textLight)))),
          ]);
        })),
      ]),
    );
  }

  Widget _ayahOfDay() {
    final verses = [
      {'ar': 'إِنَّ مَعَ الْعُسْرِ يُسْرًا', 'fr': '"A côté de la difficulté est, certes, une facilité."', 'ref': 'Ash-Sharh 94:6'},
      {'ar': 'فَاذْكُرُونِي أَذْكُرْكُمْ', 'fr': '"Souvenez-vous de Moi, Je Me souviendrai de vous."', 'ref': 'Al-Baqara 2:152'},
      {'ar': 'وَمَن يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ', 'fr': '"Quiconque place sa confiance en Allah, Il lui suffit."', 'ref': 'At-Talaq 65:3'},
      {'ar': 'إِنَّ اللَّهَ مَعَ الصَّابِرِينَ', 'fr': '"Certes, Allah est avec les patients."', 'ref': 'Al-Baqara 2:153'},
      {'ar': 'وَإِن تَعُدُّوا نِعْمَةَ اللَّهِ لَا تُحْصُوهَا', 'fr': '"Si vous comptez les bienfaits d\'Allah, vous ne pourrez les dénombrer."', 'ref': 'Ibrahim 14:34'},
      {'ar': 'وَقُل رَّبِّ زِدْنِي عِلْمًا', 'fr': '"Et dis : Ô mon Seigneur, accrois mon savoir !"', 'ref': 'Ta-Ha 20:114'},
      {'ar': 'ادْعُونِي أَسْتَجِبْ لَكُمْ', 'fr': '"Invoquez-Moi, Je vous exaucerai."', 'ref': 'Ghafir 40:60'},
    ];
    final today = DateTime.now().day % verses.length;
    final v = verses[today];

    return Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFFF8E1), Color(0xFFFAF8F3)]), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.accent.withValues(alpha: 0.2))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [const Icon(Icons.auto_stories_rounded, color: AppColors.accent, size: 20), const SizedBox(width: 8), const Text('Verset du jour', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary))]),
        const SizedBox(height: 12),
        Text(v['ar']!, textDirection: TextDirection.rtl, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        Text(v['fr']!, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontStyle: FontStyle.italic)),
        const SizedBox(height: 4),
        Text('Sourate ${v['ref']!}', style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
      ]),
    );
  }

  Widget _aiDailyTip(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF0F1B4C), Color(0xFF1E3A8A)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.auto_awesome_rounded, size: 18, color: AppColors.accent)),
          const SizedBox(width: 10),
          const Text('Conseil IA du jour', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
        ]),
        const SizedBox(height: 12),
        Text(_getDailyTip(), style: const TextStyle(fontSize: 13, color: Colors.white70, height: 1.5)),
        const SizedBox(height: 12),
        SizedBox(width: double.infinity, height: 40, child: OutlinedButton.icon(
          onPressed: () {
            final lp = context.read<LearningProvider>();
            context.read<ChatProvider>()..setMode(ChatMode.general)..sendMessage('Donne-moi un conseil personnalisé pour aujourd\'hui. Mon niveau: ${lp.xp.level}, ${lp.xp.currentXp} XP, ${lp.xp.streak}j de streak.');
          },
          icon: const Icon(Icons.auto_awesome_rounded, size: 14),
          label: const Text('Conseil personnalisé', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          style: OutlinedButton.styleFrom(foregroundColor: AppColors.accent, side: BorderSide(color: AppColors.accent.withValues(alpha: 0.3)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        )),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () {
            context.read<ChatProvider>()..setMode(ChatMode.general)
              ..sendMessage('Donne-moi un conseil court et motivant pour apprendre le Coran et l\'arabe aujourd\'hui. Maximum 2 phrases, inspirant.');
          },
          child: Text('🔄 Régénérer avec l\'IA', style: TextStyle(fontSize: 11, color: AppColors.accent.withValues(alpha: 0.6), fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }

  String _getDailyTip() {
    final tips = [
      'Révisez 5 mots avant de dormir, la mémorisation est plus efficace pendant le sommeil.',
      'Lisez un verset à voix haute 3 fois : pour les yeux, la langue et le cœur.',
      'Apprenez une lettre arabe par jour. Dans 28 jours, tout l\'alphabet !',
      'La constance vaut mieux que la quantité. 5 min/jour > 1h/semaine.',
      'Écoutez une récitation avant votre leçon, cela prépare l\'oreille.',
      'Notez les nouveaux mots et essayez de les utiliser.',
      'Chaque verset mémorisé est une lumière dans votre cœur.',
    ];
    return tips[DateTime.now().day % tips.length];
  }

  Widget _wordOfDayAi(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.15)),
      ),
      child: Column(children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.auto_awesome_rounded, size: 18, color: AppColors.accent)),
          const SizedBox(width: 10),
          const Text('Mot du jour IA', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          const Spacer(),
          GestureDetector(
            onTap: () {
              context.read<ChatProvider>()..setMode(ChatMode.arabic)
                ..sendMessage('Donne-moi un mot arabe du Coran à apprendre aujourd\'hui, adapté à un niveau débutant/intermédiaire. Donne le mot en arabe, sa translittération, sa traduction, sa racine, et un verset qui le contient. Appuie-toi sur les références vérifiées mises à ta disposition.');
            },
            child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
              child: const Text('Générer', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))),
          ),
        ]),
        const SizedBox(height: 10),
        const Text('Appuyez sur Générer pour recevoir un mot arabe coranique adapté à votre niveau.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4)),
      ]),
    );
  }

  Widget _dailyMission(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFE67E22), Color(0xFFD35400)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.rocket_launch_rounded, size: 18, color: Colors.white)),
          const SizedBox(width: 10),
          const Expanded(child: Text('Mission du jour IA', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white))),
          GestureDetector(
            onTap: () {
              context.read<ChatProvider>()..setMode(ChatMode.general)
                ..sendMessage('Crée une mission du jour personnalisée. Une tâche concrète liée au Coran ou à l\'arabe. 2 phrases max.');
            },
            child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
              child: const Text('Générer', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))),
          ),
        ]),
        const SizedBox(height: 10),
        const Text('L\'IA vous propose un défi personnalisé du jour.',
            style: TextStyle(fontSize: 12, color: Colors.white70, height: 1.4)),
      ]),
    );
  }
}
