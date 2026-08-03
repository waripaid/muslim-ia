import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'dart:async';

import 'config/theme.dart';
import 'l10n/app_localizations.dart';
import 'providers/app_state_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/internet_status_provider.dart';
import 'providers/language_provider.dart';
import 'providers/memory_provider.dart';
import 'providers/subscription_provider.dart';
import 'services/api_service.dart';
import 'services/deep_link_service.dart';
import 'services/storage_service.dart';
import 'screens/chat_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/login_screen.dart';
import 'screens/paywall_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/splash_screen.dart';
import 'utils/logger.dart';
import 'utils/validators.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Empêche l'exception framework « Looking up a deactivated widget's ancestor
  // is unsafe » (InkWell consulté pendant une transition de route quand le
  // clavier se ferme) : en fixant la stratégie sur touch, le mode de surbrillance
  // de focus ne change plus et _HighlightModeManager ne notifie plus.
  WidgetsBinding.instance.focusManager.highlightStrategy = FocusHighlightStrategy.alwaysTouch;
  DeepLinkService.init();
  AppLogger.start('App', 'Démarrage de Muslim IA...');

  try {
    await Firebase.initializeApp();
    AppLogger.success('App', 'Firebase initialisé');

    // Setup FCM push notifications
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(alert: true, badge: true, sound: true);
    final token = await messaging.getToken();
    if (token != null) AppLogger.success('App', 'FCM Token reçu');
    debugPrint('FCM Token: $token');

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
    messaging.onTokenRefresh.listen((t) => debugPrint('FCM Token refreshed: $t'));
  } catch (e) {
    AppLogger.warn('App', 'Firebase/FCM non disponible: $e');
  }

  // GeniusPay n'est plus initialisé côté client : le secret ne circule plus
  // dans l'app. La création/vérification du paiement passe par le backend
  // (/api/payments/*), qui détient les clés merchant.

  final storageService = StorageService();
  await storageService.init();
  final apiService = ApiService();
  final internetStatus = InternetStatusProvider();
  await internetStatus.init();
  final authProvider = AuthProvider(storage: storageService, api: apiService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: internetStatus),
        ChangeNotifierProvider(create: (_) => AppStateProvider(storage: storageService)),
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => LanguageProvider(prefs: storageService.prefs)),
        ChangeNotifierProvider(create: (_) => MemoryProvider(storage: storageService)),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider(
          storage: storageService,
          api: apiService,
          auth: authProvider,
        )),
        ChangeNotifierProvider(create: (_) => ChatProvider(api: apiService, storage: storageService, internetStatus: internetStatus)),
        Provider.value(value: apiService),
        Provider.value(value: storageService),
      ],
      child: const MuslimIAApp(),
    ),
  );
}

class MuslimIAApp extends StatefulWidget {
  const MuslimIAApp({super.key});

  @override
  State<MuslimIAApp> createState() => _MuslimIAAppState();
}

class _MuslimIAAppState extends State<MuslimIAApp> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  StreamSubscription<String>? _linkSub;
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _linkSub = DeepLinkService.onLink.listen(_handleLink);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final initial = await DeepLinkService.getInitialLink();
      if (initial != null && initial.isNotEmpty) {
        _handleLink(initial);
      }
    });
  }

  void _onSplashFinished() {
    if (mounted) setState(() => _showSplash = false);
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    super.dispose();
  }

  Future<void> _handleLink(String link) async {
    final auth = context.read<AuthProvider>();
    final result = await auth.handleAuthLink(link);
    if (result != null && mounted) {
      _scaffoldMessengerKey.currentState
          ?.showSnackBar(SnackBar(content: Text(result)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final auth = context.watch<AuthProvider>();
    final lang = context.watch<LanguageProvider>();

    return MaterialApp(
      title: 'Muslim IA',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: _scaffoldMessengerKey,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: appState.themeMode,
      themeAnimationDuration: Duration.zero,
      locale: lang.locale,
      supportedLocales: LanguageProvider.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 700),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: _showSplash
            ? SplashScreen(key: const ValueKey('splash'), onFinished: _onSplashFinished)
            : KeyedSubtree(
                key: const ValueKey('home'),
                child: auth.isLoggedIn
                    ? const ChatShell()
                    : auth.state == AuthState.emailVerification
                        ? const _EmailVerificationScreen()
                        : const _LoginShell(),
              ),
      ),
      builder: (context, child) {
        // Garde la disposition des éléments en LTR même en arabe (texte arabe rendu par bidi)
        return Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: child!,
          ),
        );
      },
    );
  }
}

