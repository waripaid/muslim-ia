import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../utils/admin.dart';
import '../utils/logger.dart';
import 'auth_provider.dart';

class SubscriptionProvider extends ChangeNotifier {
  final StorageService _storage;
  final ApiService _api;
  final AuthProvider _auth;

  bool _isSubscribed = false;
  bool _trialActive = false;
  DateTime? _trialStart;
  DateTime? _subscriptionEnd;
  int _themeChanges = 0;
  bool _isProcessing = false;
  String? _paymentReference;
  String? lastPaymentError;

  static const _key = 'subscription';

  SubscriptionProvider({
    required StorageService storage,
    required ApiService api,
    required AuthProvider auth,
  })  : _storage = storage,
        _api = api,
        _auth = auth {
    _load();
  }

  bool get isSubscribed => false;
  bool get isPremium => true;
  bool get trialActive => false;
  int get themeChangesLeft => 9999;
  bool get canChangeTheme => true;
  bool get isProcessing => _isProcessing;
  String? get paymentReference => _paymentReference;
  DateTime? get subscriptionEnd => _subscriptionEnd;
  DateTime? get trialStart => _trialStart;
  String get trialDaysLeft {
    if (!_trialActive || _trialStart == null) return '0';
    final end = _trialStart!.add(const Duration(days: 1));
    final remaining = end.difference(DateTime.now());
    if (remaining.isNegative) return '0';
    return '${remaining.inHours}h';
  }

  void _load() {
    AppLogger.info('Sub', 'Chargement de l\'abonnement local...');
    final data = _storage.prefs.getString(_key);
    if (data != null) {
      try {
        final d = jsonDecode(data);
        _isSubscribed = d['subscribed'] ?? false;
        _trialStart = d['trialStart'] != null ? DateTime.tryParse(d['trialStart']) : null;
        _subscriptionEnd = d['subscriptionEnd'] != null ? DateTime.tryParse(d['subscriptionEnd']) : null;
        _themeChanges = d['themeChanges'] ?? 0;

        if (_trialStart != null && !_isSubscribed) {
          final trialEnd = _trialStart!.add(const Duration(days: 1));
          _trialActive = DateTime.now().isBefore(trialEnd);
        }

        if (_isSubscribed && _subscriptionEnd != null) {
          if (DateTime.now().isAfter(_subscriptionEnd!)) {
            AppLogger.warn('Sub', 'Abonnement expiré depuis ${DateTime.now().difference(_subscriptionEnd!).inDays}j');
            _isSubscribed = false;
          }
        }
        AppLogger.info('Sub', 'Abonnement chargé: subscribed=$_isSubscribed, trial=$_trialActive, trialStart=$_trialStart, subscriptionEnd=$_subscriptionEnd');
      } catch (_) {
        AppLogger.warn('Sub', 'Données d\'abonnement corrompues, nouveau trial');
        _startTrial();
      }
    } else {
      AppLogger.info('Sub', 'Aucun abonnement stocké, démarrage du trial');
      _startTrial();
    }
  }

  void _startTrial() {
    AppLogger.success('Sub', 'Essai gratuit activé (24h)');
    _trialStart = DateTime.now();
    _trialActive = true;
    _save();
    notifyListeners();
  }

  void incrementThemeChange() {
    if (_isSubscribed || _trialActive) return;
    _themeChanges++;
    _save();
    notifyListeners();
  }

  bool tryChangeTheme() {
    if (_isSubscribed || _trialActive) return true;
    if (_themeChanges >= 3) return false;
    incrementThemeChange();
    return true;
  }

  // ── PAIEMENT (via le backend) ─────────────────────────────

  /// URLs de redirection après paiement (détectées par la WebView intégrée).
  static const successUrl = 'https://muslim-ia.web.app/payment/success';
  static const errorUrl = 'https://muslim-ia.web.app/payment/error';

