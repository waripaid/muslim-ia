import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';

class VocabWord {
  String arabic;
  String transliteration;
  String french;
  String? root;
  String? type;
  String? example;
  int level; // 0=new, 1=learning, 2=review, 3=mastered
  DateTime nextReview;
  int correctCount;
  int wrongCount;

  VocabWord({
    required this.arabic,
    required this.transliteration,
    required this.french,
    this.root,
    this.type,
    this.example,
    this.level = 0,
    DateTime? nextReview,
    this.correctCount = 0,
    this.wrongCount = 0,
  }) : nextReview = nextReview ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'arabic': arabic, 'transliteration': transliteration, 'french': french,
        'root': root, 'type': type, 'example': example, 'level': level,
        'nextReview': nextReview.toIso8601String(), 'correctCount': correctCount, 'wrongCount': wrongCount,
      };

  factory VocabWord.fromJson(Map<String, dynamic> json) => VocabWord(
        arabic: json['arabic'] ?? '',
        transliteration: json['transliteration'] ?? '',
        french: json['french'] ?? '',
        root: json['root'],
        type: json['type'],
        example: json['example'],
        level: json['level'] ?? 0,
        nextReview: json['nextReview'] != null ? DateTime.tryParse(json['nextReview']) : null,
        correctCount: json['correctCount'] ?? 0,
        wrongCount: json['wrongCount'] ?? 0,
      );

  void markCorrect() {
    correctCount++;
    level = min(3, level + 1);
    final intervals = [1, 3, 7, 30];
    nextReview = DateTime.now().add(Duration(days: intervals[level]));
  }

  void markWrong() {
    wrongCount++;
    level = max(0, level - 1);
    nextReview = DateTime.now().add(const Duration(hours: 4));
  }

  double get mastery => level / 3.0;
}

class VocabularyProvider extends ChangeNotifier {
  final StorageService _storage;
  List<VocabWord> _words = [];
  static const _key = 'vocab_words';

  VocabularyProvider({required StorageService storage}) : _storage = storage;

  List<VocabWord> get words => _words;
  List<VocabWord> get wordsToReview => _words.where((w) => w.nextReview.isBefore(DateTime.now())).toList();
  List<VocabWord> get newWords => _words.where((w) => w.level == 0).toList();
  List<VocabWord> get mastered => _words.where((w) => w.level >= 3).toList();

  void init() {
    final data = _storage.prefs.getString(_key);
    if (data != null) {
      try {
        final list = jsonDecode(data) as List;
        _words = list.map((j) => VocabWord.fromJson(j)).toList();
      } catch (_) {
        _addDefaults();
      }
    } else {
      _addDefaults();
    }
  }

  void _addDefaults() {
    addWord(VocabWord(arabic: 'كتاب', transliteration: 'Kitab', french: 'Livre', root: 'ك ت ب', type: 'Nom'));
    addWord(VocabWord(arabic: 'رب', transliteration: 'Rabb', french: 'Seigneur', root: 'ر ب ب', type: 'Nom'));
    addWord(VocabWord(arabic: 'رحمن', transliteration: 'Rahman', french: 'Miséricordieux', root: 'ر ح م', type: 'Adjectif'));
    addWord(VocabWord(arabic: 'علم', transliteration: 'Ilm', french: 'Savoir', root: 'ع ل م', type: 'Nom'));
    addWord(VocabWord(arabic: 'نور', transliteration: 'Nur', french: 'Lumière', root: 'ن و ر', type: 'Nom'));
    addWord(VocabWord(arabic: 'سلام', transliteration: 'Salam', french: 'Paix', root: 'س ل م', type: 'Nom'));
    addWord(VocabWord(arabic: 'حمد', transliteration: 'Hamd', french: 'Louange', root: 'ح م د', type: 'Nom'));
    addWord(VocabWord(arabic: 'هدى', transliteration: 'Huda', french: 'Guidance', root: 'ه د ي', type: 'Nom'));
    addWord(VocabWord(arabic: 'حق', transliteration: 'Haqq', french: 'Vérité', root: 'ح ق ق', type: 'Nom'));
    addWord(VocabWord(arabic: 'صبر', transliteration: 'Sabr', french: 'Patience', root: 'ص ب ر', type: 'Nom'));
  }

  void addWord(VocabWord word) {
    _words.add(word);
    _save();
    notifyListeners();
  }

  void removeWord(VocabWord word) {
    _words.removeWhere((w) => w.arabic == word.arabic);
    _save();
    notifyListeners();
  }

  void markCorrect(VocabWord word) {
    word.markCorrect();
    _save();
    notifyListeners();
  }

  void markWrong(VocabWord word) {
    word.markWrong();
    _save();
    notifyListeners();
  }

  bool hasWord(String arabic) => _words.any((w) => w.arabic == arabic);

  void _save() {
    _storage.prefs.setString(_key, jsonEncode(_words.map((w) => w.toJson()).toList()));
  }
}