// ─── LOGIN SHELL ─────────────────────────────────────────────

class _LoginShell extends StatelessWidget {
  const _LoginShell();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final l10n = AppLocalizations.of(context);

    if (auth.state == AuthState.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.accent)));
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppGradients.navy,
        ),
        child: Stack(
          children: [
            // Orbes décoratifs lumineux
            Positioned(
              top: -80, right: -60,
              child: Container(
                width: 220, height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    AppColors.accent.withValues(alpha: 0.18),
                    AppColors.accent.withValues(alpha: 0),
                  ]),
                ),
              ),
            ),
            Positioned(
              bottom: -100, left: -70,
              child: Container(
                width: 260, height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    AppColors.primaryLight.withValues(alpha: 0.15),
                    AppColors.primaryLight.withValues(alpha: 0),
                  ]),
                ),
              ),
            ),
            Positioned(
              top: 120, left: -50,
              child: Container(
                width: 140, height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    const Spacer(flex: 2),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOutBack,
                      builder: (context, v, child) => Transform.scale(scale: v, child: child),
                      child: Container(
                        width: 104, height: 104,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(26),
                          boxShadow: [
                            BoxShadow(color: AppColors.accent.withValues(alpha: 0.4), blurRadius: 28, offset: const Offset(0, 8)),
                          ],
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Image.asset('assets/muslimia.jpeg', fit: BoxFit.cover),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text('Muslim IA', style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5, shadows: [Shadow(color: Colors.black26, blurRadius: 20)])),
                    const SizedBox(height: 10),
                    Text(l10n.appTagline, textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 15, color: Colors.white70, height: 1.5)),
                    const Spacer(flex: 2),
                    SizedBox(width: double.infinity, height: 54, child: DecoratedBox(
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), gradient: AppGradients.gold, boxShadow: [BoxShadow(color: AppColors.accent.withValues(alpha: 0.35), blurRadius: 18, offset: const Offset(0, 6))]),
                      child: ElevatedButton(
                        onPressed: () => _showLogin(context),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, elevation: 0, foregroundColor: const Color(0xFF0F1B4C), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                        child: Text(l10n.authLoginButton, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                      ),
                    )),
                    const SizedBox(height: 14),
                    SizedBox(width: double.infinity, height: 54, child: OutlinedButton(
                      onPressed: () => _showRegister(context),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white30, width: 1.2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      child: Text(l10n.authRegisterButton, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    )),
                    const SizedBox(height: 44),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogin(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const _QuickLogin()));
  }

  void _showRegister(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const _QuickRegister()));
  }
}

// ─── QUICK LOGIN ─────────────────────────────────────────────

class _QuickLogin extends StatefulWidget {
  const _QuickLogin();
  @override
  State<_QuickLogin> createState() => _QuickLoginState();
}