  /// Crée un paiement en mode « checkout hébergé » via le backend :
  /// le secret GeniusPay reste côté serveur. Le backend renvoie l'URL de la
  /// page de paiement à ouvrir dans la WebView intégrée.
  Future<String?> createCardPayment({
    required int amount,
    required String email,
    String? customerName,
    String description = 'Abonnement Muslim IA Premium',
  }) async {
    AppLogger.start('Sub', 'createCardPayment() amount=$amount XOF, email=$email');
    if (_isProcessing) {
      AppLogger.warn('Sub', 'Paiement déjà en cours, clic ignoré');
      return null;
    }
    _isProcessing = true;
    lastPaymentError = null;
    notifyListeners();

    try {
      // Jeton rafraîchi obligatoirement : l'utilisateur a pu rester longtemps
      // sur l'écran d'abonnement, un jeton périmé serait refusé (401) par le
      // backend lors de la création du paiement.
      final idToken = await _auth.getIdToken(forceRefresh: true);
      if (idToken == null) {
        AppLogger.warn('Sub', 'Utilisateur non connecté, paiement impossible');
        lastPaymentError = 'Vous devez être connecté pour payer.';
        return null;
      }

      AppLogger.info('Sub', 'Appel backend /api/payments/checkout...');
      final res = await _api.createCheckout(
        amount: amount,
        email: email,
        customerName: customerName,
        idToken: idToken,
      );

      if (res['success'] != true || res['data'] == null) {
        final err = res['error'] ?? 'Erreur de paiement';
        AppLogger.warn('Sub', 'Backend a refusé le checkout: $err');
        lastPaymentError = err.toString();
        return null;
      }

      final data = res['data'] as Map<String, dynamic>;
      _paymentReference = data['reference'] as String?;
      AppLogger.info('Sub', 'Paiement créé côté serveur: reference=$_paymentReference, status=${data['status']}, env=${data['environment']}');

      final url = (data['checkout_url'] as String?) ?? '';
      if (url.isEmpty) {
        AppLogger.warn('Sub', 'Aucune URL de paiement retournée par le backend !');
        lastPaymentError = 'L\'API de paiement n\'a pas retourné de page. Réessayez.';
        return null;
      }
      AppLogger.info('Sub', 'URL de paiement à ouvrir: $url');
      return url;
    } catch (e) {
      AppLogger.error('Sub', 'Erreur lors de la création du paiement', e);
      lastPaymentError = 'Impossible de contacter le serveur de paiement. Vérifiez votre connexion.';
      return null;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// Enregistre la référence d'un paiement déjà créé.
  void savePaymentReference(String reference) {
    _paymentReference = reference;
    lastPaymentError = null;
    notifyListeners();
  }

  /// Interroge le statut d'un paiement via le backend jusqu'à sa confirmation.
  /// Active l'abonnement (30 jours) si le paiement est complété.
  Future<bool> checkPaymentStatus() async {
    AppLogger.info('Sub', 'checkPaymentStatus() — référence: $_paymentReference');
    if (_paymentReference == null) {
      AppLogger.warn('Sub', 'Aucune référence de paiement, vérification impossible');
      lastPaymentError = 'Aucun paiement en cours.';
      return false;
    }
    lastPaymentError = null;
    _isProcessing = true;
    notifyListeners();

    final idToken = await _auth.getIdToken(forceRefresh: true);
    if (idToken == null) {
      AppLogger.warn('Sub', 'Utilisateur non connecté, vérification impossible');
      lastPaymentError = 'Vous devez être connecté.';
      _isProcessing = false;
      notifyListeners();
      return false;
    }

    // Un paiement mobile money peut prendre quelques secondes : on interroge plusieurs fois
    for (int attempt = 0; attempt < 6; attempt++) {
      try {
        AppLogger.info('Sub', 'Tentative ${attempt + 1}/6 — backend /api/payments/status...');
        final res = await _api.getPaymentStatus(
          reference: _paymentReference!,
          idToken: idToken,
        );
        if (res['success'] != true || res['data'] == null) {
          final err = res['error'] ?? 'Erreur de statut';
          AppLogger.warn('Sub', 'Backend a refusé le statut: $err');
          lastPaymentError = err.toString();
          _isProcessing = false;
          notifyListeners();
          return false;
        }

        final data = res['data'] as Map<String, dynamic>;
        final status = (data['status'] ?? 'pending').toString();
        AppLogger.info('Sub', 'Réponse tentative ${attempt + 1}: status=$status, gateway=${data['gateway'] ?? 'null'}, completed_at=${data['completed_at'] ?? 'null'}');

        if (status == 'completed' || status == 'succeeded') {
          AppLogger.success('Sub', 'Paiement reçu (app gratuite) — aucune activation d\'abonnement');
          _isSubscribed = false;
          _subscriptionEnd = null;
          _trialActive = false;
          _isProcessing = false;
          _save();
          notifyListeners();
          return true;
        }

        if (status == 'failed' || status == 'cancelled' || status == 'expired') {
          AppLogger.warn('Sub', 'Paiement échoué: status=$status, failed_at=${data['failed_at'] ?? 'null'}');
          lastPaymentError = 'Paiement échoué par l\'opérateur. Réessayez.';
          _isProcessing = false;
          notifyListeners();
          return false;
        }

        AppLogger.info('Sub', 'Paiement encore en statut "$status", nouvel essai dans 3s...');
      } catch (e) {
        AppLogger.error('Sub', 'Erreur réseau/API lors du statut (tentative ${attempt + 1})', e);
      }
      await Future.delayed(const Duration(seconds: 3));
    }
    AppLogger.warn('Sub', '6 tentatives épuisées, paiement toujours en attente');
    lastPaymentError = 'Paiement en cours. Une fois le paiement terminé, appuyez sur « J\'ai déjà payé ».';
    _isProcessing = false;
    notifyListeners();
    return false;
  }

  /// Synchronise l'abonnement avec la source de vérité serveur (Firebase,
  /// alimentée par le webhook GeniusPay). Appelé au démarrage / changement de
  /// compte : un utilisateur payé garde son Premium même après réinstallation.
  Future<void> syncEntitlement() async {
    try {
      final idToken = await _auth.getIdToken();
      if (idToken == null) return;
      AppLogger.info('Sub', 'Sync entitlement serveur...');
      final res = await _api.getEntitlement(idToken);
      final data = res['data'] as Map<String, dynamic>?;
      final serverPremium = data?['isPremium'] == true;
      final serverEnd = data?['premiumEnd'] != null
          ? DateTime.tryParse(data!['premiumEnd'].toString())
          : null;

      // App gratuite pour tous : supprimer tout statut d'abonnement
      if (_isSubscribed || _subscriptionEnd != null || _trialActive) {
        _isSubscribed = false;
        _subscriptionEnd = null;
        _trialActive = false;
        _save();
        notifyListeners();
      }
    } catch (e) {
      AppLogger.warn('Sub', 'Sync entitlement indisponible: $e');
    }
  }

  void _save() {
    _storage.prefs.setString(_key, jsonEncode({
      'subscribed': _isSubscribed,
      'trialStart': _trialStart?.toIso8601String(),
      'subscriptionEnd': _subscriptionEnd?.toIso8601String(),
      'themeChanges': _themeChanges,
    }));
    AppLogger.info('Sub', 'Abonnement sauvegardé localement: subscribed=$_isSubscribed, subscriptionEnd=$_subscriptionEnd');
  }
}
