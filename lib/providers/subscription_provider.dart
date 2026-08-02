import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geniuspay_flutter/geniuspay_flutter.dart';
import '../services/storage_service.dart';
import '../utils/logger.dart';

class SubscriptionProvider extends ChangeNotifier {
  final StorageService _storage;

  bool _isSubscribed = false;
  bool _trialActive = false;
  DateTime? _trialStart;
  DateTime? _subscriptionEnd;
  int _themeChanges = 0;
  bool _isProcessing = false;
  String? _paymentReference;
  String? lastPaymentError;

  static const _key = 'subscription';

  SubscriptionProvider({required StorageService storage}) : _storage = storage {
    _load();
  }

  bool get isSubscribed => _isSubscribed || _trialActive;
  bool get isPremium => _isSubscribed;
  bool get trialActive => _trialActive;
  int get themeChangesLeft => 3 - _themeChanges;
  bool get canChangeTheme => _isSubscribed || _trialActive || _themeChanges < 3;
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

  // ── GENIUSPAY SDK ──────────────────────────────────────────

  /// URLs de redirection après paiement (détectées par la WebView intégrée).
  static const successUrl = 'https://muslim-ia.web.app/payment/success';
  static const errorUrl = 'https://muslim-ia.web.app/payment/error';

  /// Crée un paiement en mode « checkout hébergé » (recommandé par GeniusPay) :
  /// l'utilisateur choisit son moyen de paiement (Wave, Orange Money, MTN,
  /// Moov, Carte) sur la page de paiement GeniusPay.
  ///
  /// Retourne l'URL de la page de paiement à ouvrir dans la WebView intégrée,
  /// ou `null` en cas d'erreur (voir [lastPaymentError]).
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
      AppLogger.info('Sub', 'Appel GeniusPay.checkout() (mode hébergé)...');
      final payment = await GeniusPay.client.checkout(
        amount: amount,
        currency: 'XOF',
        description: description,
        customer: {
          if (customerName != null && customerName.isNotEmpty) 'name': customerName,
          'email': email,
        },
        successUrl: successUrl,
        errorUrl: errorUrl,
        metadata: {'app': 'muslim_ia', 'product': 'premium', 'email': email},
      );

      _paymentReference = payment.reference;
      AppLogger.info('Sub', 'Paiement créé: reference=${payment.reference}, status=${payment.status.value}, environment=${payment.environment}');

      final url = payment.checkoutUrl ?? payment.paymentUrl;
      if (url == null || url.isEmpty) {
        AppLogger.warn('Sub', 'Aucune URL de paiement retournée par l\'API !');
        lastPaymentError = 'L\'API de paiement n\'a pas retourné de page. Réessayez.';
        return null;
      }
      AppLogger.info('Sub', 'URL de paiement à ouvrir: $url');
      return url;
    } on AuthenticationException catch (e) {
      AppLogger.error('Sub', 'AuthenticationException — clés API GeniusPay invalides', e);
      lastPaymentError = 'Clés API invalides (${e.message})';
      return null;
    } on ValidationException catch (e) {
      AppLogger.error('Sub', 'ValidationException — données de paiement invalides', e);
      lastPaymentError = 'Paiement invalide (${e.message})';
      return null;
    } on NetworkException catch (e) {
      AppLogger.error('Sub', 'NetworkException — GeniusPay injoignable (URL ou DNS)', e);
      lastPaymentError = 'Impossible de contacter GeniusPay. Vérifiez votre connexion.';
      return null;
    } on GeniusPayException catch (e) {
      AppLogger.error('Sub', 'GeniusPayException status=${e.statusCode} code=${e.code}', e);
      lastPaymentError = 'Erreur de paiement (${e.message})';
      return null;
    } catch (e) {
      AppLogger.error('Sub', 'Exception inattendue', e);
      lastPaymentError = 'Erreur inattendue: $e';
      return null;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// Enregistre la référence d'un paiement déjà créé (via GeniusPaySheet).
  void savePaymentReference(String reference) {
    _paymentReference = reference;
    lastPaymentError = null;
    notifyListeners();
  }

  /// Interroge le statut d'un paiement jusqu'à sa confirmation.
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

    // Un paiement mobile money peut prendre quelques secondes : on interroge plusieurs fois
    for (int attempt = 0; attempt < 6; attempt++) {
      try {
        AppLogger.info('Sub', 'Tentative ${attempt + 1}/6 — getPayment($_paymentReference)...');
        final payment = await GeniusPay.instance.getPayment(_paymentReference!);
        AppLogger.info('Sub', 'Réponse tentatives ${attempt + 1}: status=${payment.status.value}, gateway=${payment.gateway ?? "null"}, completedAt=${payment.completedAt ?? "null"}');

        if (payment.status.isCompleted) {
          AppLogger.success('Sub', 'PAIEMENT COMPLÉTÉ ✅ — activation de l\'abonnement (30 jours)');
          _isSubscribed = true;
          _subscriptionEnd = DateTime.now().add(const Duration(days: 30));
          _trialActive = false;
          _isProcessing = false;
          _save();
          notifyListeners();
          AppLogger.success('Sub', 'Abonnement activé jusqu\'au ${_subscriptionEnd!.toIso8601String()}');
          return true;
        }

        if (payment.status.isFailed) {
          AppLogger.warn('Sub', 'Paiement échoué: status=${payment.status.value}, failedAt=${payment.failedAt ?? "null"}');
          lastPaymentError = 'Paiement échoué par l\'opérateur. Réessayez.';
          _isProcessing = false;
          notifyListeners();
          return false;
        }

        AppLogger.info('Sub', 'Paiement encore en statut "${payment.status.value}", nouvel essai dans 3s...');
      } catch (e) {
        AppLogger.error('Sub', 'Erreur réseau/API lors de getPayment (tentative ${attempt + 1})', e);
      }
      await Future.delayed(const Duration(seconds: 3));
    }
    AppLogger.warn('Sub', '6 tentatives épuisées, paiement toujours en attente');
    lastPaymentError = 'Paiement en cours. Une fois le paiement terminé, appuyez sur « J\'ai déjà payé ».';
    _isProcessing = false;
    notifyListeners();
    return false;
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