class _QuickLoginState extends State<_QuickLogin> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _obscure = true;
  String? _error;
  bool _loading = false;
  String? _emailError, _passError;
  AuthProvider? _auth;

  @override
  void initState() {
    super.initState();
    _email.addListener(_onChanged);
    _pass.addListener(_onChanged);
    // Auto-redirect if login succeeds
    _auth = context.read<AuthProvider>();
    _auth!.addListener(_onAuthChange);
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    _auth?.removeListener(_onAuthChange);
    _email.dispose(); _pass.dispose(); super.dispose();
  }

  void _onAuthChange() {
    final auth = context.read<AuthProvider>();
    if (mounted && (auth.isLoggedIn || auth.state == AuthState.emailVerification)) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  Future<void> _submit() async {
    final emailError = validateEmail(_email.text);
    final passError = _pass.text.isEmpty ? 'Mot de passe requis' : null;
    setState(() { _emailError = emailError; _passError = passError; });
    if (emailError != null || passError != null) {
      setState(() => _error = 'Veuillez corriger les champs en rouge');
      return;
    }
    setState(() { _loading = true; _error = null; });
    final r = await context.read<AuthProvider>().login(email: _email.text.trim(), password: _pass.text);
    if (r == AuthProvider.mfaRequiredCode) {
      if (mounted) {
        setState(() => _loading = false);
        await _showMfaDialog();
      }
      return;
    }
    if (r != null && mounted) setState(() { _error = r; _loading = false; });
  }

  Future<void> _showMfaDialog() async {
    final l10n = AppLocalizations.of(context);
    final codeCtrl = TextEditingController();
    String? error;
    bool loading = false;

    await showDialog(context: context, builder: (ctx) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(l10n.authMfaTitle),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(l10n.authMfaBody, style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 12),
          TextField(
            controller: codeCtrl,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: InputDecoration(labelText: l10n.profileMfaCode, hintText: l10n.profileMfaCodeHint, border: const OutlineInputBorder()),
          ),
          if (error != null)
            Padding(padding: const EdgeInsets.only(top: 8), child: Text(error!, style: const TextStyle(color: AppColors.error, fontSize: 13))),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: loading ? null : () async {
              setDialogState(() { loading = true; error = null; });
              final r = await context.read<AuthProvider>().completeMfaLogin(codeCtrl.text);
              if (!context.mounted) return;
              if (r != null) {
                setDialogState(() { loading = false; error = r; });
              } else {
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    ));
    codeCtrl.dispose();
  }

  void _showForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ForgotPasswordScreen(initialEmail: _email.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = ThemeColors.of(context);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: colors.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // En-tête dégradé avec logo
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [const Color(0xFF0F1B4C), const Color(0xFF0A0E2E).withValues(alpha: 0.92)],
                ),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 12, 28, 36),
                  child: Row(
                    children: [
                      Container(
                        width: 56, height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: AppColors.accent.withValues(alpha: 0.35), blurRadius: 16)],
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.asset('assets/muslimia.jpeg', fit: BoxFit.cover),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Muslim IA', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.3)),
                            const SizedBox(height: 4),
                            Text(l10n.authLogin, style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.6))),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Text(l10n.authLogin, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: colors.textPrimary, letterSpacing: -0.3)),
                const SizedBox(height: 8),
                Text(l10n.authLoginSubtitle, style: TextStyle(fontSize: 14, color: colors.textSecondary)),
                const SizedBox(height: 28),
                TextField(controller: _email, keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(labelText: l10n.authEmail, prefixIcon: const Icon(Icons.email_outlined),
                        errorText: _emailError)),
                const SizedBox(height: 16),
                TextField(controller: _pass, obscureText: _obscure,
                    decoration: InputDecoration(labelText: l10n.authPassword, prefixIcon: const Icon(Icons.lock_outlined),
                        errorText: _passError,
                        suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, size: 20), onPressed: () => setState(() => _obscure = !_obscure)))),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _showForgotPassword,
                    child: Text(l10n.authForgotPassword, style: const TextStyle(fontSize: 13, color: AppColors.accent)),
                  ),
                ),
                if (_error != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 13))),
                const SizedBox(height: 24),
                SizedBox(height: 52, child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: AppGradients.gold,
                    boxShadow: [BoxShadow(color: AppColors.accent.withValues(alpha: 0.35), blurRadius: 18, offset: const Offset(0, 6))],
                  ),
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, elevation: 0, foregroundColor: const Color(0xFF0F1B4C), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    child: _loading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0F1B4C)))
                        : Text(l10n.authLoginButton, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  ),
                )),
                const SizedBox(height: 22),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(l10n.authNoAccount, style: TextStyle(fontSize: 13, color: colors.textSecondary)),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const _QuickRegister())),
                    child: Text(l10n.authRegisterButton, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.accent)),
                  ),
                ]),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── QUICK REGISTER ──────────────────────────────────────────

