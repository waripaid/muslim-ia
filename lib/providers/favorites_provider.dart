import 'package:flutter/foundation.dart';
import '../models/favorite.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class FavoritesProvider extends ChangeNotifier {
  final ApiService _api;
  final StorageService _storage;
  List<Favorite> _favorites = [];
  bool _isLoading = false;

  FavoritesProvider({required ApiService api, required StorageService storage})
      : _api = api,
        _storage = storage;

  List<Favorite> get favorites => _favorites;
  bool get isLoading => _isLoading;

  Future<void> loadFavorites() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _api.getFavorites(_storage.userId);
      _favorites = data.map((j) => Favorite.fromJson(j)).toList();
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addFavorite({
    required String sourate,
    required String verset,
    String texteArabe = '',
    String traduction = '',
    String notes = '',
  }) async {
    final exists = _favorites.any((f) => f.sourate == sourate && f.verset == verset);
    if (exists) return false;

    try {
      final result = await _api.addFavorite(
        userId: _storage.userId,
        sourate: sourate,
        verset: verset,
        texteArabe: texteArabe,
        traduction: traduction,
        notes: notes,
      );
      if (result['success'] == true || result['id'] != null) {
        await loadFavorites();
        return true;
      }
    } catch (_) {}

    return false;
  }

  Future<void> removeFavorite(String id) async {
    try {
      await _api.removeFavorite(id);
      _favorites.removeWhere((f) => f.id == id);
      notifyListeners();
    } catch (_) {}
  }

  bool isFavorite(String sourate, String verset) {
    return _favorites.any((f) => f.sourate == sourate && f.verset == verset);
  }
}
