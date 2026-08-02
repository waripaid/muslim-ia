import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../config/theme.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_state_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/language_provider.dart';
import '../providers/subscription_provider.dart';
import 'login_screen.dart';
import 'paywall_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameCtrl = TextEditingController();
  bool _editing = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _nameCtrl.text = auth.fullName ?? '';
  }

  @override
  void dispose() { _nameCtrl.dispose(); super.dispose(); }

  Future<void> _save() async {
    setState(() => _saving = true);
    try { context.read<AuthProvider>().updateProfile(_nameCtrl.text.trim()); } catch (_) {}
    setState(() { _saving = false; _editing = false; });
  }

  void _confirmDeleteConversations(ChatProvider chat, int count) {
    final l10n = AppLocalizations.of(context);
    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Text(l10n.profileDeleteConversationsTitle),
      content: Text(l10n.profileDeleteConversationsBody(count)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
        ElevatedButton(onPressed: () { chat.deleteAllConversations(); Navigator.pop(ctx); }, style: ElevatedButton.styleFrom(backgroundColor: AppColors.error), child: Text(l10n.profileDeleteAll, style: const TextStyle(color: Colors.white))),
      ],
    ));
  }

  void _showChangePassword() {
    final l10n = AppLocalizations.of(context);
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    String? error;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text(l10n.profilePasswordTitle),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: oldCtrl, obscureText: true, decoration: InputDecoration(labelText: l10n.profilePasswordCurrent, border: const OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: newCtrl, obscureText: true, decoration: InputDecoration(labelText: l10n.profilePasswordNew, border: const OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: confirmCtrl, obscureText: true, decoration: InputDecoration(labelText: l10n.authConfirmPassword, border: const OutlineInputBorder())),
            if (error != null) Padding(padding: const EdgeInsets.only(top: 10), child: Text(error!, style: const TextStyle(color: AppColors.error, fontSize: 13))),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
            ElevatedButton(
              onPressed: () async {
                if (oldCtrl.text.isEmpty || newCtrl.text.isEmpty) {
                  setDialogState(() => error = l10n.authFieldsRequired);
                  return;
                }
                if (newCtrl.text.length < 6) {
                  setDialogState(() => error = l10n.authPasswordTooShort);
                  return;
                }
                if (newCtrl.text != confirmCtrl.text) {
                  setDialogState(() => error = l10n.authPasswordMismatch);
                  return;
                }
                final errorMsg = await context.read<AuthProvider>().changePassword(oldCtrl.text, newCtrl.text);
                if (errorMsg != null) {
                  setDialogState(() => error = errorMsg);
                } else {
                  Navigator.pop(ctx);
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.profilePasswordChanged)));
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
              child: Text(l10n.confirm),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangeEmail() {
    final l10n = AppLocalizations.of(context);
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    String? error;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text(l10n.profileEmailChange),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: l10n.profileEmailNew, prefixIcon: const Icon(Icons.email_outlined), border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: InputDecoration(labelText: l10n.profilePasswordCurrent, prefixIcon: const Icon(Icons.lock_outlined), border: const OutlineInputBorder()),
            ),
            if (error != null) Padding(padding: const EdgeInsets.only(top: 10), child: Text(error!, style: const TextStyle(color: AppColors.error, fontSize: 13))),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
            ElevatedButton(
              onPressed: () async {
                if (emailCtrl.text.trim().isEmpty || passCtrl.text.isEmpty) {
                  setDialogState(() => error = l10n.authFieldsRequired);
                  return;
                }
                if (!emailCtrl.text.trim().contains('@')) {
                  setDialogState(() => error = l10n.authEmailInvalid);
                  return;
                }
                final errorMsg = await context.read<AuthProvider>().changeEmail(
                  newEmail: emailCtrl.text.trim(),
                  password: passCtrl.text,
                );
                if (errorMsg != null) {
                  setDialogState(() => error = errorMsg);
                } else {
                  Navigator.pop(ctx);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
              child: Text(l10n.confirm),
            ),
          ],
        ),
      ),
    );
    emailCtrl.dispose();
    passCtrl.dispose();
  }

  Future<void> _showMfaSetup() async {
    final l10n = AppLocalizations.of(context);
    final auth = context.read<AuthProvider>();
    String? error;
    String? secret;
    String? otpauthUri;

    try {
      final r = await auth.startMfaSetup();
      secret = r.secret;
      otpauthUri = r.otpauthUri;
    } catch (e) {
      error = l10n.profileMfaInvalidCode;
    }
    if (!mounted) return;

    final codeCtrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text(l10n.profileMfaSetupTitle),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              if (otpauthUri != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: QrImageView(data: otpauthUri, size: 170),
                ),
                const SizedBox(height: 12),
              ],
              Text(l10n.profileMfaStepQr, style: const TextStyle(fontSize: 13)),
              const SizedBox(height: 12),
              if (secret != null) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)),
                  child: Text('${l10n.profileMfaSecretKey}: $secret', style: const TextStyle(fontSize: 12, fontFamily: 'monospace')),
                ),
                const SizedBox(height: 12),
              ],
              TextField(
                controller: codeCtrl,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(labelText: l10n.profileMfaCode, hintText: l10n.profileMfaCodeHint, border: const OutlineInputBorder()),
              ),
              if (error != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(error!, style: const TextStyle(color: AppColors.error, fontSize: 13))),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
            ElevatedButton(
              onPressed: () async {
                if (codeCtrl.text.trim().isEmpty) {
                  setDialogState(() => error = l10n.profileMfaInvalidCode);
                  return;
                }
                final r = await auth.completeMfaSetup(codeCtrl.text, 'Muslim IA TOTP');
                if (r != null) {
                  setDialogState(() => error = r);
                } else {
                  Navigator.pop(ctx);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.profileMfaEnabledMsg)));
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
              child: Text(l10n.profileMfaActivate),
            ),
          ],
        ),
      ),
    );
    codeCtrl.dispose();
  }

  Future<void> _showDisableMfa() async {
    final l10n = AppLocalizations.of(context);
    final passCtrl = TextEditingController();
    String? error;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text(l10n.profileMfaDisableTitle),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(l10n.profileMfaDisableBody, style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 12),
            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: InputDecoration(labelText: l10n.profilePasswordCurrent, prefixIcon: const Icon(Icons.lock_outlined), border: const OutlineInputBorder()),
            ),
            if (error != null) Padding(padding: const EdgeInsets.only(top: 10), child: Text(error!, style: const TextStyle(color: AppColors.error, fontSize: 13))),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
            ElevatedButton(
              onPressed: () async {
                if (passCtrl.text.isEmpty) {
                  setDialogState(() => error = l10n.authFieldsRequired);
                  return;
                }
                final r = await context.read<AuthProvider>().disableMfa(passCtrl.text);
                if (r != null) {
                  setDialogState(() => error = r);
                } else {
                  Navigator.pop(ctx);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.profileMfaDisabledMsg)));
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
              child: Text(l10n.profileMfaDisable),
            ),
          ],
        ),
      ),
    );
    passCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthProvider>();
    final sub = context.watch<SubscriptionProvider>();
    final chat = context.watch<ChatProvider>();
    final lang = context.watch<LanguageProvider>();
    final colors = ThemeColors.of(context);

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF0F1B4C), Color(0xFF16286B), Color(0xFF1E3A8A)]),
          ),
        ),
        foregroundColor: Colors.white,
        title: Text(l10n.profileTitle, style: const TextStyle(color: AppColors.accent, fontSize: 17, fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          const SizedBox(height: 20),
          // Avatar
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppGradients.gold,
              boxShadow: [BoxShadow(color: AppColors.accent.withValues(alpha: 0.35), blurRadius: 24)],
            ),
            child: Container(
              width: 82, height: 82,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF0F1B4C)),
              child: Center(child: Text(
                (auth.fullName ?? 'M').isNotEmpty ? (auth.fullName ?? 'M')[0].toUpperCase() : 'M',
                style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: AppColors.accent),
              )),
            ),
          ),
          const SizedBox(height: 24),

          // Name
          Text(l10n.profileFullName, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textSecondary)),
          const SizedBox(height: 8),
          TextField(
            controller: _nameCtrl,
            enabled: _editing,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: colors.textPrimary),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              border: _editing ? OutlineInputBorder(borderRadius: BorderRadius.circular(14)) : InputBorder.none,
              filled: _editing, fillColor: colors.background,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 24),

          // Abonnement : barre de progression uniquement si l'utilisateur a
          // réellement souscrit (isPremium). Sinon carte plan gratuit / essai.
          if (sub.isPremium) ...[
            _buildSubscriptionCard(sub, colors),
            const SizedBox(height: 16),
          ] else ...[
            _buildFreePlanCard(chat, auth, colors),
            const SizedBox(height: 16),
          ],

          // Email (modifiable)
          GestureDetector(
            onTap: _showChangeEmail,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.primarySurface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: colors.cardBorder),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Row(children: [
                const Icon(Icons.email_outlined, size: 20, color: AppColors.accent),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(l10n.profileEmail, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: colors.textLight)),
                  const SizedBox(height: 2),
                  Text(auth.email ?? l10n.profileNotProvided, style: TextStyle(fontSize: 14, color: colors.textPrimary)),
                ])),
                Text(l10n.profileEmailChange, style: const TextStyle(fontSize: 11, color: AppColors.accent)),
                const Icon(Icons.chevron_right, color: AppColors.accent),
              ]),
            ),
          ),
          const SizedBox(height: 12),

          // Change password button
          GestureDetector(
            onTap: _showChangePassword,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.primarySurface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: colors.cardBorder),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Row(children: [
                const Icon(Icons.lock_outline, size: 20, color: AppColors.accent),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(l10n.profilePassword, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: colors.textLight)),
                  const SizedBox(height: 2),
                  Text(l10n.profileChangePassword, style: const TextStyle(fontSize: 14, color: AppColors.accent, fontWeight: FontWeight.w600)),
                ])),
                const Icon(Icons.chevron_right, color: AppColors.accent),
              ]),
            ),
          ),
          const SizedBox(height: 12),

          // Language
          _languageCard(lang, colors),
          const SizedBox(height: 12),

          // Dark/Light mode
          Consumer<AppStateProvider>(
            builder: (context, app, _) => Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.primarySurface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: colors.cardBorder),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Row(children: [
                Icon(app.themeMode == ThemeMode.dark ? Icons.dark_mode_rounded : Icons.light_mode_rounded, size: 20, color: AppColors.accent),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(l10n.profileTheme, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: colors.textLight)),
                  const SizedBox(height: 2),
                  Text(app.themeMode == ThemeMode.dark ? l10n.profileDarkMode : l10n.profileLightMode, style: TextStyle(fontSize: 14, color: colors.textPrimary, fontWeight: FontWeight.w600)),
                ])),
                Switch(value: app.themeMode == ThemeMode.dark, onChanged: (_) => app.toggleTheme(), activeColor: AppColors.accent),
              ]),
            ),
          ),

          const SizedBox(height: 16),
          Row(children: [
            Container(
              width: 30, height: 30,
              decoration: BoxDecoration(gradient: AppGradients.gold, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.shield_rounded, size: 16, color: Color(0xFF0F1B4C)),
            ),
            const SizedBox(width: 10),
            Text(l10n.profileSecurity, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: colors.textPrimary)),
          ]),
          const SizedBox(height: 8),

          // MFA (double authentication)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: colors.primarySurface, borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              const Icon(Icons.shield_outlined, size: 20, color: AppColors.accent),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(l10n.profileMfa, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: colors.textLight)),
                const SizedBox(height: 2),
                FutureBuilder<bool>(
                  future: auth.isMfaEnabled(),
                  builder: (context, snap) {
                    final enabled = snap.data ?? false;
                    return Text(
                      enabled ? l10n.profileMfaEnabled : l10n.profileMfaDisabled,
                      style: TextStyle(fontSize: 14, color: colors.textPrimary, fontWeight: FontWeight.w600),
                    );
                  },
                ),
              ])),
              FutureBuilder<bool>(
                future: auth.isMfaEnabled(),
                builder: (context, snap) {
                  final enabled = snap.data ?? false;
                  return Switch(
                    value: enabled,
                    onChanged: (_) => enabled ? _showDisableMfa() : _showMfaSetup(),
                    activeColor: AppColors.accent,
                  );
                },
              ),
            ]),
          ),

          const SizedBox(height: 32),

          // Edit/Save
          if (_editing)
            SizedBox(width: double.infinity, height: 48, child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: _saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(l10n.save, style: const TextStyle(fontWeight: FontWeight.w700)),
            ))
          else
            SizedBox(width: double.infinity, height: 48, child: OutlinedButton(
              onPressed: () => setState(() => _editing = true),
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.accent, side: BorderSide(color: AppColors.accent.withValues(alpha: 0.3)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: Text(l10n.profileEdit, style: const TextStyle(fontWeight: FontWeight.w600)),
            )),

          const SizedBox(height: 12),

          // Delete conversations (carte style langue, toujours visible)
          Consumer<ChatProvider>(
            builder: (context, chat, _) {
              final count = chat.getSavedConversations().length;
              final hasConversations = count > 0;
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: hasConversations
                      ? () => _confirmDeleteConversations(chat, count)
                      : null,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: hasConversations ? AppColors.error.withValues(alpha: 0.08) : colors.primarySurface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.error.withValues(alpha: hasConversations ? 0.35 : 0.12)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.delete_sweep_rounded, size: 20, color: AppColors.error),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(l10n.chatHistory, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: colors.textLight)),
                        const SizedBox(height: 2),
                        Text(
                          hasConversations ? l10n.profileDeleteConversations(count) : l10n.profileDeleteAll,
                          style: TextStyle(fontSize: 14, color: hasConversations ? AppColors.error : colors.textPrimary, fontWeight: FontWeight.w600),
                        ),
                      ])),
                      if (hasConversations) const Icon(Icons.chevron_right, color: AppColors.error),
                    ]),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          // Logout
          SizedBox(width: double.infinity, height: 48, child: OutlinedButton.icon(
            onPressed: () => showDialog(context: context, builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              title: Text(l10n.logoutConfirmTitle),
              content: Text(l10n.logoutConfirmBody),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
                ElevatedButton(onPressed: () { Navigator.pop(ctx); auth.logout(); Navigator.of(context).popUntil((route) => route.isFirst); }, style: ElevatedButton.styleFrom(backgroundColor: AppColors.error), child: Text(l10n.logout, style: const TextStyle(color: Colors.white))),
              ],
            )),
            icon: const Icon(Icons.logout_rounded, size: 18, color: AppColors.error),
            label: Text(l10n.logout, style: const TextStyle(color: AppColors.error)),
            style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.error), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
          )),
          const SizedBox(height: 48),
        ]),
      ),
    );
  }

  Widget _languageCard(LanguageProvider lang, ThemeColors colors) {
    final l10n = AppLocalizations.of(context);
    final country = lang.detectedCountry;
    final autoLang = country != null ? LanguageProvider.languageForCountry(country) : null;
    final autoLangName = switch (autoLang) {
      'ar' => 'العربية',
      'en' => 'English',
      _ => 'Français',
    };

    return GestureDetector(
      onTap: () => _showLanguagePicker(),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: colors.primarySurface, borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          const Icon(Icons.language_rounded, size: 20, color: AppColors.accent),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l10n.language, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: colors.textLight)),
            const SizedBox(height: 2),
            Text(
              lang.isAuto
                  ? '${l10n.automaticLanguage} (${autoLangName})'
                  : lang.languageName,
              style: TextStyle(fontSize: 14, color: colors.textPrimary, fontWeight: FontWeight.w600),
            ),
          ])),
          const Icon(Icons.chevron_right, color: AppColors.accent),
        ]),
      ),
    );
  }

  void _showLanguagePicker() {
    final l10n = AppLocalizations.of(context);
    final lang = context.read<LanguageProvider>();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l10n.language, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              if (lang.detectedCountry != null)
                Text(
                  '${l10n.detectedCountry}: ${LanguageProvider.countryName(lang.detectedCountry!)}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textLight),
                ),
              const SizedBox(height: 16),
              _langTile(ctx, lang, null, l10n.automaticLanguage, lang.detectedCountry != null
                  ? LanguageProvider.countryName(lang.detectedCountry!)
                  : null),
              _langTile(ctx, lang, 'fr', 'Français', null),
              _langTile(ctx, lang, 'ar', 'العربية', null),
              _langTile(ctx, lang, 'en', 'English', null),
              _langTile(ctx, lang, 'es', 'Español', null),
              _langTile(ctx, lang, 'pt', 'Português', null),
              _langTile(ctx, lang, 'ru', 'Русский', null),
              _langTile(ctx, lang, 'zh', '中文', null),
              const SizedBox(height: 8),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _langTile(BuildContext ctx, LanguageProvider lang, String? code, String name, String? subtitle) {
    final selected = (code == null) ? lang.isAuto : (lang.locale.languageCode == code && !lang.isAuto);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(selected ? Icons.check_circle_rounded : Icons.circle_outlined,
          color: selected ? AppColors.accent : Colors.grey),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textLight)) : null,
      onTap: () async {
        Navigator.pop(ctx);
        if (code == null) {
          await lang.setAutoLanguage();
        } else {
          await lang.setLanguage(code);
        }
      },
    );
  }

  Widget _buildSubscriptionCard(SubscriptionProvider sub, ThemeColors colors) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final endDate = sub.subscriptionEnd ?? now.add(const Duration(days: 30));
    final startDate = endDate.subtract(const Duration(days: 30));
    final totalDuration = endDate.difference(startDate);
    final elapsed = now.difference(startDate);
    final progress = (elapsed.inMicroseconds / totalDuration.inMicroseconds).clamp(0.0, 1.0);
    final daysLeft = endDate.difference(now).inDays.clamp(0, 999);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF0A0E2E), Color(0xFF1E3A8A)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(children: [
        Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.diamond_rounded, size: 22, color: AppColors.accent),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l10n.profileSubActive, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 2),
            Text(
              daysLeft > 0 ? l10n.profileDaysLeft(daysLeft) : l10n.profileEndsToday,
              style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.6)),
            ),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${(progress * 100).toInt()}%',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.accent),
            ),
          ),
        ]),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            height: 12,
            child: Stack(children: [
              Container(height: 12, color: Colors.white.withValues(alpha: 0.1)),
              FractionallySizedBox(
                widthFactor: progress,
                alignment: Alignment.centerLeft,
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.accent, Color(0xFFE8C547)]),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(
            '${startDate.day}/${startDate.month}',
            style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.4)),
          ),
          Text(
            '${endDate.day}/${endDate.month}',
            style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.4)),
          ),
        ]),
      ]),
    );
  }

  Widget _buildFreePlanCard(ChatProvider chat, AuthProvider auth, ThemeColors colors) {
    final l10n = AppLocalizations.of(context);
    final left = (ChatProvider.maxFreeMessages - chat.messagesSentToday).clamp(0, ChatProvider.maxFreeMessages);
    final isLoggedIn = auth.isLoggedIn;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF232323), Color(0xFF2D2410)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(children: [
        Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.person_outline_rounded, size: 22, color: AppColors.accent),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l10n.profileFreePlan, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 2),
            Text(
              l10n.profileToday(left, ChatProvider.maxFreeMessages),
              style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.6)),
            ),
          ])),
        ]),
        const SizedBox(height: 16),
        SizedBox(width: double.infinity, height: 40, child: ElevatedButton.icon(
          onPressed: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => isLoggedIn ? const PaywallScreen() : const LoginScreen(),
          )),
          icon: Icon(isLoggedIn ? Icons.diamond_rounded : Icons.login_rounded, size: 16, color: const Color(0xFF0F1B4C)),
          label: Text(isLoggedIn ? l10n.profileUpgrade : l10n.login, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF0F1B4C))),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        )),
      ]),
    );
  }
}
