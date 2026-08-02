import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../config/theme.dart';
import '../l10n/app_localizations.dart';
import '../providers/subscription_provider.dart';
import '../utils/logger.dart';

/// Résultat retourné par l'écran de paiement à la page appelante.
class WebPaymentResult {
  final bool success;
  final String? message;

  const WebPaymentResult({required this.success, this.message});
}

/// Écran de paiement intégré : la page de paiement GeniusPay est chargée dans
/// une WebView à l'intérieur de l'application (jamais quitté l'app).
/// Détecte la redirection vers [SubscriptionProvider.successUrl] pour
/// considérer le paiement comme réussi, puis vérifie et active l'abonnement.
class PaymentWebViewScreen extends StatefulWidget {
  final String checkoutUrl;
  final String reference;

  const PaymentWebViewScreen({
    super.key,
    required this.checkoutUrl,
    required this.reference,
  });

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _webCtrl;
  bool _loading = true;
  bool _verifying = false;
  String? _fatalError;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _webCtrl = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(NavigationDelegate(
        onProgress: (progress) {
          if (_done) return;
          setState(() => _loading = progress < 100);
        },
        onPageFinished: (_) {
          if (_done) return;
          setState(() => _loading = false);
        },
        onWebResourceError: (error) {
          if (_done || error.isForMainFrame != true) return;
          AppLogger.error('WebPay', 'Erreur de chargement: ${error.description}');
          setState(() => _fatalError = 'Impossible de charger la page de paiement.');
        },
        onNavigationRequest: _onNavigation,
      ))
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  FutureOr<NavigationDecision> _onNavigation(NavigationRequest request) {
    final url = request.url;
    AppLogger.info('WebPay', 'Navigation → $url');

    if (url.startsWith(SubscriptionProvider.successUrl)) {
      _onPaymentSucceeded();
      return NavigationDecision.prevent;
    }
    if (url.startsWith(SubscriptionProvider.errorUrl)) {
      _onPaymentFailed('Le paiement a été refusé.');
      return NavigationDecision.prevent;
    }
    return NavigationDecision.navigate;
  }

  Future<void> _onPaymentSucceeded() async {
    if (_done) return;
    _done = true;
    AppLogger.success('WebPay', 'Redirection succès détectée — vérification du paiement...');
    setState(() {
      _loading = false;
      _verifying = true;
    });

    final sub = context.read<SubscriptionProvider>();
    final ok = await sub.checkPaymentStatus();
    AppLogger.info('WebPay', 'Vérification terminée: success=$ok');

    if (!mounted) return;
    if (ok) {
      Navigator.pop(context, const WebPaymentResult(success: true));
    } else {
      Navigator.pop(context, WebPaymentResult(
        success: false,
        message: sub.lastPaymentError ?? AppLocalizations.of(context).paywallPaymentNotDetected,
      ));
    }
  }

  void _onPaymentFailed(String message) {
    if (_done) return;
    _done = true;
    AppLogger.warn('WebPay', 'Redirection erreur détectée: $message');
    Navigator.pop(context, WebPaymentResult(success: false, message: message));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return PopScope(
      canPop: !_verifying,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0F1B4C), Color(0xFF1E3A8A)],
              ),
            ),
          ),
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            tooltip: l10n.cancel,
            onPressed: _verifying ? null : () => Navigator.pop(context),
          ),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.paywallTitle,
                style: const TextStyle(color: AppColors.accent, fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const Text(
                'Paiement sécurisé',
                style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: _fatalError != null
                  ? _errorView(_fatalError!)
                  : WebViewWidget(controller: _webCtrl),
            ),
            if (_loading && _fatalError == null)
              const _CenterBubble(
                icon: Icons.lock_rounded,
                title: 'Chargement de la page sécurisée...',
              ),
            if (_verifying)
              const _CenterBubble(
                icon: Icons.verified_user_rounded,
                title: 'Vérification du paiement...',
              ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF0F1B4C),
              border: const Border(top: BorderSide(color: AppColors.accent, width: 1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.verified_rounded, size: 15, color: AppColors.accent),
                const SizedBox(width: 6),
                Text(
                  'Paiement sécurisé par GeniusPay',
                  style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.85)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _errorView(String message) {
    final l10n = AppLocalizations.of(context);
    return Container(
      color: const Color(0xFFFAF8F3),
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 56, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _fatalError = null;
                    _loading = true;
                  });
                  _webCtrl.loadRequest(Uri.parse(widget.checkoutUrl));
                },
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(l10n.retry, style: const TextStyle(fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: const Color(0xFF0F1B4C),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterBubble extends StatelessWidget {
  final IconData icon;
  final String title;

  const _CenterBubble({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white.withValues(alpha: 0.92),
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F1B4C).withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 34,
              height: 34,
              child: CircularProgressIndicator(strokeWidth: 3, color: AppColors.accent),
            ),
            const SizedBox(height: 16),
            Icon(icon, size: 30, color: AppColors.accent),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