class _QuickRegister extends StatefulWidget {
  const _QuickRegister();
  @override
  State<_QuickRegister> createState() => _QuickRegisterState();
}

class _QuickRegisterState extends State<_QuickRegister> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure1 = true, _obscure2 = true;
  String? _error;
  bool _loading = false;
  String? _nameError, _emailError, _passError, _confirmError;
  AuthProvider? _auth;

  @override
  void initState() {
    super.initState();
    _pass.addListener(_onChanged);
    _confirm.addListener(_onChanged);
    _auth = context.read<AuthProvider>();
    _auth!.addListener(_onAuthChange);
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    _auth?.removeListener(_onAuthChange);
    _name.dispose(); _email.dispose(); _pass.dispose(); _confirm.dispose(); super.dispose();
  }

  void _onAuthChange() {
    final auth = context.read<AuthProvider>();
    if (mounted && (auth.isLoggedIn || auth.state == AuthState.emailVerification)) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  Future<void> _submit() async {
    final nameError = validateName(_name.text);
    final emailError = validateEmail(_email.text);
    final passError = validatePassword(_pass.text);
    final confirmError = _confirm.text != _pass.text ? 'Les mots de passe ne correspondent pas' : null;
    setState(() {
      _nameError = nameError;
      _emailError = emailError;
      _passError = passError;
      _confirmError = confirmError;
    });
    if (nameError != null || emailError != null || passError != null || confirmError != null) {
      setState(() => _error = 'Veuillez corriger les champs en rouge');
      return;
    }
    setState(() { _loading = true; _error = null; });
    final r = await context.read<AuthProvider>().register(
      fullName: _name.text.trim(), email: _email.text.trim(), password: _pass.text, confirmPassword: _confirm.text,
    );
    if (r != null && mounted) setState(() { _error = r; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final colors = ThemeColors.of(context);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: colors.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // En-tête dégradé avec logo
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [const Color(0xFF0F1B4C), const Color(0xFF0A0E2E).withValues(alpha: 0.92)],
                ),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 12, 28, 36),
                  child: Row(
                    children: [
                      Container(
                        width: 56, height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: AppColors.accent.withValues(alpha: 0.35), blurRadius: 16)],
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.asset('assets/muslimia.jpeg', fit: BoxFit.cover),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Muslim IA', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.3)),
                            const SizedBox(height: 4),
                            Text(l10n.authRegister, style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.6))),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Text(l10n.authRegister, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: colors.textPrimary, letterSpacing: -0.3)),
                const SizedBox(height: 8),
                Text(l10n.authRegisterSubtitle, style: TextStyle(fontSize: 14, color: colors.textSecondary)),
                const SizedBox(height: 24),
                TextField(controller: _name, decoration: InputDecoration(labelText: l10n.authFullName, prefixIcon: const Icon(Icons.person_outline),
                    errorText: _nameError)),
                const SizedBox(height: 14),
                TextField(controller: _email, keyboardType: TextInputType.emailAddress, decoration: InputDecoration(labelText: l10n.authEmail, prefixIcon: const Icon(Icons.email_outlined),
                    errorText: _emailError)),
                const SizedBox(height: 14),
                TextField(controller: _pass, obscureText: _obscure1,
                    decoration: InputDecoration(labelText: l10n.authPassword, prefixIcon: const Icon(Icons.lock_outlined),
                        errorText: _passError,
                        suffixIcon: IconButton(icon: Icon(_obscure1 ? Icons.visibility_off : Icons.visibility, size: 20), onPressed: () => setState(() => _obscure1 = !_obscure1)))),
                const SizedBox(height: 14),
                TextField(controller: _confirm, obscureText: _obscure2,
                    decoration: InputDecoration(labelText: l10n.authConfirmPassword, prefixIcon: const Icon(Icons.lock_outlined),
                        errorText: _confirmError,
                        suffixIcon: IconButton(icon: Icon(_obscure2 ? Icons.visibility_off : Icons.visibility, size: 20), onPressed: () => setState(() => _obscure2 = !_obscure2)))),
                if (_error != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 13))),
                const SizedBox(height: 24),
                SizedBox(height: 52, child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: AppGradients.gold,
                    boxShadow: [BoxShadow(color: AppColors.accent.withValues(alpha: 0.35), blurRadius: 18, offset: const Offset(0, 6))],
                  ),
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, elevation: 0, foregroundColor: const Color(0xFF0F1B4C), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    child: _loading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0F1B4C)))
                        : Text(l10n.authRegisterButton, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  ),
                )),
                const SizedBox(height: 22),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(l10n.authHaveAccount, style: TextStyle(fontSize: 13, color: colors.textSecondary)),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const _QuickLogin())),
                    child: Text(l10n.authLoginButton, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.accent)),
                  ),
                ]),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── EMAIL VERIFICATION SCREEN ─────────────────────────────────

