import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../utils/logger.dart';

enum AuthState { loading, loggedOut, loggedIn, emailVerification }

class AuthProvider extends ChangeNotifier {
  final StorageService _storage;
  final FirebaseAuth _firebaseAuth;
  final ApiService? _api;
  final bool requireEmailVerification;
  AuthState _state = AuthState.loading;
  String? _userId;
  String? _fullName;
  String? _email;

  AuthProvider({
    required StorageService storage,
    ApiService? api,
    this.requireEmailVerification = false,
  })  : _storage = storage,
        _api = api,
        _firebaseAuth = FirebaseAuth.instance {
    _checkAuth();
    _firebaseAuth.authStateChanges().listen(_onFirebaseAuthChange);
  }

  static const String _verifyContinueUrl =
      'https://muslim-ia.firebaseapp.com/verify';

  static ActionCodeSettings _verifyEmailSettings() => ActionCodeSettings(
        url: _verifyContinueUrl,
        handleCodeInApp: true,
        androidPackageName: 'com.muslim_ia.app',
        androidInstallApp: true,
      );

  AuthState get state => _state;
  bool get isLoggedIn => _state == AuthState.loggedIn;
  String? get fullName => _fullName;
  String? get email => _email;
  String? get userId => _userId;

  bool get isEmailVerified =>
      _firebaseAuth.currentUser?.emailVerified ?? false;

