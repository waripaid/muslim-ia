import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  bool unlocked;
  DateTime? unlockedAt;

  Achievement({required this.id, required this.title, required this.description, required this.icon, this.unlocked = false, this.unlockedAt});

  Map<String, dynamic> toJson() => {'id': id, 'unlocked': unlocked, 'unlockedAt': unlockedAt?.toIso8601String()};
  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(id: json['id'] ?? '', title: json['title'] ?? '', description: json['description'] ?? '', icon: json['icon'] ?? '', unlocked: json['unlocked'] ?? false, unlockedAt: json['unlockedAt'] != null ? DateTime.tryParse(json['unlockedAt']) : null);
}

class MemorizeVerse {
  final String reference;
  final String arabic;
  final String translation;
  final String translationEn;
  final String sourateName;
  int level; // 0-4
  DateTime nextReview;
  int correctCount;

  MemorizeVerse({required this.reference, required this.arabic, required this.translation, this.translationEn = '', required this.sourateName, this.level = 0, DateTime? nextReview, this.correctCount = 0}) : nextReview = nextReview ?? DateTime.now();

  Map<String, dynamic> toJson() => {'reference': reference, 'arabic': arabic, 'translation': translation, 'translationEn': translationEn, 'sourateName': sourateName, 'level': level, 'nextReview': nextReview.toIso8601String(), 'correctCount': correctCount};
  factory MemorizeVerse.fromJson(Map<String, dynamic> json) => MemorizeVerse(reference: json['reference'] ?? '', arabic: json['arabic'] ?? '', translation: json['translation'] ?? '', translationEn: json['translationEn'] ?? '', sourateName: json['sourateName'] ?? '', level: json['level'] ?? 0, nextReview: json['nextReview'] != null ? DateTime.tryParse(json['nextReview']) : null, correctCount: json['correctCount'] ?? 0);

  String translationFor(String lang) => (lang == 'en' && translationEn.isNotEmpty) ? translationEn : translation;

  void markCorrect() { correctCount++; level = (level + 1).clamp(0, 4); final ints = [1, 3, 7, 14, 30]; nextReview = DateTime.now().add(Duration(days: ints[level])); }
  void markWrong() { level = (level - 1).clamp(0, 4); nextReview = DateTime.now().add(const Duration(hours: 8)); }
}

class MemorizeProvider extends ChangeNotifier {
  final StorageService _storage;
  List<MemorizeVerse> _verses = [];
  static const _keyVerses = 'memorize_verses';
  static const _keyAchievements = 'achievements';

  List<Achievement> _achievements = [];
  final Set<String> _unseenAchievements = {};

  MemorizeProvider({required StorageService storage}) : _storage = storage;

  List<MemorizeVerse> get verses => _verses;
  List<MemorizeVerse> get toReview => _verses.where((v) => v.nextReview.isBefore(DateTime.now())).toList();
  List<MemorizeVerse> get memorized => _verses.where((v) => v.level >= 4).toList();
  List<Achievement> get achievements => _achievements;
  List<Achievement> get unlocked => _achievements.where((a) => a.unlocked).toList();

  void init() {
    _loadVerses();
    _initAchievements();
    _refreshFromData();
  }

  void _refreshFromData() {
    // Check from stored lesson data
    final lessonData = _storage.prefs.getString('lessons_progress');
    if (lessonData != null) {
      final list = jsonDecode(lessonData) as List;
      final completed = list.where((l) => l['completed'] == true).length;
      checkLessonAchievements(completed);
    }
    // Check from stored XP
    final xpData = _storage.prefs.getString('xp_system');
    if (xpData != null) {
      final xp = jsonDecode(xpData);
      final streak = xp['streak'] ?? 0;
      if (streak >= 3) unlock('streak_3');
      if (streak >= 7) unlock('streak_7');
      if (streak >= 30) unlock('streak_30');
    }
    // Check words
    final wordData = _storage.prefs.getString('vocab_words');
    if (wordData != null) {
      final words = jsonDecode(wordData) as List;
      if (words.length >= 25) unlock('words_25');
      if (words.length >= 100) unlock('words_100');
    }
  }

