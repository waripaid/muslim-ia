import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Suit l'état de connexion réseau pour informer l'utilisateur quand il est
/// hors ligne (avion, Wi-Fi/4G coupés, etc.).
class InternetStatusProvider extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _sub;
  bool _isOffline = false;

  bool get isOffline => _isOffline;

  Future<void> init() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _apply(results);
      _sub = _connectivity.onConnectivityChanged.listen(_apply);
    } catch (e) {
      debugPrint('InternetStatusProvider: init erreur $e');
    }
  }

  void _apply(List<ConnectivityResult> results) {
    final offline =
        results.isEmpty || results.every((r) => r == ConnectivityResult.none);
    if (offline != _isOffline) {
      _isOffline = offline;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
