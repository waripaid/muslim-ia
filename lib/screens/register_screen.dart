import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../utils/validators.dart';
import '../widgets/legal_acceptance.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure1 = true, _obscure2 = true;
  bool _accepted = false;
  String? _error;
  bool _loading = false;

  // Live validation states
  String? _nameError, _emailError, _passError, _confirmError;

  @override
  void initState() {
    super.initState();
    _name.addListener(_validateName);
    _email.addListener(_validateEmail);
    _pass.addListener(() { _validatePassword(); _validateConfirm(); });
    _confirm.addListener(_validateConfirm);
  }

  @override
  void dispose() { _name.dispose(); _email.dispose(); _pass.dispose(); _confirm.dispose(); super.dispose(); }

  void _validateName() {
    final v = _name.text;
    setState(() {
      if (v.isEmpty) _nameError = null;
      else if (v.trim().length < 2) _nameError = 'Trop court (min. 2)';
      else if (v.trim().length > 50) _nameError = 'Trop long (max. 50)';
      else _nameError = 'valid';
    });
  }

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
      else _passError = validatePassword(v) ?? 'valid';
    });
  }

  void _validateConfirm() {
    final v = _confirm.text;
    setState(() {
      if (v.isEmpty) _confirmError = null;
      else if (v != _pass.text) _confirmError = 'Ne correspond pas';
      else _confirmError = 'valid';
    });
  }

  IconData _fieldIcon(String? state) {
    if (state == null) return Icons.circle_outlined;
    if (state == 'valid') return Icons.check_circle_rounded;
    return Icons.error_rounded;
  }

  Color _fieldColor(String? state) {
    if (state == null) return AppColors.textLight;
    if (state == 'valid') return AppColors.success;
    return AppColors.error;
  }

  String _passwordStrength() {
    final v = _pass.text;
    if (v.isEmpty) return '';
    if (v.length < 6) return 'Très faible';
    if (v.length < 8) return 'Faible';
    if (v.contains(RegExp(r'[A-Z]')) && v.contains(RegExp(r'[0-9]'))) return 'Fort';
    return 'Moyen';
  }

  Color _strengthColor() {
    final s = _passwordStrength();
    if (s.isEmpty) return Colors.transparent;
    if (s.contains('faible')) return AppColors.error;
    if (s == 'Moyen') return AppColors.warning;
    return AppColors.success;
  }

  Future<void> _submit() async {
    // Force validation of all fields
    _validateName(); _validateEmail(); _validatePassword(); _validateConfirm();

    if (_nameError != 'valid' || _emailError != 'valid' || _passError != 'valid' || _confirmError != 'valid') {
      setState(() => _error = 'Veuillez corriger les champs en rouge');
      return;
    }

    if (!_accepted) {
      setState(() => _error = 'Veuillez accepter les conditions d\'utilisation et la politique de confidentialité');
      return;
    }

    setState(() { _loading = true; _error = null; });
    final result = await context.read<AuthProvider>().register(
      fullName: _name.text.trim(),
      email: _email.text.trim(),
      password: _pass.text,
      confirmPassword: _confirm.text,
    );
    if (result != null && mounted) setState(() { _error = result; _loading = false; });
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
            const SizedBox(height: 76),
            Center(
              child: Container(
                width: 88, height: 88,
                decoration: BoxDecoration(
                  gradient: AppGradients.gold,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: const Color(0xFFC5A028).withValues(alpha: 0.4), blurRadius: 30)],
                ),
                child: const Icon(Icons.person_add_rounded, size: 40, color: Color(0xFF0F1B4C)),
              ),
            ),
            const SizedBox(height: 22),
            const Text('Inscription', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.3)),
            const SizedBox(height: 8),
            const Text('Créez votre compte Muslim IA', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.white70)),
            const SizedBox(height: 32),
            _buildField(_name, 'Nom complet', 'Entrez votre nom complet', Icons.person_outline, _nameError, false,
              suffix: _name.text.isNotEmpty ? Icon(_fieldIcon(_nameError), size: 18, color: _fieldColor(_nameError)) : null),
            const SizedBox(height: 18),
            _buildField(_email, 'Email', 'votre@email.com', Icons.email_outlined, _emailError, false, type: TextInputType.emailAddress,
              suffix: _email.text.isNotEmpty ? Icon(_fieldIcon(_emailError), size: 18, color: _fieldColor(_emailError)) : null),
            const SizedBox(height: 18),
            _buildField(_pass, 'Mot de passe', 'Minimum 6 caractères', Icons.lock_outlined, _passError, _obscure1,
              suffix: Row(mainAxisSize: MainAxisSize.min, children: [
                if (_pass.text.isNotEmpty) ...[
                  Container(margin: const EdgeInsets.only(right: 4), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: _strengthColor().withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                    child: Text(_passwordStrength(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _strengthColor()))),
                  const SizedBox(width: 4),
                ],
                IconButton(icon: Icon(_obscure1 ? Icons.visibility_off : Icons.visibility, size: 20, color: Colors.white54), onPressed: () => setState(() => _obscure1 = !_obscure1)),
              ])),
            if (_pass.text.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(children: List.generate(4, (i) {
                final strength = _passwordStrength();
                final active = strength.contains('faible') && i < 1 || strength == 'Moyen' && i < 2 || strength == 'Fort' && i < 4;
                return Expanded(child: Container(margin: const EdgeInsets.symmetric(horizontal: 2), height: 3,
                  decoration: BoxDecoration(color: active ? _strengthColor() : Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(2))));
              })),
            ],
            const SizedBox(height: 18),
            _buildField(_confirm, 'Confirmer', 'Répétez le mot de passe', Icons.lock_outlined, _confirmError, _obscure2,
              suffix: Row(mainAxisSize: MainAxisSize.min, children: [
                if (_confirm.text.isNotEmpty) Icon(_fieldIcon(_confirmError), size: 18, color: _fieldColor(_confirmError)),
                const SizedBox(width: 4),
                IconButton(icon: Icon(_obscure2 ? Icons.visibility_off : Icons.visibility, size: 20, color: Colors.white54), onPressed: () => setState(() => _obscure2 = !_obscure2)),
              ])),
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
                    : const Text('S\'inscrire', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F1B4C))),
              ),
            )),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('Déjà un compte ? ', style: TextStyle(color: Colors.white60)),
              GestureDetector(onTap: () => Navigator.pop(context), child: const Text('Se connecter', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.accent))),
            ]),
            const SizedBox(height: 30),
          ])),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, String hint, IconData icon, String? error, bool obscure, {TextInputType? type, Widget? suffix}) {
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
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.error, width: 1.5)),
          focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.error, width: 2)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: error == 'valid' ? AppColors.success.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.15), width: error == 'valid' ? 1.5 : 1)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: error == 'valid' ? AppColors.success : AppColors.accent, width: 2)),
        ),
      ),
    ]);
  }

  Widget _errorBox(String msg) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.error.withValues(alpha: 0.3))), child: Row(children: [const Icon(Icons.error_outline, size: 16, color: AppColors.error), const SizedBox(width: 8), Expanded(child: Text(msg, style: const TextStyle(fontSize: 13, color: AppColors.error)))]));
}