  void _loadVerses() {
    final data = _storage.prefs.getString(_keyVerses);
    if (data != null) {
      _verses = (jsonDecode(data) as List).map((j) => MemorizeVerse.fromJson(j)).toList();
    } else {
      _addDefaults();
    }
  }

  void _addDefaults() {
    addVerse(MemorizeVerse(reference: '1:1-7', sourateName: 'Al-Fatiha', arabic: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ\nالْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ\nالرَّحْمَٰنِ الرَّحِيمِ\nمَالِكِ يَوْمِ الدِّينِ\nإِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ\nاهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ\nصِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ', translation: 'Au nom d\'Allah, le Tout Miséricordieux, le Très Miséricordieux.\nLouange à Allah, Seigneur de l\'univers...', translationEn: 'In the name of Allah, the Entirely Merciful, the Especially Merciful.\nAll praise is due to Allah, Lord of the worlds...'));
    addVerse(MemorizeVerse(reference: '112:1-4', sourateName: 'Al-Ikhlas', arabic: 'قُلْ هُوَ اللَّهُ أَحَدٌ\nاللَّهُ الصَّمَدُ\nلَمْ يَلِدْ وَلَمْ يُولَدْ\nوَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ', translation: 'Dis: "Il est Allah, Unique.\nAllah, Le Seul à être imploré...', translationEn: 'Say, "He is Allah, [who is] One.\nAllah, the Eternal Refuge...'));
    addVerse(MemorizeVerse(reference: '113:1-5', sourateName: 'Al-Falaq', arabic: 'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ\nمِن شَرِّ مَا خَلَقَ...', translation: 'Dis: "Je cherche protection auprès du Seigneur de l\'aube...', translationEn: 'Say, "I seek refuge in the Lord of the daybreak...'));
    addVerse(MemorizeVerse(reference: '114:1-6', sourateName: 'An-Nas', arabic: 'قُلْ أَعُوذُ بِرَبِّ النَّاسِ\nمَلِكِ النَّاسِ...', translation: 'Dis: "Je cherche protection auprès du Seigneur des hommes...', translationEn: 'Say, "I seek refuge in the Lord of mankind...'));
    addVerse(MemorizeVerse(reference: '2:255', sourateName: 'Al-Baqara', arabic: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ...', translation: 'Allah! Point de divinité à part Lui, le Vivant...', translationEn: 'Allah - there is no deity except Him, the Ever-Living...'));
    addVerse(MemorizeVerse(reference: '103:1-3', sourateName: 'Al-Asr', arabic: 'وَالْعَصْرِ\nإِنَّ الْإِنسَانَ لَفِي خُسْرٍ\nإِلَّا الَّذِينَ آمَنُوا وَعَمِلُوا الصَّالِحَاتِ...', translation: 'Par le temps ! L\'homme est certes en perdition, sauf ceux qui croient...', translationEn: 'By time! Indeed, mankind is in loss, except for those who believe and do righteous deeds...'));
    addVerse(MemorizeVerse(reference: '108:1-3', sourateName: 'Al-Kawthar', arabic: 'إِنَّا أَعْطَيْنَاكَ الْكَوْثَرَ\nفَصَلِّ لِرَبِّكَ وَانْحَرْ\nإِنَّ شَانِئَكَ هُوَ الْأَبْتَرُ', translation: 'Nous t\'avons certes accordé l\'Abondance...', translationEn: 'Indeed, We have granted you al-Kawthar. So pray to your Lord and sacrifice [to Him alone]...'));
    addVerse(MemorizeVerse(reference: '109:1-6', sourateName: 'Al-Kafirun', arabic: 'قُلْ يَا أَيُّهَا الْكَافِرُونَ\nلَا أَعْبُدُ مَا تَعْبُدُونَ...', translation: 'Dis : Ô vous les infidèles ! Je n\'adore pas ce que vous adorez...', translationEn: 'Say, "O disbelievers! I do not worship what you worship..."'));
    addVerse(MemorizeVerse(reference: '110:1-3', sourateName: 'An-Nasr', arabic: 'إِذَا جَاءَ نَصْرُ اللَّهِ وَالْفَتْحُ\nوَرَأَيْتَ النَّاسَ يَدْخُلُونَ فِي دِينِ اللَّهِ أَفْوَاجًا...', translation: 'Lorsque vient le secours d\'Allah ainsi que la victoire...', translationEn: 'When the victory of Allah has come and the conquest...'));
    addVerse(MemorizeVerse(reference: '97:1-5', sourateName: 'Al-Qadr', arabic: 'إِنَّا أَنزَلْنَاهُ فِي لَيْلَةِ الْقَدْرِ\nوَمَا أَدْرَاكَ مَا لَيْلَةُ الْقَدْرِ...', translation: 'Nous l\'avons certes fait descendre pendant la Nuit du Destin...', translationEn: 'Indeed, We sent it down during the Night of Decree...'));
  }

  void addVerse(MemorizeVerse verse) { _verses.add(verse); _save(); notifyListeners(); }

  void markCorrect(MemorizeVerse v) { v.markCorrect(); _checkAchievements(); _save(); notifyListeners(); }
  void markWrong(MemorizeVerse v) { v.markWrong(); _save(); notifyListeners(); }

  void _save() { _storage.prefs.setString(_keyVerses, jsonEncode(_verses.map((v) => v.toJson()).toList())); }

  // Achievements
  void _initAchievements() {
    _achievements = [
      Achievement(id: 'first_lesson', title: 'Premier pas', description: 'Terminer 1 leçon', icon: '🎯'),
      Achievement(id: 'five_lessons', title: 'Apprenti', description: 'Terminer 5 leçons', icon: '📚'),
      Achievement(id: 'ten_lessons', title: 'Savant', description: 'Terminer 10 leçons', icon: '🎓'),
      Achievement(id: 'streak_3', title: 'Régulier', description: 'Streak de 3 jours', icon: '🔥'),
      Achievement(id: 'streak_7', title: 'Assidu', description: 'Streak de 7 jours', icon: '💪'),
      Achievement(id: 'streak_30', title: 'Inarrêtable', description: 'Streak de 30 jours', icon: '⚡'),
      Achievement(id: 'words_25', title: 'Vocabulaire', description: '25 mots appris', icon: '📝'),
      Achievement(id: 'words_100', title: 'Lexique', description: '100 mots appris', icon: '📖'),
      Achievement(id: 'verse_1', title: 'Mémorisation', description: '1er verset mémorisé', icon: '🧠'),
      Achievement(id: 'verse_5', title: 'Hafiz en herbe', description: '5 versets mémorisés', icon: '🌟'),
      Achievement(id: 'first_search', title: 'Explorateur', description: '1ère recherche dans le Coran', icon: '🔍'),
      Achievement(id: 'first_chat', title: 'Curieux', description: '1ère question à l\'IA', icon: '💬'),
    ];
    _loadAchievements();
  }

  void _loadAchievements() {
    final data = _storage.prefs.getString(_keyAchievements);
    if (data != null) {
      final list = jsonDecode(data) as List;
      for (final j in list) {
        final a = _achievements.firstWhere((x) => x.id == j['id'], orElse: () => Achievement(id: '', title: '', description: '', icon: ''));
        if (a.id.isNotEmpty) { a.unlocked = j['unlocked'] ?? false; if (j['unlockedAt'] != null) a.unlockedAt = DateTime.tryParse(j['unlockedAt']); }
      }
    }
  }

  void unlock(String id) {
    final a = _achievements.firstWhere((x) => x.id == id, orElse: () => Achievement(id: '', title: '', description: '', icon: ''));
    if (a.id.isEmpty || a.unlocked) return;
    a.unlocked = true;
    a.unlockedAt = DateTime.now();
    _unseenAchievements.add(id);
    _saveAchievements();
    notifyListeners();
  }

  Set<String> popUnseenAchievements() {
    final unseen = Set<String>.from(_unseenAchievements);
    _unseenAchievements.clear();
    return unseen;
  }

  void _checkAchievements() {
    if (_verses.any((v) => v.level >= 4)) unlock('verse_1');
    if (_verses.where((v) => v.level >= 4).length >= 5) unlock('verse_5');
  }

  void checkLessonAchievements(int completed) {
    if (completed >= 1) unlock('first_lesson');
    if (completed >= 5) unlock('five_lessons');
    if (completed >= 10) unlock('ten_lessons');
  }

  void _saveAchievements() {
    _storage.prefs.setString(_keyAchievements, jsonEncode(_achievements.map((a) => a.toJson()).toList()));
  }
}