  /// Retourne le jeton d'identification Firebase actuel (pour les appels
  /// authentifiés au backend), ou null si non connecté.
  Future<String?> getIdToken() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    try {
      return await user.getIdToken();
    } catch (e) {
      AppLogger.warn('Auth', 'getIdToken échoué: $e');
      return null;
    }
  }

  void _onFirebaseAuthChange(User? user) {
    if (user != null) {
      AppLogger.info('Auth', 'Changement d\'état: connecté (${user.email})');
      _userId = user.uid;
      _fullName = user.displayName ?? _storage.prefs.getString('auth_name');
      _email = user.email;
      final verified = user.emailVerified;
      if (!requireEmailVerification || verified) {
        _state = AuthState.loggedIn;
      } else if (_state != AuthState.emailVerification) {
        _state = AuthState.emailVerification;
      }
      _storage.prefs.setString('auth_user', jsonEncode({
        'id': user.uid, 'name': _fullName, 'email': _email,
      }));
      notifyListeners();
    }
  }

  void _checkAuth() {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser != null) {
      _userId = currentUser.uid;
      _fullName = currentUser.displayName ?? _storage.prefs.getString('auth_name');
      _email = currentUser.email;
      _state = (!requireEmailVerification || currentUser.emailVerified)
          ? AuthState.loggedIn
          : AuthState.emailVerification;
      notifyListeners();
      return;
    }

    // Fallback: local auth
    final userData = _storage.prefs.getString('auth_user');
    if (userData != null) {
      try {
        final data = jsonDecode(userData);
        _userId = data['id'];
        _fullName = data['name'];
        _email = data['email'];
      _state = AuthState.loggedIn;
      AppLogger.success('Auth', 'Inscription réussie: $email');
      notifyListeners();
        return;
      } catch (_) {}
    }
    _state = AuthState.loggedOut;
    notifyListeners();
  }

  Future<String?> register({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    AppLogger.info('Auth', 'Tentative d\'inscription: $email');
    if (fullName.trim().length < 2) return 'Le nom doit contenir au moins 2 caractères';
    if (!email.contains('@')) return 'Email invalide';
    if (password.length < 6) return 'Mot de passe : minimum 6 caractères';
    if (password != confirmPassword) return 'Les mots de passe ne correspondent pas';

    try {
      // Firebase Auth
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await credential.user?.updateDisplayName(fullName.trim());

      // Créer le document Firestore
      try {
        await FirebaseFirestore.instance.collection('users').doc(credential.user!.uid).set({
          'displayName': fullName.trim(),
          'email': email.trim(),
          'createdAt': FieldValue.serverTimestamp(),
          'level': 1,
          'xp': 0,
          'streak': 0,
          'messagesSent': 0,
          'subscription': 'trial',
        }, SetOptions(merge: true));
      } catch (_) {}

      // Envoyer l'email de vérification (backend + repli Firebase)
      if (requireEmailVerification) {
        await _sendVerificationEmail();
      }

      _userId = credential.user!.uid;
      _fullName = fullName.trim();
      _email = email.trim();
      _state = requireEmailVerification
          ? AuthState.emailVerification
          : AuthState.loggedIn;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Auth', 'Erreur d\'inscription Firebase', e);
      return _firebaseError(e.code);
    } catch (e) {
      AppLogger.error('Auth', 'Erreur d\'inscription', e);
      // Fallback: local registration
      return _registerLocal(fullName, email, password);
    }
  }

  /// Envoie l'email de vérification via le backend (email au logo de l'app),
  /// avec repli sur l'email Firebase natif si le serveur est injoignable.
  Future<void> _sendVerificationEmail() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;
    try {
      final idToken = await user.getIdToken();
      if (idToken == null) {
        AppLogger.warn('Auth', 'idToken null, repli Firebase');
      } else {
        final sent = await _api?.sendVerificationEmail(idToken);
        if (sent == true) {
          AppLogger.success('Auth', 'Email de vérification envoyé via le backend');
          return;
        }
      }
    } catch (e) {
      AppLogger.warn('Auth', 'Backend indisponible, repli Firebase: $e');
    }
    try {
      await user.sendEmailVerification(_verifyEmailSettings());
    } catch (e) {
      AppLogger.error('Auth', 'Échec de l\'envoi de l\'email Firebase', e);
    }
  }

  Future<String?> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return 'Aucun utilisateur connecté';
      await _sendVerificationEmail();
      return null;
    } catch (e) {
      return 'Erreur lors de l\'envoi de l\'email de vérification';
    }
  }

  Future<String?> handleAuthLink(String link) async {
    try {
      final uri = Uri.parse(link);
      final mode = uri.queryParameters['mode'];
      final oobCode = uri.queryParameters['oobCode'];
      if (oobCode == null || oobCode.isEmpty) return null;

      if (mode == 'verifyEmail') {
        AppLogger.info('Auth', 'Validation de l\'email via le lien reçu');
        await _firebaseAuth.applyActionCode(oobCode);
        final user = _firebaseAuth.currentUser;
        await user?.reload();
        if (user?.emailVerified ?? false) {
          _state = AuthState.loggedIn;
          _storage.prefs.setString('auth_user', jsonEncode({
            'id': user!.uid, 'name': _fullName, 'email': _email,
          }));
        }
        notifyListeners();
        return null;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      AppLogger.warn('Auth', 'Lien auth invalide/expiré: ${e.code}');
      if (e.code == 'invalid-action-code' || e.code == 'expired-action-code') {
        return 'Lien expiré ou déjà utilisé. Veuillez renvoyer un email de vérification.';
      }
      return 'Erreur lors du traitement du lien';
    } catch (e) {
      AppLogger.error('Auth', 'Erreur lors du traitement du lien', e);
      return 'Erreur lors du traitement du lien';
    }
  }

  Future<String?> checkEmailVerified() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return 'Aucun utilisateur connecté';
      await user.reload();
      if (user.emailVerified) {
        _state = AuthState.loggedIn;
        _storage.prefs.setString('auth_user', jsonEncode({
          'id': user.uid, 'name': _fullName, 'email': _email,
        }));
        notifyListeners();
        return null;
      }
      return 'Email non vérifié. Veuillez vérifier votre boîte de réception.';
    } catch (e) {
      return 'Erreur de vérification';
    }
  }

  Future<String?> _registerLocal(String fullName, String email, String password) async {
    final existing = _storage.prefs.getString('auth_$email');
    if (existing != null) return 'Cet email est déjà utilisé';

    final hashedPassword = base64Encode(utf8.encode('muslim_ia_salt_$password'));
    final userId = 'local_${DateTime.now().millisecondsSinceEpoch}';

    _storage.prefs.setString('auth_$email', jsonEncode({
      'password': hashedPassword, 'id': userId, 'name': fullName.trim(),
    }));
    _storage.prefs.setString('auth_user', jsonEncode({
      'id': userId, 'name': fullName.trim(), 'email': email.trim(),
    }));

    _userId = userId;
    _fullName = fullName.trim();
    _email = email.trim();
    _state = AuthState.loggedIn;
    notifyListeners();
    return null;
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    AppLogger.info('Auth', 'Tentative de connexion: $email');
    if (!email.contains('@')) return 'Email invalide';
    if (password.isEmpty) return 'Mot de passe requis';

    try {
      // Firebase Auth
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      if (!requireEmailVerification || credential.user!.emailVerified) {
        _userId = credential.user!.uid;
        _fullName = credential.user!.displayName ?? email.split('@')[0];
        _email = email.trim();
        _state = AuthState.loggedIn;

        _storage.prefs.setString('auth_user', jsonEncode({
          'id': _userId, 'name': _fullName, 'email': _email,
        }));
        notifyListeners();
        return null;
      }
      _userId = credential.user!.uid;
      _fullName = credential.user!.displayName ?? email.split('@')[0];
      _email = email.trim();
      _state = AuthState.emailVerification;
      notifyListeners();
      return 'Email non vérifié. Veuillez vérifier votre boîte de réception.';
    } on FirebaseAuthMultiFactorException catch (e) {
      _pendingMfaResolver = e.resolver;
      AppLogger.info('Auth', 'MFA requis pour: $email');
      return mfaRequiredCode;
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Auth', 'Erreur de connexion Firebase', e);
      return _firebaseError(e.code);
    } catch (e) {
      AppLogger.error('Auth', 'Erreur de connexion', e);
      // Fallback: local login
      return _loginLocal(email, password);
    }
  }

  Future<String?> _loginLocal(String email, String password) async {
    final userData = _storage.prefs.getString('auth_$email');
    if (userData == null) return 'Aucun compte trouvé';

    try {
      final data = jsonDecode(userData);
      final hashedPassword = base64Encode(utf8.encode('muslim_ia_salt_$password'));
      if (data['password'] != hashedPassword) return 'Mot de passe incorrect';

      _storage.prefs.setString('auth_user', jsonEncode({
        'id': data['id'], 'name': data['name'], 'email': email.trim(),
      }));

      _userId = data['id'];
      _fullName = data['name'];
      _email = email.trim();
      _state = AuthState.loggedIn;
      notifyListeners();
      return null;
    } catch (_) {
      return 'Erreur de connexion';
    }
  }

  String _firebaseError(String code) {
    switch (code) {
      case 'email-already-in-use': return 'Cet email est déjà utilisé';
      case 'invalid-email': return 'Email invalide';
      case 'weak-password': return 'Mot de passe trop faible';
      case 'user-not-found': return 'Aucun compte trouvé';
      case 'wrong-password': return 'Mot de passe incorrect';
      case 'invalid-credential': return 'Email ou mot de passe incorrect';
      case 'network-request-failed': return 'Erreur réseau. Vérifiez votre connexion.';
      default: return 'Erreur: $code';
    }
  }

  Future<void> logout() async {
    AppLogger.info('Auth', 'Déconnexion: $_email');
    try {
      await _firebaseAuth.signOut();
    } catch (_) {}

    _storage.prefs.remove('auth_user');
    _userId = null;
    _fullName = null;
    _email = null;
    _state = AuthState.loggedOut;
    notifyListeners();
  }

  Future<void> updateProfile(String newName) async {    if (newName.trim().isEmpty) return;
    _fullName = newName.trim();
    _storage.prefs.setString('auth_name', _fullName!);
    try {
      await _firebaseAuth.currentUser?.updateDisplayName(newName.trim());
    } catch (_) {}
    notifyListeners();
  }

  Future<String?> changePassword(String oldPassword, String newPassword) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return 'Aucun utilisateur connecté';

      // Re-authenticate
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return _firebaseError(e.code);
    } catch (e) {
      return 'Erreur lors du changement de mot de passe';
    }
  }

  Future<String?> resetPassword({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      return _firebaseError(e.code);
    } catch (e) {
      return 'Erreur lors de l\'envoi de l\'email de réinitialisation';
    }
  }

  Future<String?> changeEmail({
    required String newEmail,
    required String password,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return 'Aucun utilisateur connecté';
    if (!newEmail.contains('@')) return 'Email invalide';

    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updateEmail(newEmail.trim());
      if (requireEmailVerification) {
        await _sendVerificationEmail();
      }
      _email = newEmail.trim();
      _state = requireEmailVerification
          ? AuthState.emailVerification
          : AuthState.loggedIn;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return _firebaseError(e.code);
    } catch (e) {
      return 'Erreur lors de la modification de l\'email';
    }
  }

  static const String mfaRequiredCode = '__MFA_REQUIRED__';
  MultiFactorResolver? _pendingMfaResolver;

  Future<bool> isMfaEnabled() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return false;
    final factors = await user.multiFactor.getEnrolledFactors();
    return factors.isNotEmpty;
  }

  MultiFactorSession? _pendingMfaSession;
  TotpSecret? _pendingMfaSecret;

  Future<({String secret, String otpauthUri})> startMfaSetup() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw StateError('Aucun utilisateur connecté');
    _pendingMfaSession = await user.multiFactor.getSession();
    _pendingMfaSecret = await TotpMultiFactorGenerator.generateSecret(_pendingMfaSession!);
    final otpauthUri = await _pendingMfaSecret!.generateQrCodeUrl();
    return (
      secret: _pendingMfaSecret!.secretKey,
      otpauthUri: otpauthUri,
    );
  }

  Future<String?> completeMfaSetup(String code, String displayName) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null || _pendingMfaSession == null || _pendingMfaSecret == null) {
        return 'Session expirée. Réessayez.';
      }
      final assertion = await TotpMultiFactorGenerator.getAssertionForEnrollment(
        _pendingMfaSecret!,
        code.trim(),
      );
      await user.multiFactor.enroll(assertion, displayName: displayName);
      _pendingMfaSession = null;
      _pendingMfaSecret = null;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return _firebaseError(e.code);
    } catch (e) {
      return 'Code invalide ou erreur lors de l\'activation';
    }
  }

  Future<String?> disableMfa(String password) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return 'Aucun utilisateur connecté';
    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
      final factors = await user.multiFactor.getEnrolledFactors();
      for (final factor in factors) {
        await user.multiFactor.unenroll(factorUid: factor.uid);
      }
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return _firebaseError(e.code);
    } catch (e) {
      return 'Erreur lors de la désactivation';
    }
  }

  Future<String?> completeMfaLogin(String code) async {
    final resolver = _pendingMfaResolver;
    if (resolver == null) return 'Session expirée. Réessayez.';
    try {
      final hint = resolver.hints.isNotEmpty ? resolver.hints.first : null;
      if (hint == null) return 'Aucun facteur d\'authentification trouvé';
      final assertion = await TotpMultiFactorGenerator.getAssertionForSignIn(
        hint.uid,
        code.trim(),
      );
      await resolver.resolveSignIn(assertion);
      _pendingMfaResolver = null;
      return null;
    } on FirebaseAuthException catch (e) {
      return _firebaseError(e.code);
    } catch (e) {
      return 'Code invalide. Réessayez.';
    }
  }
}
