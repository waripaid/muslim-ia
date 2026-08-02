import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _keyHistory = 'chat_history';
  static const _keyProgress = 'user_progress';
  static const _keyUserId = 'local_user_id';

  late SharedPreferences _prefs;

  SharedPreferences get prefs => _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  String get userId {
    final stored = _prefs.getString(_keyUserId);
    if (stored == null) {
      final newId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      _prefs.setString(_keyUserId, newId);
      return newId;
    }
    return stored;
  }

  List<String> get history => _prefs.getStringList(_keyHistory) ?? [];

  void addToHistory(String messageJson) {
    final current = history;
    current.add(messageJson);
    if (current.length > 200) current.removeAt(0);
    _prefs.setStringList(_keyHistory, current);
  }

  void clearHistory() => _prefs.remove(_keyHistory);

  String? get progress => _prefs.getString(_keyProgress);
  set progress(String? value) {
    if (value != null) {
      _prefs.setString(_keyProgress, value);
    } else {
      _prefs.remove(_keyProgress);
    }
  }
}
