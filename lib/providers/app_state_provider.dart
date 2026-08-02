import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class AppStateProvider extends ChangeNotifier {
  final StorageService _storage;
  ThemeMode _themeMode = ThemeMode.dark; // Sombre par défaut
  bool _notificationsEnabled = true;
  int _themeChangeCount = 0;
  int _maxFreeThemeChanges = 3;

  static const _keyTheme = 'theme_mode';

  AppStateProvider({required StorageService storage}) : _storage = storage {
    _load();
  }

  ThemeMode get themeMode => _themeMode;
  bool get notificationsEnabled => _notificationsEnabled;
  int get themeChangesLeft => _maxFreeThemeChanges - _themeChangeCount;

  void _load() {
    final stored = _storage.prefs.getString(_keyTheme);
    if (stored == 'dark') _themeMode = ThemeMode.dark;
    _themeChangeCount = _storage.prefs.getInt('theme_changes') ?? 0;
  }

  bool canChangeTheme(bool isPremium) {
    if (isPremium) return true;
    return _themeChangeCount < _maxFreeThemeChanges;
  }

  bool toggleTheme({bool isPremium = false}) {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    _storage.prefs.setString(_keyTheme, _themeMode == ThemeMode.dark ? 'dark' : 'light');
    notifyListeners();
    return true;
  }

  void setTheme(ThemeMode mode) {
    _themeMode = mode;
    _storage.prefs.setString(_keyTheme, mode == ThemeMode.dark ? 'dark' : 'light');
    notifyListeners();
  }

  void toggleNotifications() {
    _notificationsEnabled = !_notificationsEnabled;
    notifyListeners();
  }
}
