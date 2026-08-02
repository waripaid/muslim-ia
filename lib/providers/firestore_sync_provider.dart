import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../services/firebase_service.dart';
import '../services/storage_service.dart';

class FirestoreSyncProvider extends ChangeNotifier {
  final FirebaseService _firebase;
  final StorageService _storage;
  bool _isSyncing = false;
  String? _fcmToken;
  bool _notificationsEnabled = true;

  FirestoreSyncProvider({required FirebaseService firebase, required StorageService storage})
      : _firebase = firebase,
        _storage = storage;

  bool get isSyncing => _isSyncing;
  String? get fcmToken => _fcmToken;
  bool get notificationsEnabled => _notificationsEnabled;

  Future<void> initFCM() async {
    try {
      final messaging = FirebaseMessaging.instance;
      _fcmToken = await messaging.getToken();
      messaging.onTokenRefresh.listen((token) {
        _fcmToken = token;
        notifyListeners();
      });

      // Foreground notifications
      FirebaseMessaging.onMessage.listen((message) {
        debugPrint('FCM message: ${message.notification?.title}');
      });

      // Notification tap
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        debugPrint('FCM opened: ${message.data}');
      });

      notifyListeners();
    } catch (e) {
      debugPrint('FCM init failed: $e');
    }
  }

  Future<void> requestNotificationPermission() async {
    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.requestPermission(
      alert: true, badge: true, sound: true,
    );
    _notificationsEnabled = settings.authorizationStatus == AuthorizationStatus.authorized;
    notifyListeners();
  }

  // ── SYNC ──────────────────────────────────────────────────

  Future<void> syncToCloud() async {
    if (!_firebase.isAuthenticated) return;
    _isSyncing = true;
    notifyListeners();

    try {
      final prefs = _storage.prefs;
      final userData = {
        'displayName': prefs.getString('auth_name') ?? '',
        'level': prefs.getString('xp_system') != null ? (jsonDecode(prefs.getString('xp_system')!)['level'] ?? 1) : 1,
        'streak': prefs.getString('xp_system') != null ? (jsonDecode(prefs.getString('xp_system')!)['streak'] ?? 0) : 0,
      };

      // Progress
      final xpData = prefs.getString('xp_system');
      Map<String, dynamic>? progress;
      if (xpData != null) progress = jsonDecode(xpData);

      // Vocabulary
      final vocabData = prefs.getString('vocab_words');
      List<Map<String, dynamic>>? vocab;
      if (vocabData != null) vocab = (jsonDecode(vocabData) as List).cast<Map<String, dynamic>>();

      // Memorization
      final memoData = prefs.getString('memorize_verses');
      List<Map<String, dynamic>>? memo;
      if (memoData != null) memo = (jsonDecode(memoData) as List).cast<Map<String, dynamic>>();

      await _firebase.syncAll(
        userData: userData,
        progress: progress,
        vocabulary: vocab,
        memorization: memo,
      );
    } catch (e) {
      debugPrint('Sync error: $e');
    }

    _isSyncing = false;
    notifyListeners();
  }

  Future<void> syncFromCloud() async {
    if (!_firebase.isAuthenticated) return;
    _isSyncing = true;
    notifyListeners();

    try {
      final userData = await _firebase.getUserData();
      final progress = await _firebase.getProgress();
      final vocab = await _firebase.getVocabulary();
      final memo = await _firebase.getMemorization();

      final prefs = _storage.prefs;

      if (progress != null) {
        prefs.setString('xp_system', jsonEncode(progress));
      }
      if (vocab.isNotEmpty) {
        prefs.setString('vocab_words', jsonEncode(vocab));
      }
      if (memo.isNotEmpty) {
        prefs.setString('memorize_verses', jsonEncode(memo));
      }
      if (userData != null && userData['displayName'] != null) {
        prefs.setString('auth_name', userData['displayName']);
      }
    } catch (e) {
      debugPrint('Sync from cloud error: $e');
    }

    _isSyncing = false;
    notifyListeners();
  }
}
