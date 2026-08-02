class ExerciseType {
  static const multiChoice = 'multi_choice';
  static const matchPair = 'match_pair';
  static const fillBlank = 'fill_blank';
  static const listenSelect = 'listen_select';
  static const orderWords = 'order_words';
  static const pronounce = 'pronounce';
  static const writeArabic = 'write_arabic';
}

class Exercise {
  final String id;
  final String type;
  final String question;
  final String? arabicText;
  final String? transliteration;
  final List<String>? options;
  final String correctAnswer;
  final String? explanation;
  final Map<String, String>? matchPairs; // for match_pair type
  final int xpReward;

  const Exercise({
    required this.id,
    required this.type,
    required this.question,
    this.arabicText,
    this.transliteration,
    this.options,
    required this.correctAnswer,
    this.explanation,
    this.matchPairs,
    this.xpReward = 10,
  });
}

class LessonNode {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int level;
  final List<Exercise> exercises;
  final int totalXp;
  bool completed;
  bool unlocked;
  double progress; // 0.0 to 1.0

  LessonNode({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.level,
    required this.exercises,
    this.totalXp = 50,
    this.completed = false,
    this.unlocked = false,
    this.progress = 0.0,
  });
}

class XpSystem {
  int currentXp;
  int totalXp;
  int lives;
  int streak;
  int level;
  DateTime? lastActive;

  XpSystem({
    this.currentXp = 0,
    this.totalXp = 0,
    this.lives = 5,
    this.streak = 0,
    this.level = 1,
    this.lastActive,
  });

  int get xpToNextLevel => level * 100;
  double get levelProgress => xpToNextLevel > 0 ? (currentXp % (level * 100)) / xpToNextLevel : 0;

  bool get hasLives => lives > 0;

  factory XpSystem.fromJson(Map<String, dynamic> json) => XpSystem(
        currentXp: json['currentXp'] ?? 0,
        totalXp: json['totalXp'] ?? 0,
        lives: json['lives'] ?? 5,
        streak: json['streak'] ?? 0,
        level: json['level'] ?? 1,
        lastActive: json['lastActive'] != null ? DateTime.tryParse(json['lastActive'].toString()) : null,
      );

  Map<String, dynamic> toJson() => {
        'currentXp': currentXp,
        'totalXp': totalXp,
        'lives': lives,
        'streak': streak,
        'level': level,
        'lastActive': lastActive?.toIso8601String(),
      };
}