class _EmailVerificationScreen extends StatefulWidget {
  const _EmailVerificationScreen();
  @override
  State<_EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<_EmailVerificationScreen> {
  bool _sending = false;
  bool _checking = false;
  String? _message;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppGradients.navy,
        ),
        child: Stack(
          children: [
            Positioned(
              top: -80, right: -60,
              child: Container(
                width: 220, height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    AppColors.accent.withValues(alpha: 0.18),
                    AppColors.accent.withValues(alpha: 0),
                  ]),
                ),
              ),
            ),
            Positioned(
              bottom: -100, left: -70,
              child: Container(
                width: 260, height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    AppColors.primaryLight.withValues(alpha: 0.15),
                    AppColors.primaryLight.withValues(alpha: 0),
                  ]),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    const Spacer(flex: 2),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOutBack,
                      builder: (context, v, child) => Transform.scale(scale: v, child: child),
                      child: Container(
                        width: 96, height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(colors: [
                            AppColors.accent.withValues(alpha: 0.3),
                            AppColors.accent.withValues(alpha: 0.12),
                          ]),
                          boxShadow: [BoxShadow(color: AppColors.accent.withValues(alpha: 0.3), blurRadius: 26)],
                        ),
                        child: const Icon(Icons.mark_email_unread_rounded, size: 46, color: AppColors.accent),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(l10n.authVerifyTitle,
                        style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.3)),
                    const SizedBox(height: 14),
                    Text(
                      l10n.authVerifySent,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.6), height: 1.5),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      auth.email ?? '',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                    const SizedBox(height: 26),
                    Text(
                      l10n.authVerifyInstructions,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.45), height: 1.5),
                    ),
                    const Spacer(flex: 2),
                    if (_message != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(_message!, textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _message!.contains('Erreur') || _message!.contains('خطأ') ? AppColors.error : Colors.greenAccent,
                              fontSize: 13,
                            )),
                      ),
                    SizedBox(
                      width: double.infinity, height: 54,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: AppGradients.gold,
                          boxShadow: [BoxShadow(color: AppColors.accent.withValues(alpha: 0.35), blurRadius: 18, offset: const Offset(0, 6))],
                        ),
                        child: ElevatedButton(
                          onPressed: _checking ? null : _onContinue,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, elevation: 0, foregroundColor: const Color(0xFF0F1B4C), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                          child: _checking
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0F1B4C)))
                              : Text(l10n.authVerifyContinue, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity, height: 46,
                      child: OutlinedButton(
                        onPressed: _sending ? null : _onResend,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white70,
                          side: const BorderSide(color: Colors.white24, width: 1.2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: _sending
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70))
                            : Text(l10n.authVerifyResend, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        context.read<AuthProvider>().logout();
                      },
                      child: Text(l10n.authVerifyUseOther,
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 13)),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onContinue() async {
    setState(() { _checking = true; _message = null; });
    final r = await context.read<AuthProvider>().checkEmailVerified();
    if (mounted) {
      setState(() {
        _checking = false;
        if (r != null) _message = r;
        else _message = null;
      });
    }
  }

  Future<void> _onResend() async {
    final l10n = AppLocalizations.of(context);
    setState(() { _sending = true; _message = null; });
    final r = await context.read<AuthProvider>().sendEmailVerification();
    if (mounted) {
      setState(() {
        _sending = false;
        _message = r != null ? 'Erreur: $r' : l10n.authVerifyEmailSent;
      });
    }
  }
}

