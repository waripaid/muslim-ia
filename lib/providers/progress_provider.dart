import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/user_progress.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class ProgressProvider extends ChangeNotifier {
  final ApiService _api;
  final StorageService _storage;
  UserProgress _progress = UserProgress();
  bool _isLoading = false;

  ProgressProvider({required ApiService api, required StorageService storage})
      : _api = api,
        _storage = storage;

  UserProgress get progress => _progress;
  bool get isLoading => _isLoading;

  Future<void> loadProgress() async {
    final stored = _storage.progress;
    if (stored != null) {
      _progress = UserProgress.fromJson(jsonDecode(stored));
      notifyListeners();
    }

    try {
      final result = await _api.getProgress(_storage.userId);
      if (result['data'] != null && (result['data'] as Map).isNotEmpty) {
        _progress = UserProgress.fromJson(Map<String, dynamic>.from(result['data']));
        _storage.progress = jsonEncode(_progress.toJson());
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> updateProgress(Map<String, dynamic> data) async {
    _progress = UserProgress.fromJson({..._progress.toJson(), ...data});
    _storage.progress = jsonEncode(_progress.toJson());
    notifyListeners();

    try {
      await _api.updateProgress(_storage.userId, data);
    } catch (_) {}
  }

  Future<void> addStudyTime(int minutes) async {
    final newTime = _progress.studyTimeMinutes + minutes;
    await updateProgress({'study_time_minutes': newTime});

    if (newTime % 60 == 0 || (newTime - minutes) % 60 > newTime % 60) {
      await updateProgress({'daily_streak': _progress.dailyStreak + 1});
    }
  }
}
