import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../providers/subscription_provider.dart';
import '../services/currency_service.dart';
import '../utils/logger.dart';
import 'login_screen.dart';
import 'payment_result_screen.dart';
import 'payment_webview_screen.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});
  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  bool _checkingPayment = false;

  @override
  Widget build(BuildContext context) {
    final sub = context.watch<SubscriptionProvider>();
    final auth = context.watch<AuthProvider>();
    final l10n = AppLocalizations.of(context);
    final currency = CurrencyService.detectCurrency();
    final price = CurrencyService.formatPrice(currency);
    final isLoggedIn = auth.isLoggedIn;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Color(0xFF0A0E2E), Color(0xFF152461)]),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(children: [
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.topRight,
                child: Material(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: const CircleBorder(),
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, size: 20, color: Colors.white70),
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(width: 84, height: 84,
                decoration: BoxDecoration(gradient: AppGradients.gold, shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: const Color(0xFFC5A028).withValues(alpha: 0.35), blurRadius: 28)]),
                child: const Icon(Icons.diamond_rounded, size: 42, color: Color(0xFF0F1B4C))),
              const SizedBox(height: 20),
              const Text('Muslim IA Premium', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)),
              const SizedBox(height: 8),
              Text(sub.trialActive ? l10n.paywallTrialDays(sub.trialDaysLeft) : l10n.paywallTrialEnded,
                  style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.6))),
              const SizedBox(height: 32),
              _feature('📖', l10n.paywallFreeChat, l10n.paywallAssistant),
              _feature('🖼️', l10n.paywallVision, 'Analyse d\'images du Coran'),
              _feature('🕌', l10n.paywallMemorization, 'Prières, Coran, objectifs'),
              _feature('🔍', l10n.paywallQuranExplorer, l10n.paywallSearchMCP),
              _feature('🌙', l10n.paywallTheme, 'Thème personnalisé'),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.accent.withValues(alpha: 0.3), width: 2),
                ),
                child: Column(children: [
                  Row(children: [
                    Text(l10n.paywallSubtitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                    const Spacer(),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(8)),
                        child: Text(l10n.paywallPopular, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.black))),
                  ]),
                  const SizedBox(height: 8),
                  Text(price, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.accent)),
                  const SizedBox(height: 4),
                  Text(l10n.paywallCard, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.5))),
                  const SizedBox(height: 16),
                  SizedBox(width: double.infinity, height: 48, child: isLoggedIn
                    ? ElevatedButton.icon(
                        onPressed: sub.isProcessing ? null : () => _pay(sub),
                        icon: sub.isProcessing
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryDark))
                            : const Icon(Icons.credit_card_rounded, size: 18),
                        label: Text(sub.isProcessing ? l10n.paywallProcessing : l10n.paywallPay, style: const TextStyle(fontWeight: FontWeight.w800)),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, foregroundColor: AppColors.primaryDark, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                      )
                    : ElevatedButton.icon(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                        icon: const Icon(Icons.login_rounded, size: 18),
                        label: Text(l10n.login, style: const TextStyle(fontWeight: FontWeight.w800)),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, foregroundColor: AppColors.primaryDark, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                      ),
                  ),
                ]),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: _checkingPayment ? null : () => _verifyPayment(sub),
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: Text(_checkingPayment ? l10n.paywallVerifying : l10n.paywallAlreadyPaid,
                    style: const TextStyle(color: Colors.white70)),
              ),
              const SizedBox(height: 20),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _feature(String icon, String title, String subtitle) {
    return Padding(padding: const EdgeInsets.only(bottom: 14), child: Row(children: [
      Container(
        width: 44, height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
        ),
        child: Text(icon, style: const TextStyle(fontSize: 22)),
      ),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
        const SizedBox(height: 2),
        Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.5))),
      ])),
      const Icon(Icons.check_circle_rounded, size: 20, color: AppColors.accent),
    ]));
  }

  /// Crée le paiement puis ouvre la page de paiement dans la WebView intégrée.
  Future<void> _pay(SubscriptionProvider sub) async {
    AppLogger.start('Paywall', 'Clic sur "Payer" — montant=${CurrencyService.basePriceXOF} XOF');
    if (sub.isProcessing) {
      AppLogger.warn('Paywall', 'Paiement déjà en cours, clic ignoré');
      return;
    }
    final email = context.read<AuthProvider>().email ?? 'user@muslimia.app';
    final name = context.read<AuthProvider>().fullName;
    final l10n = AppLocalizations.of(context);
    AppLogger.info('Paywall', 'Email utilisé pour le paiement: $email');

    final url = await sub.createCardPayment(
      amount: CurrencyService.basePriceXOF,
      email: email,
      customerName: name,
    );
    if (!mounted) return;

    if (url == null) {
      final error = sub.lastPaymentError ?? l10n.paywallPaymentError;
      AppLogger.warn('Paywall', 'Échec de création du paiement — "$error"');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    AppLogger.info('Paywall', 'Ouverture de la page de paiement intégrée (WebView)');
    final result = await Navigator.push<WebPaymentResult>(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentWebViewScreen(
          checkoutUrl: url,
          reference: sub.paymentReference ?? '',
        ),
      ),
    );
    if (!mounted) return;

    if (result?.success == true) {
      AppLogger.success('Paywall', 'Paiement réussi — l\'utilisateur est maintenant premium');
      final action = await Navigator.push<PaymentResultAction>(
        context,
        MaterialPageRoute(builder: (_) => const PaymentResultScreen(success: true)),
      );
      if (!mounted) return;
      if (action == PaymentResultAction.success) {
        Navigator.pop(context);
      }
    } else if (result != null) {
      final error = result.message ?? sub.lastPaymentError ?? l10n.paywallPaymentError;
      AppLogger.warn('Paywall', 'Paiement échoué — "$error"');
      final action = await Navigator.push<PaymentResultAction>(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentResultScreen(success: false, message: error),
        ),
      );
      if (!mounted) return;
      if (action == PaymentResultAction.retry) {
        _pay(sub);
      }
    }
  }

  Future<void> _verifyPayment(SubscriptionProvider sub) async {
    AppLogger.start('Paywall', 'Clic sur "J\'ai déjà payé" — référence=${sub.paymentReference}');
    if (_checkingPayment) {
      AppLogger.warn('Paywall', 'Vérification déjà en cours, clic ignoré');
      return;
    }
    final l10n = AppLocalizations.of(context);
    setState(() => _checkingPayment = true);
    final success = await sub.checkPaymentStatus();
    if (mounted) setState(() => _checkingPayment = false);
    AppLogger.info('Paywall', 'checkPaymentStatus() retourné: success=$success, isSubscribed=${sub.isSubscribed}, subscriptionEnd=${sub.subscriptionEnd}');
    if (!mounted) return;
    if (!success) {
      final error = sub.lastPaymentError ?? l10n.paywallPaymentNotDetected;
      AppLogger.warn('Paywall', 'Vérification négative — message affiché: "$error"');
      final action = await Navigator.push<PaymentResultAction>(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentResultScreen(success: false, message: error),
        ),
      );
      if (!mounted) return;
      if (action == PaymentResultAction.retry) {
        _verifyPayment(sub);
      }
    } else {
      AppLogger.success('Paywall', 'Abonnement vérifié et activé');
      final action = await Navigator.push<PaymentResultAction>(
        context,
        MaterialPageRoute(builder: (_) => const PaymentResultScreen(success: true)),
      );
      if (!mounted) return;
      if (action == PaymentResultAction.success) {
        Navigator.pop(context);
      }
    }
  }
}
