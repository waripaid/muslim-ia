class UserProgress {
  String level;
  int wordsLearned;
  int versesUnderstood;
  int studyTimeMinutes;
  int dailyStreak;
  int quizScore;
  int totalWords;
  int dayNumber;

  UserProgress({
    this.level = 'beginner',
    this.wordsLearned = 0,
    this.versesUnderstood = 0,
    this.studyTimeMinutes = 0,
    this.dailyStreak = 0,
    this.quizScore = 0,
    this.totalWords = 2000,
    this.dayNumber = 1,
  });

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      level: json['level'] ?? 'beginner',
      wordsLearned: (json['words_learned'] ?? 0).toInt(),
      versesUnderstood: (json['verses_understood'] ?? 0).toInt(),
      studyTimeMinutes: (json['study_time_minutes'] ?? 0).toInt(),
      dailyStreak: (json['daily_streak'] ?? 0).toInt(),
      quizScore: (json['quiz_score'] ?? 0).toInt(),
      totalWords: (json['total_words'] ?? 2000).toInt(),
      dayNumber: (json['day_number'] ?? 1).toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
        'level': level,
        'words_learned': wordsLearned,
        'verses_understood': versesUnderstood,
        'study_time_minutes': studyTimeMinutes,
        'daily_streak': dailyStreak,
        'quiz_score': quizScore,
        'total_words': totalWords,
        'day_number': dayNumber,
      };

  String get levelLabel {
    switch (level) {
      case 'beginner':
        return 'Débutant';
      case 'intermediate':
        return 'Intermédiaire';
      case 'advanced':
        return 'Avancé';
      default:
        return 'Débutant';
    }
  }

  double get wordProgress => totalWords > 0 ? wordsLearned / totalWords : 0;
}
