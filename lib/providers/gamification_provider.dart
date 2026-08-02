import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';

class LeagueInfo {
  final String name;
  final String icon;
  final int minXp;
  final int maxXp;
  final int gemsReward;

  const LeagueInfo(this.name, this.icon, this.minXp, this.maxXp, this.gemsReward);
}

class GamificationProvider extends ChangeNotifier {
  final StorageService _storage;
  final Random _random = Random();

  // Ligues
  static const leagues = [
    LeagueInfo('Bronze', '🥉', 0, 200, 5),
    LeagueInfo('Argent', '🥈', 200, 500, 10),
    LeagueInfo('Or', '🥇', 500, 1000, 15),
    LeagueInfo('Saphir', '💎', 1000, 2000, 25),
    LeagueInfo('Rubis', '❤️', 2000, 3500, 40),
    LeagueInfo('Émeraude', '💚', 3500, 5500, 60),
    LeagueInfo('Améthyste', '💜', 5500, 8000, 80),
    LeagueInfo('Perle', '🤍', 8000, 12000, 100),
    LeagueInfo('Obsidienne', '🖤', 12000, 18000, 150),
    LeagueInfo('Diamant', '💠', 18000, 999999, 250),
  ];

  int _leagueIndex = 0;
  int _weeklyXp = 0;
  int _gems = 0;
  bool _streakFreezeActive = false;
  bool _xpBoostActive = false;
  DateTime? _boostEndTime;
  int _dailyChestDay = -1;
  bool _dailyChestOpened = false;
  List<Map<String, dynamic>> _leaderboard = [];
  int _promotions = 0;
  int _demotions = 0;

  static const _key = 'gamification';

  GamificationProvider({required StorageService storage}) : _storage = storage;

  LeagueInfo get currentLeague => leagues[_leagueIndex];
  int get leagueIndex => _leagueIndex;
  int get weeklyXp => _weeklyXp;
  int get gems => _gems;
  bool get hasBoost => _xpBoostActive && (_boostEndTime?.isAfter(DateTime.now()) ?? false);
  bool get hasStreakFreeze => _streakFreezeActive;
  bool get dailyChestOpened => _dailyChestOpened;
  bool get canOpenChest => !_dailyChestOpened || _dailyChestDay != DateTime.now().weekday;
  List<Map<String, dynamic>> get leaderboard => _leaderboard;
  int get promotions => _promotions;
  int get demotions => _demotions;
  int get xpMultiplier => hasBoost ? 2 : 1;

  void init() {
    _load();
    _checkNewWeek();
    _generateLeaderboard();
    _checkDailyReset();
  }

  void _checkNewWeek() {
    final now = DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day - (now.weekday - 1));
    final stored = _storage.prefs.getString('week_start');
    if (stored != weekStart.toIso8601String().substring(0, 10)) {
      _storage.prefs.setString('week_start', weekStart.toIso8601String().substring(0, 10));
      _applyWeeklyResults();
      _weeklyXp = 0;
      _dailyChestDay = -1;
      _dailyChestOpened = false;
      _generateLeaderboard();
    }
  }

  void _checkDailyReset() {
    final today = DateTime.now().weekday;
    if (_dailyChestDay != today) {
      _dailyChestOpened = false;
    }
  }

  void _applyWeeklyResults() {
    if (_leaderboard.isEmpty) return;
    _leaderboard.sort((a, b) => (b['xp'] as int).compareTo(a['xp'] as int));
    final myRank = _leaderboard.indexWhere((e) => e['me'] == true);
    if (myRank < 0) return;

    // Top 7 promote, bottom 5 demote
    if (myRank <= 6 && _leagueIndex < leagues.length - 1) {
      _leagueIndex++;
      _promotions++;
    } else if (myRank >= _leaderboard.length - 5 && _leagueIndex > 0) {
      _leagueIndex--;
      _demotions++;
    }

    // Gems reward
    _gems += currentLeague.gemsReward * (myRank <= 6 ? 2 : 1);
    _save();
  }

  void _generateLeaderboard() {
    _leaderboard = [];
    // Add the user
    _leaderboard.add({'name': 'Vous', 'xp': _weeklyXp, 'me': true});
    // Add bots
    final botNames = ['Fatima', 'Omar', 'Aisha', 'Ali', 'Zaynab', 'Hassan', 'Khadija', 'Bilal',
      'Maryam', 'Yusuf', 'Sara', 'Ibrahim', 'Nur', 'Hamza', 'Layla', 'Amir', 'Sofia', 'Tariq', 'Huda', 'Rashid'];
    for (final name in botNames) {
      _leaderboard.add({
        'name': name,
        'xp': _weeklyXp + _random.nextInt(200) - 100 + _random.nextInt(currentLeague.maxXp ~/ 3),
        'me': false,
      });
    }
    _leaderboard.sort((a, b) => (b['xp'] as int).compareTo(a['xp'] as int));
  }

  void addXp(int baseXp) {
    final xp = baseXp * xpMultiplier;
    _weeklyXp += xp;
    _save();
    notifyListeners();
  }

  void openDailyChest() {
    if (_dailyChestOpened) return;
    _dailyChestOpened = true;
    _dailyChestDay = DateTime.now().weekday;
    final reward = 5 + _random.nextInt(15) + _leagueIndex * 2;
    _gems += reward;
    _save();
    notifyListeners();
  }

  bool buyBoost() {
    final cost = 30;
    if (_gems < cost || hasBoost) return false;
    _gems -= cost;
    _xpBoostActive = true;
    _boostEndTime = DateTime.now().add(const Duration(minutes: 15));
    _save();
    notifyListeners();
    // Auto-disable after 15 min
    Future.delayed(const Duration(minutes: 15), () {
      _xpBoostActive = false;
      _boostEndTime = null;
      _save();
      notifyListeners();
    });
    return true;
  }

  bool buyStreakFreeze() {
    final cost = 50;
    if (_gems < cost || _streakFreezeActive) return false;
    _gems -= cost;
    _streakFreezeActive = true;
    _save();
    notifyListeners();
    return true;
  }

  bool useStreakFreeze() {
    if (!_streakFreezeActive) return false;
    _streakFreezeActive = false;
    _save();
    notifyListeners();
    return true;
  }

  void _save() {
    _storage.prefs.setString(_key, jsonEncode({
      'leagueIndex': _leagueIndex, 'weeklyXp': _weeklyXp, 'gems': _gems,
      'streakFreeze': _streakFreezeActive, 'xpBoost': _xpBoostActive,
      'boostEnd': _boostEndTime?.toIso8601String(), 'chestDay': _dailyChestDay,
      'chestOpened': _dailyChestOpened, 'leaderboard': _leaderboard,
      'promotions': _promotions, 'demotions': _demotions,
    }));
  }

  void _load() {
    final data = _storage.prefs.getString(_key);
    if (data == null) return;
    try {
      final d = jsonDecode(data);
      _leagueIndex = d['leagueIndex'] ?? 0;
      _weeklyXp = d['weeklyXp'] ?? 0;
      _gems = d['gems'] ?? 0;
      _streakFreezeActive = d['streakFreeze'] ?? false;
      _xpBoostActive = d['xpBoost'] ?? false;
      _boostEndTime = d['boostEnd'] != null ? DateTime.tryParse(d['boostEnd']) : null;
      _dailyChestDay = d['chestDay'] ?? -1;
      _dailyChestOpened = d['chestOpened'] ?? false;
      _leaderboard = (d['leaderboard'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      _promotions = d['promotions'] ?? 0;
      _demotions = d['demotions'] ?? 0;
    } catch (_) {}
  }
}
