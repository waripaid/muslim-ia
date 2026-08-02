import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';

class VerseCard extends StatelessWidget {
  final String sourate;
  final String verset;
  final String? texteArabe;
  final String? traduction;
  final bool isFavorite;
  final VoidCallback? onFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onDeepDive;

  const VerseCard({
    super.key, required this.sourate, required this.verset,
    this.texteArabe, this.traduction, this.isFavorite = false,
    this.onFavorite, this.onTap, this.onDeepDive,
  });

  void _copyToClipboard(BuildContext context) {
    final text = '$sourate $verset\n${texteArabe ?? ''}\n${traduction ?? ''}';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$sourate $verset copié'), duration: const Duration(seconds: 1), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = ThemeColors.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.12)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('$sourate $verset',
                      style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary, fontSize: 12)),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => _copyToClipboard(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    child: Icon(Icons.copy_rounded, size: 16, color: colors.textLight),
                  ),
                ),
                GestureDetector(
                  onTap: onFavorite,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isFavorite ? AppColors.accent.withValues(alpha: 0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isFavorite ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                      size: 20, color: isFavorite ? AppColors.accent : colors.textLight,
                    ),
                  ),
                ),
                if (onDeepDive != null)
                  GestureDetector(
                    onTap: onDeepDive,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      child: const Icon(Icons.psychology_rounded, size: 16, color: AppColors.primaryLight),
                    ),
                  ),
              ]),
              if (texteArabe != null && texteArabe!.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(texteArabe!,
                    style: TextStyle(fontSize: 22, color: colors.textPrimary, height: 1.9),
                    textDirection: TextDirection.rtl, textAlign: TextAlign.right),
              ],
              if (traduction != null && traduction!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.primarySurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.accent.withValues(alpha: 0.08)),
                  ),
                  child: Text(traduction!,
                      style: TextStyle(fontSize: 13, color: colors.textSecondary, fontStyle: FontStyle.italic, height: 1.5)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
