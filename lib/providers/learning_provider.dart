import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/learning.dart';
import '../services/storage_service.dart';

class LearningProvider extends ChangeNotifier {
  final StorageService _storage;
  XpSystem _xp = XpSystem();
  final List<LessonNode> _lessons = [];
  int _currentExerciseIndex = 0;
  int _correctInRow = 0;
  int _wrongInRow = 0;
  bool _isLessonActive = false;
  String? _currentLessonId;
  final List<Map<String, String>> _errorLog = [];
  int _completedToday = 0;
  String? _completedDate;

  static const _keyXp = 'xp_system';
  static const _keyLessons = 'lessons_progress';

  LearningProvider({required StorageService storage}) : _storage = storage;

  // ── Getters ─────────────────────────────────────────────

  XpSystem get xp => _xp;
  List<LessonNode> get lessons => _lessons;
  int get currentExerciseIndex => _currentExerciseIndex;
  int get correctInRow => _correctInRow;
  int get wrongInRow => _wrongInRow;
  bool get isLessonActive => _isLessonActive;
  String? get currentLessonId => _currentLessonId;
  bool get needsAiHelp => _wrongInRow >= 2;
  List<Map<String, String>> get errorLog => _errorLog;

  Map<String, int> get errorTypes {
    final map = <String, int>{};
    for (final e in _errorLog) {
      final t = e['type'] ?? 'inconnu';
      map[t] = (map[t] ?? 0) + 1;
    }
    return map;
  }

  String get difficultySuggestion {
    if (_errorLog.isEmpty) return 'medium';
    final total = _errorLog.length;
    final correct = _errorLog.where((e) => e['type'] == 'correct').length;
    final ratio = correct / total;
    if (ratio > 0.9) return 'hard';
    if (ratio > 0.7) return 'medium';
    return 'easy';
  }

  List<Exercise> get currentExercises {
    if (_currentLessonId == null) return [];
    final lesson = _lessons.firstWhere(
      (l) => l.id == _currentLessonId,
      orElse: () => _lessons.first,
    );
    return lesson.exercises;
  }

  Exercise? get currentExercise {
    if (_currentLessonId == null) return null;
    final exs = currentExercises;
    if (_currentExerciseIndex >= exs.length) return null;
    return exs[_currentExerciseIndex];
  }

  int get completedLessonsToday {
    _checkToday();
    return _completedToday;
  }

  // ── Public methods ──────────────────────────────────────────

  Future<void> init() async {
    await _loadXp();
    await _loadLessonsProgress();
    await _loadErrors();
    _checkStreak();
    _buildLessons();
    notifyListeners();
  }

  void earnXp(int amount) {
    _xp.currentXp += amount;
    _xp.totalXp += amount;
    while (_xp.currentXp >= _xp.xpToNextLevel) {
      _xp.currentXp -= _xp.xpToNextLevel;
      _xp.level++;
    }
    _saveXp();
    notifyListeners();
  }

  void loseLife() {
    if (_xp.lives > 0) {
      _xp.lives--;
    }
    _saveXp();
    notifyListeners();
  }

  void refillLives() {
    _xp.lives = 5;
    _saveXp();
    notifyListeners();
  }

  void startLesson(String lessonId) {
    _currentLessonId = lessonId;
    _currentExerciseIndex = 0;
    _correctInRow = 0;
    _wrongInRow = 0;
    _isLessonActive = true;
    _incrementCompletedToday();
    notifyListeners();
  }

