import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../utils/validators.dart';
import '../widgets/legal_acceptance.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _obscure = true;
  bool _accepted = false;
  String? _error;
  bool _loading = false;

  String? _emailError, _passError;

  @override
  void initState() {
    super.initState();
    _email.addListener(_validateEmail);
    _pass.addListener(_validatePassword);
  }

  @override
  void dispose() { _email.dispose(); _pass.dispose(); super.dispose(); }

  void _validateEmail() {
    final v = _email.text;
    setState(() {
      if (v.isEmpty) _emailError = null;
      else _emailError = validateEmail(v) ?? 'valid';
    });
  }

  void _validatePassword() {
    final v = _pass.text;
    setState(() {
      if (v.isEmpty) _passError = null;
      else _passError = v.length >= 6 ? 'valid' : 'Minimum 6 caractères';
    });
  }

  Future<void> _submit() async {
    _validateEmail(); _validatePassword();
    if (_emailError != 'valid' || _passError != 'valid') {
      setState(() => _error = 'Veuillez corriger les champs');
      return;
    }

    if (!_accepted) {
      setState(() => _error = 'Veuillez accepter les conditions d\'utilisation et la politique de confidentialité');
      return;
    }
    setState(() { _loading = true; _error = null; });
    final result = await context.read<AuthProvider>().login(email: _email.text.trim(), password: _pass.text);
    if (result == AuthProvider.mfaRequiredCode) {
      if (mounted) {
        setState(() => _loading = false);
        await _showMfaDialog();
      }
      return;
    }
    if (result != null && mounted) setState(() { _error = result; _loading = false; });
  }

  Future<void> _showMfaDialog() async {
    final codeCtrl = TextEditingController();
    String? error;
    bool loading = false;

    await showDialog(context: context, builder: (ctx) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Vérification en deux étapes'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Entrez le code à 6 chiffres généré par votre application d\'authentification.', style: TextStyle(fontSize: 13)),
          const SizedBox(height: 12),
          TextField(
            controller: codeCtrl,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: const InputDecoration(labelText: 'Code à 6 chiffres', hintText: '123456', border: OutlineInputBorder()),
          ),
          if (error != null)
            Padding(padding: const EdgeInsets.only(top: 8), child: Text(error!, style: const TextStyle(color: AppColors.error, fontSize: 13))),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
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
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    ));
    codeCtrl.dispose();
  }

  Future<void> _showForgotPassword() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ForgotPasswordScreen(initialEmail: _email.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18), onPressed: () => Navigator.pop(context)),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFF0F1B4C), Color(0xFF16286B), Color(0xFF1E3A8A)]),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Form(key: _form, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const SizedBox(height: 80),
            Center(
              child: Container(
                width: 88, height: 88,
                decoration: BoxDecoration(
                  gradient: AppGradients.gold,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: const Color(0xFFC5A028).withValues(alpha: 0.4), blurRadius: 30)],
                ),
                child: const Icon(Icons.mosque_rounded, size: 42, color: Color(0xFF0F1B4C)),
              ),
            ),
            const SizedBox(height: 22),
            const Text('Connexion', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.3)),
            const SizedBox(height: 8),
            const Text('Connectez-vous pour continuer', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.white70)),
            const SizedBox(height: 36),
            _buildField(_email, 'Email', 'votre@email.com', Icons.email_outlined, _emailError, false, TextInputType.emailAddress),
            const SizedBox(height: 18),
            _buildField(_pass, 'Mot de passe', 'Votre mot de passe', Icons.lock_outlined, _passError, _obscure, TextInputType.text,
              suffix: IconButton(icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, size: 20, color: Colors.white54), onPressed: () => setState(() => _obscure = !_obscure))),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: _showForgotPassword,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Text('Mot de passe oublié ?', style: TextStyle(fontSize: 13, color: AppColors.accent)),
                ),
              ),
            ),
            if (_error != null) ...[const SizedBox(height: 16), _errorBox(_error!)],
            const SizedBox(height: 20),
            LegalAcceptance(accepted: _accepted, onChanged: (v) => setState(() => _accepted = v)),
            const SizedBox(height: 4),
            const SizedBox(height: 28),
            SizedBox(height: 54, child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppGradients.gold,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: const Color(0xFFC5A028).withValues(alpha: 0.4), blurRadius: 18, offset: const Offset(0, 6))],
              ),
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _loading
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0F1B4C)))
                    : const Text('Se connecter', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F1B4C))),
              ),
            )),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('Pas de compte ? ', style: TextStyle(color: Colors.white60)),
              GestureDetector(onTap: () => Navigator.pop(context), child: const Text('S\'inscrire', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.accent))),
            ]),
            const SizedBox(height: 32),
          ])),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, String hint, IconData icon, String? error, bool obscure, TextInputType? type, {Widget? suffix}) {
    final hasError = error != null && error != 'valid';
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white70)),
      const SizedBox(height: 6),
      TextFormField(
        controller: ctrl, obscureText: obscure, keyboardType: type,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35)),
          prefixIcon: Icon(icon, size: 20, color: Colors.white70),
          suffixIcon: suffix,
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.08),
          errorText: hasError ? error : null,
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: error == 'valid' ? AppColors.success.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.15))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: error == 'valid' ? AppColors.success : AppColors.accent, width: 2)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.error)),
        ),
      ),
    ]);
  }

  Widget _errorBox(String msg) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.error.withValues(alpha: 0.3))), child: Row(children: [const Icon(Icons.error_outline, size: 16, color: AppColors.error), const SizedBox(width: 8), Expanded(child: Text(msg, style: const TextStyle(fontSize: 13, color: AppColors.error)))]));
}
