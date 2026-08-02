import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';

/// Case à cocher d'acceptation des Conditions d'utilisation et de la
/// Politique de confidentialité, avec liens ouvrant les textes stockés
/// dans les assets (fichiers .txt).
class LegalAcceptance extends StatelessWidget {
  final bool accepted;
  final ValueChanged<bool> onChanged;

  const LegalAcceptance({super.key, required this.accepted, required this.onChanged});

  Future<void> _open(BuildContext context, String assetPath, String title) async {
    final content = await rootBundle.loadString(assetPath);
    if (!context.mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 1,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Column(children: [
            Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(2))),
            Row(children: [
              const Icon(Icons.description_outlined, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F1B4C)))),
              IconButton(icon: const Icon(Icons.close, color: Colors.black54), onPressed: () => Navigator.pop(context)),
            ]),
            const SizedBox(height: 4),
            Expanded(child: SingleChildScrollView(controller: controller, child: SelectableText(content, style: const TextStyle(fontSize: 13.5, height: 1.5, color: Colors.black87)))),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const linkStyle = TextStyle(color: AppColors.accent, fontWeight: FontWeight.w700, decoration: TextDecoration.underline);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Transform.scale(
          scale: 0.95,
          child: Checkbox(
            value: accepted,
            onChanged: (v) => onChanged(v ?? false),
            activeColor: AppColors.accent,
            checkColor: const Color(0xFF0F1B4C),
            side: const BorderSide(color: Colors.white38),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text.rich(
            TextSpan(style: const TextStyle(fontSize: 12.5, height: 1.4, color: Colors.white70), children: [
              const TextSpan(text: 'J\'ai lu et j\'accepte les '),
              TextSpan(
                text: 'Conditions d\'utilisation',
                style: linkStyle,
                recognizer: TapGestureRecognizer()
                  ..onTap = () => _open(context, 'assets/terms_of_use.txt', 'Conditions d\'utilisation'),
              ),
              const TextSpan(text: ' et la '),
              TextSpan(
                text: 'Politique de confidentialité',
                style: linkStyle,
                recognizer: TapGestureRecognizer()
                  ..onTap = () => _open(context, 'assets/privacy_policy.txt', 'Politique de confidentialité'),
              ),
              const TextSpan(text: ' du service.'),
            ]),
          ),
        )),
      ]),
    );
  }
}