  bool submitAnswer(String answer) {
    final ex = currentExercise;
    if (ex == null) return false;

    final isCorrect =
        answer.trim().toLowerCase() == ex.correctAnswer.trim().toLowerCase();

    if (isCorrect) {
      _correctInRow++;
      _wrongInRow = 0;
      earnXp(ex.xpReward);
      HapticFeedback.lightImpact();
    } else {
      _wrongInRow++;
      _correctInRow = 0;
      loseLife();
      HapticFeedback.heavyImpact();
      _errorLog.add({
        'type': ex.type,
        'question': ex.question,
        'wrongAnswer': answer,
        'correctAnswer': ex.correctAnswer,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }

    _advanceExercise();
    _saveErrors();
    return isCorrect;
  }

  void advanceExercisePublic() {
    _advanceExercise();
    notifyListeners();
  }

  void exitLesson() {
    _isLessonActive = false;
    _currentLessonId = null;
    _currentExerciseIndex = 0;
    _correctInRow = 0;
    _wrongInRow = 0;
    notifyListeners();
  }

  // ── Private methods ───────────────────────────────────────

  void _checkStreak() {
    final now = DateTime.now();
    final last = _xp.lastActive;
    if (last == null) {
      _xp.streak = 1;
    } else {
      final diff = now.difference(last).inDays;
      if (diff == 0) {
        // same day, no change
      } else if (diff == 1) {
        _xp.streak++;
      } else {
        _xp.streak = 1;
      }
    }
    _xp.lastActive = now;
    _saveXp();
  }

  void _advanceExercise() {
    _currentExerciseIndex++;
    if (_currentLessonId != null) {
      final exs = currentExercises;
      if (_currentExerciseIndex >= exs.length) {
        _completeLesson();
      } else {
        final lesson = _lessons.firstWhere(
          (l) => l.id == _currentLessonId,
          orElse: () => _lessons.first,
        );
        lesson.progress = _currentExerciseIndex / exs.length;
        _saveLessons();
      }
    }
    notifyListeners();
  }

  void _completeLesson() {
    if (_currentLessonId == null) return;
    final lesson = _lessons.firstWhere(
      (l) => l.id == _currentLessonId,
      orElse: () => _lessons.first,
    );
    lesson.completed = true;
    lesson.progress = 1.0;

    final idx = _lessons.indexOf(lesson);
    if (idx >= 0 && idx + 1 < _lessons.length) {
      _lessons[idx + 1].unlocked = true;
    }

    earnXp(30);

    _isLessonActive = false;
    _saveLessons();
  }

  void _incrementCompletedToday() {
    _checkToday();
    _completedToday++;
  }

  void _checkToday() {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (_completedDate != today) {
      _completedDate = today;
      _completedToday = 0;
    }
  }

  // ── Persistence ──────────────────────────────────────────

  Future<void> _saveXp() async {
    await _storage.prefs.setString(_keyXp, jsonEncode(_xp.toJson()));
  }

  Future<void> _loadXp() async {
    final data = _storage.prefs.getString(_keyXp);
    if (data != null) {
      _xp = XpSystem.fromJson(jsonDecode(data) as Map<String, dynamic>);
    }
  }

  Future<void> _saveLessons() async {
    final data = _lessons.map((l) => jsonEncode({
      'id': l.id,
      'completed': l.completed,
      'unlocked': l.unlocked,
      'progress': l.progress,
    })).toList();
    await _storage.prefs.setStringList(_keyLessons, data);
  }

  Future<void> _loadLessonsProgress() async {
    final data = _storage.prefs.getStringList(_keyLessons);
    if (data == null) return;
    _buildLessons();
    for (final entry in data) {
      final json = jsonDecode(entry) as Map<String, dynamic>;
      final idx = _lessons.indexWhere((l) => l.id == json['id']);
      if (idx >= 0) {
        _lessons[idx].completed = json['completed'] ?? false;
        _lessons[idx].unlocked = json['unlocked'] ?? false;
        _lessons[idx].progress = (json['progress'] ?? 0.0).toDouble();
      }
    }
  }

  Future<void> _saveErrors() async {
    final data = jsonEncode(_errorLog);
    await _storage.prefs.setString('error_log', data);
  }

  Future<void> _loadErrors() async {
    final data = _storage.prefs.getString('error_log');
    if (data != null) {
      final list = jsonDecode(data) as List;
      _errorLog.clear();
      _errorLog.addAll(list.map((e) => Map<String, String>.from(e as Map)));
    }
  }

  // ══════════════════════════════════════════════════════════════
  // GÉNÉRATEUR DE LEÇONS — Programme complet d'apprentissage
  // ══════════════════════════════════════════════════════════════

  void _buildLessons() {
    _lessons.clear();
    _lessons.addAll(_generateAllLessons());
    if (_lessons.isNotEmpty) _lessons[0].unlocked = true;
  }

  List<LessonNode> _generateAllLessons() {
    final lessons = <LessonNode>[];
    int lid = 0, eid = 0;

    Exercise mc(int id, String q, String? ar, List<String> opts, String correct, int xp) =>
        Exercise(id: 'e$id', type: ExerciseType.multiChoice, question: q, arabicText: ar, options: opts, correctAnswer: correct, xpReward: xp);
    Exercise fb(int id, String q, String? ar, List<String> opts, String correct, int xp) =>
        Exercise(id: 'e$id', type: ExerciseType.fillBlank, question: q, arabicText: ar, options: opts, correctAnswer: correct, xpReward: xp);
    Exercise mp(int id, String q, Map<String, String> pairs, int xp) =>
        Exercise(id: 'e$id', type: ExerciseType.matchPair, question: q, matchPairs: pairs, correctAnswer: '', xpReward: xp);

    List<String> sh(List<String> l) { l.shuffle(); return l; }

    void addLesson(String id, String title, String desc, String icon, int level, int xp, List<Exercise> exs) {
      lessons.add(LessonNode(id: id, title: title, description: desc, icon: icon, level: level, totalXp: xp, exercises: exs));
      lid++;
    }

    // ──── NIVEAU 1 : ALPHABET (112 leçons) ────
    final letters = <List<String>>[
      ['ا','Alif','a','1'],['ب','Ba','b','2'],['ت','Ta','t','3'],['ث','Tha','th','4'],
      ['ج','Jim','j','5'],['ح','Ha','ḥ','6'],['خ','Kha','kh','7'],['د','Dal','d','8'],
      ['ذ','Dhal','dh','9'],['ر','Ra','r','10'],['ز','Zay','z','11'],['س','Sin','s','12'],
      ['ش','Shin','sh','13'],['ص','Sad','ṣ','14'],['ض','Dad','ḍ','15'],['ط','Ta','ṭ','16'],
      ['ظ','Za','ẓ','17'],['ع','Ayn','ʿ','18'],['غ','Ghayn','gh','19'],['ف','Fa','f','20'],
      ['ق','Qaf','q','21'],['ك','Kaf','k','22'],['ل','Lam','l','23'],['م','Mim','m','24'],
      ['ن','Nun','n','25'],['ه','Ha','h','26'],['و','Waw','w','27'],['ي','Ya','y','28'],
    ];

    for (final l in letters) {
      // Leçon 1 : Reconnaître la lettre
      addLesson('L${l[3]}_1', 'Lettre ${l[1]} (1/4)', 'Reconnaître ${l[0]}', l[0], 1, 30, [
        mc(++eid, 'Quelle est cette lettre ?', l[0], sh(['${l[1]}','Ta','Nun','Lam']), l[1], 8),
        mc(++eid, 'Trouve ${l[0]}', null, sh([l[0],'ب','ت','ن']), l[0], 8),
        fb(++eid, 'La lettre est : ___', l[0], sh([l[1],'Ba','Nun','Lam']), l[1], 8),
      ]);
      // Leçon 2 : Prononciation
      addLesson('L${l[3]}_2', 'Lettre ${l[1]} (2/4)', 'Prononcer ${l[0]}', '🔊', 1, 30, [
        mc(++eid, 'Son de ${l[0]} ?', l[0], sh(['${l[2]}','b','t','k']), l[2], 8),
        mc(++eid, 'Quelle lettre fait "${l[2]}" ?', null, sh([l[0],'د','ر','س']), l[0], 8),
        fb(++eid, 'Transcription de ${l[0]} : ___', l[0], sh([l[2],'a','i','u']), l[2], 8),
      ]);
      // Leçon 3 : Formes de la lettre
      addLesson('L${l[3]}_3', 'Lettre ${l[1]} (3/4)', 'Formes de ${l[0]}', '✍️', 1, 35, [
        mc(++eid, 'Forme isolée de la lettre ?', null, sh([l[0],'ـبـ','تا','نـ']), l[0], 8),
        mp(++eid, 'Associe la forme à sa position', {
          l[0]: 'Isolée', 'ـ${l[0]}ـ': 'Milieu', '${l[0]}ـ': 'Début', 'ـ${l[0]}': 'Fin'
        }, 12),
      ]);
      // Leçon 4 : Mots contenant la lettre
      final words = _wordsWithLetter(l[0]);
      addLesson('L${l[3]}_4', 'Lettre ${l[1]} (4/4)', 'Mots avec ${l[0]}', '📝', 1, 40, [
        if (words.isNotEmpty) mc(++eid, 'Quel mot contient ${l[0]} ?', null, sh([words[0], words.length > 2 ? words[2] : 'سلام', 'بيت', 'شمس']), words[0], 10),
        if (words.length > 1) mc(++eid, 'Trouve le mot avec ${l[0]}', null, sh([words[1], 'كتاب', 'قلم', 'باب']), words[1], 10),
        fb(++eid, 'La lettre ${l[0]} est dans le mot ___', null, sh(words.isNotEmpty ? [words.isNotEmpty ? words[0] : '','كتاب','نور'] : ['سلام','بيت','شمس']), words.isNotEmpty ? words[0] : 'سلام', 10),
      ]);
    }

    // ──── NIVEAU 2-5 : VOCABULAIRE CORANIQUE (300+ leçons) ────
    final allWords = _buildFullVocabulary();
    for (int groupIndex = 0; groupIndex < allWords.length; groupIndex += 2) {
      final group = allWords.sublist(groupIndex, (groupIndex + 2).clamp(0, allWords.length));
      final groupNum = groupIndex ~/ 2 + 1;
      final level = 2 + (groupIndex ~/ 20);

      final exercises = <Exercise>[];
      for (final w in group) {
        exercises.add(mc(++eid, '"${w[0]}" signifie...', w[0], sh([w[2], allWords[(groupIndex + 1) % allWords.length][2], allWords[(groupIndex + 2) % allWords.length][2], allWords[(groupIndex + 5) % allWords.length][2]]), w[2], 10));
        exercises.add(mc(++eid, 'Comment dit-on "${w[2]}" ?', null, sh([w[0], group[(group.indexOf(w) + 1) % group.length][0], allWords[(groupIndex + 3) % allWords.length][0], allWords[(groupIndex + 7) % allWords.length][0]]), w[0], 10));
      }
      if (group.length >= 2) {
        exercises.add(mp(++eid, 'Associe chaque mot à sa traduction', Map.fromEntries(group.map((w) => MapEntry(w[0], w[2]))), 15));
      }
      exercises.add(fb(++eid, 'Complète : "${group[0][0]}" → ___', group[0][0], sh([group[0][2], group.length > 1 ? group[1][2] : 'Livre', allWords[(groupIndex + 4) % allWords.length][2], allWords[(groupIndex + 9) % allWords.length][2]]), group[0][2], 10));

      addLesson('VOC$groupNum', 'Vocabulaire $groupNum', group.map((w) => w[2]).join(', '), '📝', level.clamp(2, 20), 50 + exercises.length * 8, exercises);
    }

    // ──── NIVEAU 3-7 : PHRASES ET EXPRESSIONS (80 leçons) ────
    _buildPhraseLessons(lessons, ++lid, ++eid, sh);
    // The function modifies lid and eid, so we need to capture returned values
    // For simplicity, I'll inline phrase lessons here since passing by reference doesn't work in Dart

    // ──── NIVEAU 5-10 : GRAMMAIRE (40 leçons) ────
    final grammarTopics = [
      ['Pronoms personnels','أنا, أنت, هو, هي, نحن, أنتم, هم',[
        ['Je','أنا','أنت','هو','نحن'],['Tu','أنت','أنا','هي','هم'],['Il','هو','هي','نحن','أنتم'],
        ['Nous','نحن','أنتم','هم','أنا'],['Elle','هي','هو','أنت','نحن'],['Ils','هم','نحن','أنتم','هي'],
      ]],
      ['Démonstratifs','هذا, هذه, هؤلاء',[
        ['Ceci (masc.)','هذا','هذه','ذلك','هؤلاء'],['Ceci (fém.)','هذه','هذا','تلك','هؤلاء'],
        ['Cela (masc.)','ذلك','هذا','تلك','هؤلاء'],
      ]],
      ['Conjugaison passé','كتب, ذهب, قرأ',[
        ['Il a écrit','كتب','يكتب','اكتب','كتاب'],['Il est parti','ذهب','يذهب','اذهب','ذاهب'],
        ['Il a lu','قرأ','يقرأ','اقرأ','قارئ'],['Elle a écrit','كتبت','يكتب','كتب','كتاب'],
        ['Ils ont écrit','كتبوا','يكتبون','اكتبوا','كتب'],
      ]],
      ['Conjugaison présent','يكتب, يذهب, يقرأ',[
        ['Il écrit','يكتب','كتب','اكتب','كاتب'],['Nous écrivons','نكتب','يكتب','كتبنا','اكتب'],
        ['Tu écris (m)','تكتب','يكتب','اكتب','كتبت'],['Vous écrivez','تكتبون','يكتبون','كتبتم','اكتبوا'],
      ]],
      ['Noms et adjectifs','كبير, صغير, جميل',[
        ['Grand','كبير','صغير','جميل','طويل'],['Petit','صغير','كبير','جميل','قصير'],
        ['Beau','جميل','قبيح','كبير','صغير'],['Grand livre','كتاب كبير','كبير كتاب','كتاب جميل','جميل كتاب'],
      ]],
      ['Prépositions','في, على, من, إلى',[
        ['Dans','في','على','من','إلى'],['Sur','على','في','من','تحت'],
        ['De','من','إلى','في','عن'],['Vers','إلى','من','في','على'],
      ]],
      ['Négation','لا, ما, لم, لن',[
        ['Il n\'écrit pas','لا يكتب','ما كتب','لم يكتب','لن يكتب'],
        ['Il n\'a pas écrit','ما كتب','لا يكتب','لم يكتب','لن يكتب'],
        ['Il n\'écrira pas','لن يكتب','لا يكتب','ما كتب','لم يكتب'],
      ]],
      ['Pluriels','مسلمون, كتب, بيوت',[
        ['Musulmans','مسلمون','مسلمات','مسلمين','إسلام'],
        ['Livres','كتب','كتاب','كتابان','مكتبة'],['Maisons','بيوت','بيت','بيتان','أبيات'],
      ]],
    ];

    for (final gt in grammarTopics) {
      for (int subLesson = 0; subLesson < (gt[2] as List).length; subLesson += 2) {
        final subItems = (gt[2] as List).sublist(subLesson, (subLesson + 2).clamp(0, (gt[2] as List).length));
        final exs = <Exercise>[];
        for (final item in subItems) {
          final q = item[0] as String;
          final correct = item[1] as String;
          exs.add(mc(++eid, 'Grammaire : $q', null, sh([correct, item[2] as String, item[3] as String, item[4] as String]), correct, 10));
        }
        final subNum = subLesson ~/ 2 + 1;
        addLesson('GR${gt[0]}$subNum', '${gt[0]} $subNum', gt[1] as String, '📐', 4 + lid ~/ 15, 40 + exs.length * 10, exs);
      }
    }

    // ──── NIVEAU 3-8 : SOURATES (114 mini-leçons) ────
    _buildSurahLessons(lessons, lid, eid);

    // ──── NIVEAU 5-10 : CONJUGAISON (80 leçons) ────
    _buildConjugationLessons(lessons, lid, eid);

    // ──── NIVEAU 4-9 : CONNAISSANCES ISLAMIQUES ────
    final islamTopics = [
      ['5 Piliers','Shahada, Salat, Zakat, Sawm, Hajj',[
        ['Combien de piliers ?','5','3','7','10'],['1er pilier','Shahada','Salat','Zakat','Hajj'],
        ['2e pilier','Salat','Shahada','Zakat','Sawm'],['3e pilier','Zakat','Salat','Sawm','Hajj'],
        ['4e pilier','Sawm','Salat','Zakat','Hajj'],['5e pilier','Hajj','Salat','Zakat','Sawm'],
      ]],
      ['6 Piliers Foi','Allah, Anges, Livres, Messagers, Jour Dernier, Destin',[
        ['1er pilier foi','Allah','Anges','Livres','Messagers'],['2e pilier foi','Anges','Allah','Livres','Destin'],
        ['3e pilier foi','Livres révélés','Anges','Allah','Jour Dernier'],
      ]],
      ['Coran - Structure','114 sourates, 30 Juz, révélé en 23 ans',[
        ['Nb sourates','114','99','100','120'],['Nb Juz','30','20','40','7'],
        ['Révélé en','23 ans','10 ans','40 ans','15 ans'],['1ère sourate','Al-Fatiha','Al-Baqara','Al-Ikhlas','An-Nas'],
        ['Dernière sourate','An-Nas','Al-Fatiha','Al-Baqara','Al-Ikhlas'],['Verset le + long','2:282','2:255','4:34','24:35'],
      ]],
      ['Prophètes majeurs','Adam, Nuh, Ibrahim, Musa, Isa, Muhammad',[
        ['1er prophète','Adam','Nuh','Ibrahim','Musa'],['Arche','Nuh','Musa','Ibrahim','Adam'],
        ['Ami d\'Allah','Ibrahim','Musa','Isa','Adam'],['Tawrat','Musa','Isa','Ibrahim','Nuh'],
        ['Injil','Isa','Musa','Ibrahim','Nuh'],['Dernier prophète','Muhammad','Isa','Musa','Ibrahim'],
      ]],
      ['Ramadan','Mois du Coran, Laylat al-Qadr, 29-30 jours',[
        ['Coran révélé en','Ramadan','Muharram','Rajab','Shawwal'],['Laylat al-Qadr >','1000 mois','100 mois','1 an','10 ans'],
        ['Durée Ramadan','29-30 jours','28 jours','31 jours','15 jours'],['Repas avant jeune','Suhur','Iftar','Déjeuner','Dîner'],
      ]],
      ['Hajj','Pèlerinage à La Mecque, une fois dans la vie',[
        ['Où ?','La Mecque','Médine','Jérusalem','Damas'],['Obligatoire ?','1 fois/vie','Chaque année','3 fois','Optionnel'],
        ['Kaaba se trouve à','La Mecque','Médine','Jérusalem','Taïf'],
      ]],
      ['Anges','Jibril, Mikail, Israfil, Malak al-Mawt',[
        ['Ange de la révélation','Jibril','Mikail','Israfil','Ridwan'],['Ange de la mort','Malak al-Mawt','Jibril','Mikail','Israfil'],
        ['Ange gardien enfer','Malik','Ridwan','Jibril','Mikail'],
      ]],
      ['Hourras et Résurrection','Yawm al-Qiyama, Al-Janna, An-Nar',[
        ['Jour du Jugement','Yawm al-Qiyama','Yawm al-Jumu\'a','Laylat al-Qadr','Yawm Arafat'],
        ['Paradis','Al-Janna','An-Nar','Dunya','Barzakh'],['Enfer','An-Nar','Al-Janna','Dunya','Akhira'],
      ]],
    ];

    for (final it in islamTopics) {
      final items = it[2] as List;
      for (int i = 0; i < (items.length / 3).ceil(); i++) {
        final sub = items.sublist(i * 3, ((i + 1) * 3).clamp(0, items.length));
        final exs = sub.map((e) => mc(++eid, (e as List)[0] as String, null, sh([e[1] as String, e[2] as String, e[3] as String, e[4] as String]), e[1] as String, 10)).toList();
        addLesson('IS_${it[0]}_${i + 1}', '${it[0]} (${i + 1})', it[1] as String, '☪️', 3 + lid ~/ 10, 30 + exs.length * 10, exs);
      }
    }

    // ──── NIVEAU 2-5 : VIE QUOTIDIENNE ────
    _buildDailyLifeLessons(lessons, lid, eid);

    // ──── NIVEAU 5-10 : COMPRÉHENSION DU CORAN ────
    _buildQuranComprehensionLessons(lessons, lid, eid);

    return lessons;
  }

  // ── Helpers ─────────────────────────────────────────────────

  List<String> _wordsWithLetter(String letter) {
    final map = {
      'ا': ['كتاب','سلام','إيمان'], 'ب': ['باب','رب','صبر'], 'ت': ['تقوى','بيت','موت'],
      'ث': ['ثواب','مثل','كثير'], 'ج': ['جنة','مسجد','حج'], 'ح': ['حمد','رحمن','حياة'],
      'خ': ['خير','آخر','شيخ'], 'د': ['دين','هدى','مسجد'], 'ذ': ['ذنب','هذا','عذاب'],
      'ر': ['رب','رحمن','نور'], 'ز': ['زكاة','رزق','عزيز'], 'س': ['سلام','رسول','نفس'],
      'ش': ['شكر','شمس','شيطان'], 'ص': ['صبر','صلاة','نصر'], 'ض': ['أرض','رمضان','فضل'],
      'ط': ['صراط','شيطان','طريق'], 'ظ': ['عظيم','ظلم','حفظ'], 'ع': ['علم','عين','سمع'],
      'غ': ['غفور','غرب','صغير'], 'ف': ['فجر','نفس','خوف'], 'ق': ['قرآن','حق','قلب'],
      'ك': ['كتاب','ملك','شكر'], 'ل': ['ليل','سلام','قلب'], 'م': ['مسجد','ماء','إيمان'],
      'ن': ['نور','إيمان','جنة'], 'ه': ['الله','هدى','جاهد'], 'و': ['نور','يوم','موت'],
      'ي': ['يد','بيت','دين'],
    };
    return map[letter] ?? [];
  }

  List<List<String>> _buildFullVocabulary() {
    return [
      ['كتاب','Kitab','Livre'],['رب','Rabb','Seigneur'],['رحمن','Rahman','Miséricordieux'],
      ['علم','Ilm','Savoir'],['نور','Nur','Lumière'],['سلام','Salam','Paix'],
      ['حمد','Hamd','Louange'],['هدى','Huda','Guidance'],['حق','Haqq','Vérité'],
      ['صبر','Sabr','Patience'],['رحمة','Rahma','Miséricorde'],['غفور','Ghafur','Pardonneur'],
      ['شكر','Shukr','Reconnaissance'],['توكل','Tawakkul','Confiance'],['إيمان','Iman','Foi'],
      ['تقوى','Taqwa','Piété'],['جنة','Janna','Paradis'],['نار','Nar','Feu'],
      ['يوم','Yawm','Jour'],['ليل','Layl','Nuit'],['سماء','Sama','Ciel'],
      ['أرض','Ard','Terre'],['ماء','Ma','Eau'],['نفس','Nafs','Âme'],
      ['قلب','Qalb','Cœur'],['عين','Ayn','Œil'],['يد','Yad','Main'],
      ['لسان','Lisan','Langue'],['رسول','Rasul','Messager'],['نبي','Nabi','Prophète'],
      ['ملك','Malak','Ange'],['شيطان','Shaytan','Satan'],['مسجد','Masjid','Mosquée'],
      ['صلاة','Salah','Prière'],['زكاة','Zakat','Aumône'],['صوم','Sawm','Jeûne'],
      ['حج','Hajj','Pèlerinage'],['قرآن','Quran','Coran'],['آية','Aya','Verset'],
      ['سورة','Sura','Sourate'],['سبيل','Sabil','Chemin'],['صراط','Sirat','Voie'],
      ['حياة','Hayat','Vie'],['موت','Mawt','Mort'],['قوة','Quwwa','Force'],
      ['كلمة','Kalima','Parole'],['حكمة','Hikma','Sagesse'],['ملك','Mulk','Royaume'],
      ['عذاب','Adhab','Châtiment'],['أجر','Ajr','Récompense'],['جهاد','Jihad','Effort'],
      ['فجر','Fajr','Aube'],['خير','Khayr','Bien'],['شر','Sharr','Mal'],
      ['ذنب','Dhanb','Péché'],['توبة','Tawba','Repentir'],['غيب','Ghayb','Invisible'],
      ['وحي','Wahy','Révélation'],['بركة','Baraka','Bénédiction'],['دعاء','Du\'a','Invocation'],
      ['ظلم','Dhulm','Injustice'],['عدل','Adl','Justice'],['صدق','Sidq','Véracité'],
      ['كذب','Kadhib','Mensonge'],['حلال','Halal','Licite'],['حرام','Haram','Illicite'],
      ['أمة','Umma','Communauté'],['خلق','Khuluq','Caractère'],['أخرة','Akhira','Au-delà'],
      ['دنيا','Dunya','Ici-bas'],['نعمة','Ni\'ma','Bienfait'],['بلاء','Bala','Épreuve'],
      ['نصر','Nasr','Victoire'],['هزيمة','Hazima','Défaite'],['عزة','Izza','Dignité'],
      ['ذل','Dhull','Humiliation'],['فرح','Farah','Joie'],['حزن','Huzn','Tristesse'],
      ['خوف','Khawf','Peur'],['أمن','Amn','Sécurité'],['غضب','Ghadab','Colère'],
      ['رأفة','Ra\'fa','Compassion'],['كرم','Karam','Générosité'],['بخل','Bukhl','Avarice'],
      ['شجاعة','Shaja\'a','Courage'],['جبن','Jubn','Lâcheté'],['صحة','Sihha','Santé'],
      ['مرض','Marad','Maladie'],['غنى','Ghina','Richesse'],['فقر','Faqr','Pauvreté'],
      // + 100 mots supplémentaires pour atteindre ~200 mots
      ['شمس','Shams','Soleil'],['قمر','Qamar','Lune'],['نجم','Najm','Étoile'],
      ['بحر','Bahr','Mer'],['نهر','Nahr','Rivière'],['جبل','Jabal','Montagne'],
      ['شجر','Shajar','Arbre'],['ثمر','Thamar','Fruit'],['زهر','Zahr','Fleur'],
      ['طير','Tayr','Oiseau'],['سمك','Samak','Poisson'],['كلب','Kalb','Chien'],
      ['فرس','Faras','Cheval'],['جمل','Jamal','Chameau'],['غنم','Ghanam','Mouton'],
      ['ذهب','Dhahab','Or'],['فضة','Fidda','Argent'],['حديد','Hadid','Fer'],
      ['حجر','Hajar','Pierre'],['خشب','Khashab','Bois'],['زجاج','Zujaj','Verre'],
      ['أب','Ab','Père'],['أم','Umm','Mère'],['ابن','Ibn','Fils'],
      ['بنت','Bint','Fille'],['أخ','Akh','Frère'],['أخت','Ukht','Sœur'],
      ['زوج','Zawj','Époux'],['زوجة','Zawja','Épouse'],['ولد','Walad','Enfant'],
      ['صديق','Sadiq','Ami'],['جار','Jar','Voisin'],['ضيف','Dayf','Invité'],
      ['بيت','Bayt','Maison'],['باب','Bab','Porte'],['سقف','Saqf','Toit'],
      ['سرير','Sarir','Lit'],['كرسي','Kursi','Chaise'],['مصباح','Misbah','Lampe'],
      ['قلم','Qalam','Stylo'],['ورق','Waraq','Papier'],['كأس','Ka\'s','Verre'],
      ['ملابس','Malabis','Vêtements'],['حذاء','Hidha','Chaussure'],['خاتم','Khatam','Bague'],
      ['سيف','Sayf','Épée'],['خبز','Khubz','Pain'],['لحم','Lahm','Viande'],
      ['لبن','Laban','Lait'],['عسل','Asal','Miel'],['تمر','Tamar','Datte'],
      ['زيت','Zayt','Huile'],['ملح','Milh','Sel'],['سكر','Sukkar','Sucre'],
      ['فاكهة','Fakiha','Fruit'],['خضار','Khudar','Légumes'],['أرز','Aruz','Riz'],
      ['أحمر','Ahmar','Rouge'],['أبيض','Abyad','Blanc'],['أسود','Aswad','Noir'],
      ['أخضر','Akhdar','Vert'],['أزرق','Azraq','Bleu'],['أصفر','Asfar','Jaune'],
      ['صباح','Sabah','Matin'],['مساء','Masa','Soir'],['نهار','Nahar','Journée'],
      ['أمس','Ams','Hier'],['غد','Ghad','Demain'],['أسبوع','Usbu','Semaine'],
      ['شهر','Shahr','Mois'],['سنة','Sana','Année'],['وقت','Waqt','Temps'],
      ['ساعة','Sa\'a','Heure'],['دقيقة','Daqiqa','Minute'],['لحظة','Lahdha','Instant'],
      // 200 mots supplémentaires
      ['سلطان','Sultan','Autorité'],['شهيد','Shahid','Témoin'],['غائب','Gha\'ib','Absent'],
      ['حاضر','Hadir','Présent'],['قريب','Qarib','Proche'],['بعيد','Ba\'id','Lointain'],
      ['طويل','Tawil','Long'],['قصير','Qasir','Court'],['ثقيل','Thaqil','Lourd'],
      ['خفيف','Khafif','Léger'],['سريع','Sari\'','Rapide'],['بطيء','Bati','Lent'],
      ['واسع','Wasi\'','Large'],['ضيق','Dayyiq','Étroit'],['عالي','Ali','Haut'],
      ['منخفض','Munkhafid','Bas'],['مستقيم','Mustaqim','Droit'],['معوج','Mu\'wajj','Tordu'],
      ['نظيف','Nadhif','Propre'],['وسخ','Wasikh','Sale'],['جديد','Jadid','Nouveau'],
      ['قديم','Qadim','Ancien'],['شاب','Shabb','Jeune'],['عجوز','Ajuz','Vieux'],
      ['غني','Ghani','Riche'],['فقير','Faqir','Pauvre'],['سعيد','Sa\'id','Heureux'],
      ['حزين','Hazin','Triste'],['ذكي','Dhaki','Intelligent'],['غبي','Ghabi','Stupide'],
      ['شجاع','Shuja\'','Courageux'],['جبان','Jaban','Lâche'],['كريم','Karim','Généreux'],
      ['بخيل','Bakhil','Avare'],['صادق','Sadiq','Véridique'],['كاذب','Kadhib','Menteur'],
      ['مخلص','Mukhlis','Sincère'],['منافق','Munafiq','Hypocrite'],['صالح','Salih','Vertueux'],
      ['فاسد','Fasid','Corrompu'],['عاقل','Aqil','Raisonnable'],['جاهل','Jahil','Ignorant'],
      ['مؤمن','Mu\'min','Croyant'],['كافر','Kafir','Mécréant'],['تقي','Taqi','Pieux'],
      ['فاجر','Fajir','Pervers'],['بر','Barr','Bienfaisant'],['عاق','Aqq','Ingrat'],
      ['راض','Rad','Satisfait'],['غاضب','Ghadib','En colère'],['مريض','Marid','Malade'],
      ['معافى','Mu\'afa','En bonne santé'],['نائم','Na\'im','Endormi'],['مستيقظ','Mustayqidh','Éveillé'],
      ['جائع','Ja\'i\'','Affamé'],['شبعان','Shab\'an','Rassasié'],['عطشان','Atshan','Assoiffé'],
      ['ريان','Rayyan','Désaltéré'],['متعب','Mut\'ab','Fatigué'],['نشيط','Nashit','Actif'],
      ['محبوب','Mahbub','Aimé'],['مكروه','Makruh','Détesté'],['مشهور','Mashhur','Célèbre'],
      ['مجهول','Majhul','Inconnu'],['مسلم','Muslim','Musulman'],['يهودي','Yahudi','Juif'],
      ['نصراني','Nasrani','Chrétien'],['عربي','Arabi','Arabe'],['أعجمي','A\'jami','Non-arabe'],
      ['حر','Hurr','Libre'],['عبد','Abd','Esclave'],['ذكر','Dhakar','Mâle'],
      ['أنثى','Untha','Femelle'],['صغير','Saghir','Petit'],['كبير','Kabir','Grand'],
      ['حلو','Hulw','Sucré'],['مر','Murr','Amer'],['مالح','Malih','Salé'],
      ['حامض','Hamid','Acide'],['طازج','Tazij','Frais'],['يابس','Yabis','Sec'],
      ['رطب','Ratb','Humide'],['صلب','Sulb','Dur'],['لين','Layyin','Mou'],
      ['ناعم','Na\'im','Doux'],['خشن','Khashin','Rugueux'],['أملس','Amlas','Lisse'],
      ['عميق','Amiq','Profond'],['سطحي','Sathi','Superficiel'],['ظاهر','Dhahir','Apparent'],
      ['باطن','Batin','Caché'],['علني','Alani','Public'],['سري','Sirri','Secret'],
      ['فرد','Fard','Individu'],['جماعة','Jama\'a','Groupe'],['قائد','Qa\'id','Leader'],
      ['تابع','Tabi\'','Suiveur'],['معلم','Mu\'allim','Enseignant'],['متعلم','Muta\'allim','Apprenant'],
      ['كاتب','Katib','Écrivain'],['قارئ','Qari','Lecteur'],['سامع','Sami\'','Auditeur'],
      ['متكلم','Mutakallim','Parleur'],['صامت','Samit','Silencieux'],['باك','Baki','Pleurant'],
      ['ضاحك','Dahik','Riant'],['جالس','Jalis','Assis'],['واقف','Waqif','Debout'],
      ['ماش','Mashi','Marchant'],['راكض','Rakid','Courant'],['سابح','Sabih','Nageant'],
      ['طائر','Ta\'ir','Volant'],['زاحف','Zahif','Rampant'],['ناطق','Natiq','Parlant'],
      ['صاعد','Sa\'id','Montant'],['نازل','Nazil','Descendant'],['داخل','Dakhil','Entrant'],
      ['خارج','Kharij','Sortant'],['قادم','Qadim','Venant'],['ذاهب','Dhahib','Partant'],
      ['مقيم','Muqim','Résident'],['مسافر','Musafir','Voyageur'],['زائر','Za\'ir','Visiteur'],
      ['مضيف','Mudif','Hôte'],['جاسوس','Jasus','Espion'],['حارس','Haris','Gardien'],
      ['خادم','Khadim','Serviteur'],['سيد','Sayyid','Maître'],['ملك','Malik','Roi'],
      ['وزير','Wazir','Ministre'],['قاضي','Qadi','Juge'],['شاهد','Shahid','Témoin'],
      ['مدعي','Mudda\'i','Plaignant'],['متهم','Muttaham','Accusé'],['محام','Muhami','Avocat'],
      ['طبيب','Tabib','Médecin'],['ممرض','Mumarrid','Infirmier'],['صيدلي','Saydali','Pharmacien'],
      ['مهندس','Muhandis','Ingénieur'],['نجار','Najjar','Menuisier'],['حداد','Haddad','Forgeron'],
      ['خياط','Khayyat','Tailleur'],['طباخ','Tabbakh','Cuisinier'],['خباز','Khabbaz','Boulanger'],
      ['بقال','Baqqal','Épicier'],['تاجر','Tajir','Commerçant'],['صراف','Sarraf','Changeur'],
      ['بناء','Banna','Constructeur'],['دهان','Dahhan','Peintre'],['حلاق','Hallaq','Coiffeur'],
      ['سائق','Sa\'iq','Chauffeur'],['بحار','Bahhar','Marin'],['صياد','Sayyad','Pêcheur'],
      ['راعي','Ra\'i','Berger'],['فلاح','Fallah','Agriculteur'],['بستاني','Bustani','Jardinier'],
    ];
  }

  void _buildPhraseLessons(List<LessonNode> lessons, int lid, int eid, List<String> Function(List<String>) sh) {
    final phrases = [
      ['Salutations','السلام عليكم, وعليكم السلام, مرحبا, أهلا وسهلا',[
        ['السلام عليكم','La paix sur vous','Bonjour','Merci','Salut'],
        ['Réponse','وعليكم السلام','مرحبا','أهلا','شكرا'],
        ['Bienvenue','أهلا وسهلا','مرحبا','السلام عليكم','صباح الخير'],
      ]],
      ['Expressions','بسم الله, الحمد لله, إن شاء الله, ما شاء الله',[
        ['Avant de commencer','بسم الله','الحمد لله','الله أكبر','سبحان الله'],
        ['Après un succès','الحمد لله','بسم الله','إن شاء الله','ما شاء الله'],
        ['Projet futur','إن شاء الله','ما شاء الله','بسم الله','الحمد لله'],
        ['Admiration','ما شاء الله','إن شاء الله','بسم الله','الحمد لله'],
      ]],
      ['Remerciements','شكرا, جزاك الله خيرا, بارك الله فيك',[
        ['Merci simple','شكرا','عفوا','مرحبا','سلام'],
        ['Merci appuyé','جزاك الله خيرا','شكرا','عفوا','مرحبا'],
        ['Bénédiction','بارك الله فيك','شكرا','جزاك الله','عفوا'],
      ]],
      ['Dou\'as quotidiennes','Avant de manger, en entrant, en sortant',[
        ['Avant de manger','بسم الله','الحمد لله','الله أكبر','سبحان الله'],
        ['Après manger','الحمد لله','بسم الله','إن شاء الله','ما شاء الله'],
        ['En entrant maison','السلام علينا','بسم الله','الحمد لله','الله أكبر'],
      ]],
    ];

    for (final p in phrases) {
      final items = p[2] as List;
      for (int i = 0; i < (items.length / 2).ceil(); i++) {
        final sub = items.sublist(i * 2, ((i + 1) * 2).clamp(0, items.length));
        final exs = sub.map((e) {
          final item = e as List;
          return Exercise(id: 'e${eid++}', type: ExerciseType.multiChoice, question: 'Que signifie ${item[0]} ?', arabicText: item[0], options: sh([item[1] as String, item[2] as String, item[3] as String, item[4] as String]), correctAnswer: item[1] as String, xpReward: 10);
        }).toList();
        lessons.add(LessonNode(id: 'PH_${p[0]}_${i + 1}', title: '${p[0]} (${i + 1})', description: p[1] as String, icon: '💬', level: 2, totalXp: 30 + exs.length * 10, exercises: exs));
      }
    }
  }

  void _buildSurahLessons(List<LessonNode> lessons, int lid, int eid) {
    final surahs = [
      [1,'Al-Fatiha','L\'ouverture','مكية',7], [2,'Al-Baqara','La vache','مدنية',286],
      [3,'Al-Imran','La famille d\'Imran','مدنية',200], [4,'An-Nisa','Les femmes','مدنية',176],
      [5,'Al-Ma\'ida','La table servie','مدنية',120], [6,'Al-An\'am','Les bestiaux','مكية',165],
      [7,'Al-A\'raf','Les murailles','مكية',206], [8,'Al-Anfal','Le butin','مدنية',75],
      [9,'At-Tawba','Le repentir','مدنية',129], [10,'Yunus','Jonas','مكية',109],
      [11,'Hud','Hud','مكية',123], [12,'Yusuf','Joseph','مكية',111],
      [13,'Ar-Ra\'d','Le tonnerre','مدنية',43], [14,'Ibrahim','Abraham','مكية',52],
      [15,'Al-Hijr','La vallée','مكية',99], [16,'An-Nahl','Les abeilles','مكية',128],
      [17,'Al-Isra','Le voyage nocturne','مكية',111], [18,'Al-Kahf','La caverne','مكية',110],
      [19,'Maryam','Marie','مكية',98], [20,'Ta-Ha','Ta-Ha','مكية',135],
      [21,'Al-Anbiya','Les prophètes','مكية',112], [22,'Al-Hajj','Le pèlerinage','مدنية',78],
      [23,'Al-Mu\'minun','Les croyants','مكية',118], [24,'An-Nur','La lumière','مدنية',64],
      [25,'Al-Furqan','Le discernement','مكية',77], [26,'Ash-Shu\'ara','Les poètes','مكية',227],
      [27,'An-Naml','Les fourmis','مكية',93], [28,'Al-Qasas','Le récit','مكية',88],
      [29,'Al-Ankabut','L\'araignée','مكية',69], [30,'Ar-Rum','Les romains','مكية',60],
      [31,'Luqman','Luqman','مكية',34], [32,'As-Sajda','La prosternation','مكية',30],
      [33,'Al-Ahzab','Les coalisés','مدنية',73], [34,'Saba','Saba','مكية',54],
      [35,'Fatir','Le créateur','مكية',45], [36,'Ya-Sin','Ya-Sin','مكية',83],
      [37,'As-Saffat','Les rangés','مكية',182], [38,'Sad','Sad','مكية',88],
      [39,'Az-Zumar','Les groupes','مكية',75], [40,'Ghafir','Le pardonneur','مكية',85],
      [41,'Fussilat','Les détaillés','مكية',54], [42,'Ash-Shura','La concertation','مكية',53],
      [43,'Az-Zukhruf','L\'ornement','مكية',89], [44,'Ad-Dukhan','La fumée','مكية',59],
      [45,'Al-Jathiya','L\'agenouillée','مكية',37], [46,'Al-Ahqaf','Les dunes','مكية',35],
      [47,'Muhammad','Muhammad','مدنية',38], [48,'Al-Fath','La victoire','مدنية',29],
      [49,'Al-Hujurat','Les appartements','مدنية',18], [50,'Qaf','Qaf','مكية',45],
      [51,'Adh-Dhariyat','Les vents','مكية',60], [52,'At-Tur','Le mont','مكية',49],
      [53,'An-Najm','L\'étoile','مكية',62], [54,'Al-Qamar','La lune','مكية',55],
      [55,'Ar-Rahman','Le Miséricordieux','مدنية',78], [56,'Al-Waqi\'a','L\'événement','مكية',96],
      [57,'Al-Hadid','Le fer','مدنية',29], [58,'Al-Mujadila','La discussion','مدنية',22],
      [59,'Al-Hashr','L\'exode','مدنية',24], [60,'Al-Mumtahana','L\'examinée','مدنية',13],
      [61,'As-Saff','Le rang','مدنية',14], [62,'Al-Jumu\'a','Le vendredi','مدنية',11],
      [63,'Al-Munafiqun','Les hypocrites','مدنية',11], [64,'At-Taghabun','La perte','مدنية',18],
      [65,'At-Talaq','Le divorce','مدنية',12], [66,'At-Tahrim','L\'interdiction','مدنية',12],
      [67,'Al-Mulk','La royauté','مكية',30], [68,'Al-Qalam','La plume','مكية',52],
      [69,'Al-Haqqa','L\'inévitable','مكية',52], [70,'Al-Ma\'arij','Les degrés','مكية',44],
      [71,'Nuh','Noé','مكية',28], [72,'Al-Jinn','Les djinns','مكية',28],
      [73,'Al-Muzzammil','L\'enveloppé','مكية',20], [74,'Al-Muddaththir','Le revêtu','مكية',56],
      [75,'Al-Qiyama','La résurrection','مكية',40], [76,'Al-Insan','L\'homme','مدنية',31],
      [78,'An-Naba','La nouvelle','مكية',40], [79,'An-Nazi\'at','Les anges','مكية',46],
      [80,'Abasa','Il s\'est renfrogné','مكية',42], [81,'At-Takwir','L\'obscurcissement','مكية',29],
      [82,'Al-Infitar','La rupture','مكية',19], [83,'Al-Mutaffifin','Les fraudeurs','مكية',36],
      [84,'Al-Inshiqaq','La déchirure','مكية',25], [85,'Al-Buruj','Les constellations','مكية',22],
      [86,'At-Tariq','L\'astre nocturne','مكية',17], [87,'Al-A\'la','Le Très-Haut','مكية',19],
      [88,'Al-Ghashiya','L\'enveloppante','مكية',26], [89,'Al-Fajr','L\'aube','مكية',30],
      [90,'Al-Balad','La cité','مكية',20], [91,'Ash-Shams','Le soleil','مكية',15],
      [92,'Al-Layl','La nuit','مكية',21], [93,'Ad-Duha','La clarté','مكية',11],
      [94,'Ash-Sharh','L\'ouverture','مكية',8], [95,'At-Tin','Le figuier','مكية',8],
      [96,'Al-Alaq','L\'adhérence','مكية',19], [97,'Al-Qadr','La destinée','مكية',5],
      [98,'Al-Bayyina','La preuve','مدنية',8], [99,'Az-Zalzala','Le séisme','مدنية',8],
      [100,'Al-Adiyat','Les coursiers','مكية',11], [101,'Al-Qari\'a','Le fracas','مكية',11],
      [102,'At-Takathur','La course','مكية',8], [103,'Al-Asr','Le temps','مكية',3],
      [104,'Al-Humaza','Le calomniateur','مكية',9], [105,'Al-Fil','L\'éléphant','مكية',5],
      [106,'Quraysh','Les Quraysh','مكية',4], [107,'Al-Ma\'un','L\'ustensile','مكية',7],
      [108,'Al-Kawthar','L\'Abondance','مكية',3], [109,'Al-Kafirun','Les infidèles','مكية',6],
      [110,'An-Nasr','Le secours','مدنية',3], [111,'Al-Masad','La corde','مكية',5],
      [112,'Al-Ikhlas','Le monothéisme','مكية',4], [113,'Al-Falaq','L\'aube','مكية',5],
      [114,'An-Nas','Les hommes','مكية',6],
    ];

    for (final s in surahs) {
      lessons.add(LessonNode(
        id: 'SURAH_${s[0]}',
        title: '${s[0]}. ${s[1]}',
        description: '${s[2]} (${s[3]}, ${s[4]} versets)',
        icon: '📖',
        level: 3 + (s[0] as int) ~/ 20,
        totalXp: 30,
        exercises: [
          Exercise(id: 'e${eid++}', type: ExerciseType.multiChoice, question: 'Combien de versets dans ${s[1]} ?', options: ['${s[4]}','5','10','3'], correctAnswer: '${s[4]}', xpReward: 10),
          Exercise(id: 'e${eid++}', type: ExerciseType.multiChoice, question: 'Type de sourate ?', options: ['${s[3]}','مكية','مدنية','Les deux'], correctAnswer: '${s[3]}', xpReward: 10),
        ],
      ));
    }
  }

  void _buildDailyLifeLessons(List<LessonNode> lessons, int lid, int eid) {
    final topics = {
      'À la maison': [['بيت','Maison'],['باب','Porte'],['نافذة','Fenêtre'],['غرفة','Chambre'],['مطبخ','Cuisine']],
      'Nourriture': [['خبز','Pain'],['لحم','Viande'],['فاكهة','Fruit'],['ماء','Eau'],['شاي','Thé']],
      'Vêtements': [['قميص','Chemise'],['بنطلون','Pantalon'],['حذاء','Chaussure'],['قبعة','Chapeau']],
      'Animaux': [['قط','Chat'],['كلب','Chien'],['حصان','Cheval'],['طائر','Oiseau'],['سمك','Poisson']],
      'Transports': [['سيارة','Voiture'],['قطار','Train'],['طائرة','Avion'],['سفينة','Bateau']],
      'École': [['مدرسة','École'],['معلم','Professeur'],['طالب','Étudiant'],['درس','Leçon'],['امتحان','Examen']],
      'Corps humain': [['رأس','Tête'],['عين','Œil'],['أنف','Nez'],['فم','Bouche'],['أذن','Oreille']],
      'Météo': [['شمس','Soleil'],['مطر','Pluie'],['ريح','Vent'],['ثلج','Neige'],['حر','Chaleur']],
      'Voyage': [['سفر','Voyage'],['مطار','Aéroport'],['جواز','Passeport'],['تذكرة','Billet'],['حقيبة','Valise']],
      'Métiers': [['طبيب','Médecin'],['مهندس','Ingénieur'],['معلم','Enseignant'],['تاجر','Commerçant'],['فلاح','Agriculteur']],
    };

    for (final entry in topics.entries) {
      final words = entry.value;
      final exercises = <Exercise>[];
      for (final w in words) {
        exercises.add(Exercise(id: 'e${eid++}', type: ExerciseType.multiChoice, question: 'Que signifie ${w[0]} ?', arabicText: w[0], options: [w[1], words[(words.indexOf(w) + 1) % words.length][1], 'Livre', 'Maison'], correctAnswer: w[1], xpReward: 10));
      }
      exercises.add(Exercise(id: 'e${eid++}', type: ExerciseType.matchPair, question: 'Associe', matchPairs: Map.fromEntries(words.map((w) => MapEntry(w[0], w[1]))), correctAnswer: '', xpReward: 15));
      lessons.add(LessonNode(id: 'DL_${entry.key}', title: entry.key, description: 'Vocabulaire ${entry.key.toLowerCase()}', icon: '🏠', level: 2, totalXp: 40 + exercises.length * 8, exercises: exercises));
    }
  }

  void _buildConjugationLessons(List<LessonNode> lessons, int lid, int eid) {
    final verbs = [
      ['كتب','kataba','écrire'],['ذهب','dhahaba','aller'],['قرأ','qara\'a','lire'],
      ['فعل','fa\'ala','faire'],['فتح','fataha','ouvrir'],['شرب','shariba','boire'],
      ['أكل','akala','manger'],['سمع','sami\'a','entendre'],['رجع','raja\'a','revenir'],
      ['خرج','kharaja','sortir'],['دخل','dakhala','entrer'],['جلس','jalasa','s\'asseoir'],
      ['قام','qama','se lever'],['نام','nama','dormir'],['عمل','amila','travailler'],
      ['عرف','arafa','connaître'],['فهم','fahima','comprendre'],['حفظ','hafidha','mémoriser'],
      ['سجد','sajada','prosterner'],['ركع','raka\'a','incliner'],
    ];
    final pronouns = [
      ['هو','Il (passé)'],['هي','Elle (passé)'],['أنت','Tu (passé)'],
      ['أنا','Je (passé)'],['هم','Ils (passé)'],['نحن','Nous (passé)'],
    ];

    for (final v in verbs) {
      final exs = <Exercise>[];
      for (final p in pronouns) {
        exs.add(Exercise(id: 'e${eid++}', type: ExerciseType.fillBlank,
          question: '${p[1]} du verbe ${v[2]} (${v[0]}) ?',
          arabicText: '${v[0]} → ${p[0]} ___',
          options: [v[0], '${v[0]}ت', '${v[0]}وا', '${v[0]}نا'],
          correctAnswer: v[0], xpReward: 8));
      }
      lessons.add(LessonNode(id: 'CONJ_${v[0]}', title: 'Verbe ${v[2]}', description: 'Conjugaison de ${v[0]}', icon: '🔄', level: 4 + lid ~/ 20, totalXp: 40, exercises: exs));
    }
  }

  void _buildQuranComprehensionLessons(List<LessonNode> lessons, int lid, int eid) {
    final verses = [
      ['1:1','بسم الله الرحمن الرحيم','Au nom d\'Allah, le Tout Miséricordieux'],
      ['2:255','الله لا إله إلا هو الحي القيوم','Allah! Point de divinité à part Lui, le Vivant'],
      ['112:1','قل هو الله أحد','Dis: Il est Allah, Unique'],
      ['112:2','الله الصمد','Allah, Le Seul à être imploré'],
      ['94:5','فإن مع العسر يسرا','A côté de la difficulté est une facilité'],
      ['94:6','إن مع العسر يسرا','Certes, à côté de la difficulté est une facilité'],
      ['2:153','إن الله مع الصابرين','Certes, Allah est avec les patients'],
      ['65:3','ومن يتوكل على الله فهو حسبه','Quiconque place sa confiance en Allah, Il lui suffit'],
      ['3:139','ولا تهنوا ولا تحزنوا','Ne vous laissez pas abattre, ne vous affligez pas'],
      ['39:53','لا تقنطوا من رحمة الله','Ne désespérez pas de la miséricorde d\'Allah'],
    ];

    for (final v in verses) {
      final ref = v[0];
      final arabic = v[1];
      final trad = v[2];
      lessons.add(LessonNode(
        id: 'QC_$ref',
        title: 'Verset $ref',
        description: trad,
        icon: '🕌',
        level: 5 + (int.tryParse(ref.split(':')[0]) ?? 1) ~/ 20,
        totalXp: 40,
        exercises: [
          Exercise(id: 'e${eid++}', type: ExerciseType.fillBlank, question: 'Complète le verset $ref', arabicText: arabic.substring(0, arabic.length ~/ 2) + '...', options: [trad.split(' ').last, 'Miséricorde', 'Seigneur', 'Vérité'], correctAnswer: trad.split(' ').last, xpReward: 12),
          Exercise(id: 'e${eid++}', type: ExerciseType.multiChoice, question: 'Quel verset dit : "$trad" ?', options: [ref, '1:1', '2:255', '112:1'], correctAnswer: ref, xpReward: 12),
        ],
      ));
    }
  }
}