// ─── CHAT SHELL ──────────────────────────────────────────────

class ChatShell extends StatefulWidget {
  const ChatShell({super.key});
  @override
  State<ChatShell> createState() => _ChatShellState();
}

class _ChatShellState extends State<ChatShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncSubscription());
    context.read<SubscriptionProvider>().addListener(_syncSubscription);
  }

  void _syncSubscription() {
    if (mounted) {
      final sub = context.read<SubscriptionProvider>();
      context.read<ChatProvider>().isPremium = sub.isPremium;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch subscription so UI rebuilds when it changes
    context.watch<SubscriptionProvider>();

    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: const ChatScreen(),
    );
  }

  Widget _buildConversationsList(ChatProvider chat) {
    final l10n = AppLocalizations.of(context);
    final colors = ThemeColors.of(context);
    final conversations = chat.getSavedConversations();
    final currentMsgCount = chat.messages.length;
    final activeId = chat.activeConversationId;
    final activeInList = activeId != null && conversations.any((c) => c['id'] == activeId);
    final showCurrent = currentMsgCount > 0 && (activeId == null || !activeInList);

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        // Current conversation (non encore sauvegardée ou absente de l'historique)
        if (showCurrent) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(l10n.chatCurrent, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: colors.textLight)),
          ),
          ListTile(
            leading: const Icon(Icons.chat_bubble_rounded, size: 18, color: AppColors.accent),
            title: Text(
              chat.messages.first.content.length > 40 ? '${chat.messages.first.content.substring(0, 40)}...' : chat.messages.first.content,
              style: TextStyle(fontSize: 13, color: colors.textPrimary),
              maxLines: 1, overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text('$currentMsgCount ${l10n.chatMessages}', style: TextStyle(fontSize: 11, color: colors.textSecondary)),
            selected: true,
            selectedTileColor: AppColors.accent.withValues(alpha: 0.1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          Divider(color: colors.cardBorder, height: 1),
        ],
        // Saved conversations
        if (conversations.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(l10n.chatHistory, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: colors.textLight)),
          ),
          ...conversations.map((c) => ListTile(
            key: Key(c['id']?.toString() ?? DateTime.now().toString()),
            leading: Icon(c['id'] == activeId ? Icons.chat_bubble_rounded : Icons.chat_bubble_outline_rounded, size: 18, color: c['id'] == activeId ? AppColors.accent : colors.textLight),
            title: Text(c['title'] ?? '', style: TextStyle(fontSize: 13, color: colors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text('${c['messageCount'] ?? 0} ${l10n.chatMessages}', style: TextStyle(fontSize: 11, color: colors.textSecondary)),
            selected: c['id'] == activeId,
            selectedTileColor: AppColors.accent.withValues(alpha: 0.1),
            onTap: () {
              chat.loadConversation(c['id']?.toString() ?? '');
              Navigator.pop(context);
            },
            onLongPress: () => _confirmDeleteConversation(chat, c['id']?.toString() ?? '', c['title'] ?? '', l10n),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          )),
        ],
        if (currentMsgCount == 0 && conversations.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.chat_bubble_outline_rounded, size: 40, color: colors.textLight.withValues(alpha: 0.4)),
                const SizedBox(height: 8),
                Text(l10n.chatNoConversations, style: TextStyle(color: colors.textSecondary, fontSize: 13)),
              ]),
            ),
          ),
      ],
    );
  }

  Future<void> _confirmDeleteConversation(ChatProvider chat, String id, String title, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(l10n.chatDeleteTitle),
        content: Text(l10n.chatDeleteBody(title)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), style: ElevatedButton.styleFrom(backgroundColor: AppColors.error), child: Text(l10n.delete, style: const TextStyle(color: Colors.white))),
        ],
      ),
    );
    if (confirmed == true) {
      chat.deleteConversation(id);
    }
  }

  PreferredSizeWidget _buildAppBar() {
    final l10n = AppLocalizations.of(context);
    return AppBar(
      backgroundColor: const Color(0xFF1A1A1A),
      leading: IconButton(
        icon: const Icon(Icons.menu_rounded, color: AppColors.accent),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      title: const SizedBox.shrink(),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Center(
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaywallScreen())),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: AppGradients.gold,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [BoxShadow(color: AppColors.accent.withValues(alpha: 0.3), blurRadius: 10)],
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.diamond_rounded, size: 15, color: Color(0xFF0F1B4C)),
                  const SizedBox(width: 6),
                  Text(l10n.appBarPremium, style: const TextStyle(color: Color(0xFF0F1B4C), fontWeight: FontWeight.w700, fontSize: 12)),
                ]),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDrawer() {
    final chat = context.watch<ChatProvider>();
    final auth = context.watch<AuthProvider>();
    final l10n = AppLocalizations.of(context);
    final colors = ThemeColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(24), bottomRight: Radius.circular(24))),
      child: SafeArea(
        child: Column(
          children: [
            // En-tête du menu : avatar + nouveau chat
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [const Color(0xFF1E1E1E), const Color(0xFF2A2414)]
                      : [const Color(0xFFFFF8E1), const Color(0xFFFAF3E0)],
                ),
                border: Border(bottom: BorderSide(color: colors.cardBorder)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppGradients.gold,
                          boxShadow: [BoxShadow(color: AppColors.accent.withValues(alpha: 0.35), blurRadius: 14)],
                        ),
                        child: Center(
                          child: Text(
                            (auth.fullName ?? 'M').isNotEmpty ? (auth.fullName ?? 'M')[0].toUpperCase() : 'M',
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0F1B4C)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(auth.fullName ?? 'Muslim IA', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: colors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text(auth.email ?? l10n.profileNotProvided, style: TextStyle(fontSize: 11, color: colors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: () {
                      chat.clearMessages();
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: double.infinity,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: AppGradients.gold,
                        boxShadow: [BoxShadow(color: AppColors.accent.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_rounded, size: 18, color: Color(0xFF0F1B4C)),
                          const SizedBox(width: 8),
                          Text(l10n.chatNew, style: const TextStyle(color: Color(0xFF0F1B4C), fontWeight: FontWeight.w700, fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: colors.cardBorder, height: 1),

            // Today's conversations
            Expanded(
              child: _buildConversationsList(chat),
            ),

            // Bottom section
            Divider(color: colors.cardBorder, height: 1),
            if (!auth.isLoggedIn)
              ListTile(
                leading: Icon(Icons.login_rounded, size: 20, color: colors.textLight),
                title: Text(l10n.login, style: TextStyle(fontSize: 13, color: colors.textPrimary)),
                subtitle: Text(l10n.profileNotProvided, style: TextStyle(fontSize: 11, color: colors.textSecondary)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                },
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ListTile(
              leading: Icon(Icons.person_rounded, size: 20, color: colors.textLight),
              title: Text(l10n.profileTitle, style: TextStyle(fontSize: 13, color: colors.textPrimary)),
              subtitle: Text(auth.email ?? l10n.profileNotProvided, style: TextStyle(fontSize: 11, color: colors.textSecondary)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
              },
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            const Divider(color: Colors.white12, height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Muslim IA v1.0', style: TextStyle(color: colors.textLight, fontSize: 11)),
            ),
          ],
        ),
      ),
    );
  }
}

// FCM Handlers (top-level functions)

@pragma('vm:entry-point')
void _handleForegroundMessage(RemoteMessage message) {
  debugPrint('FCM: ${message.notification?.title}');
}

@pragma('vm:entry-point')  
void _handleNotificationTap(RemoteMessage message) {
  debugPrint('FCM tapped: ${message.data}');
}
