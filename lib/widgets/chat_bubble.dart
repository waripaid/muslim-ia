import 'dart:io';
import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../l10n/app_localizations.dart';
import '../models/chat_message.dart';
import 'typewriter_text.dart';
import 'voice_bubble.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onSourceTap;
  final VoidCallback? onContinue;
  final VoidCallback? onCopy;
  final VoidCallback? onEdit;
  final VoidCallback? onShare;
  final bool isLoading;
  final bool isStreaming;
  final bool autoplayAudio;
  final VoidCallback? onAutoplayTriggered;

  const ChatBubble({
    super.key,
    required this.message,
    this.onSourceTap,
    this.onContinue,
    this.onCopy,
    this.onEdit,
    this.onShare,
    this.isLoading = false,
    this.isStreaming = false,
    this.autoplayAudio = false,
    this.onAutoplayTriggered,
  });

  static final _nameRegex = _buildNameRegex();
  static final _sourceRegex = RegExp(r'\[SOURCE\](.*?)\[/SOURCE\]', dotAll: true);
  static final _verseRefRegex = RegExp(
    r'\([^)]*(?:\d+:\d+|verset\s+\d+|sourate\s+\d+|ayah|āyah)[^)]*\)',
    caseSensitive: false,
  );

  static RegExp _buildNameRegex() {
    const names = [
      'Allah', 'Muhammad', 'Mohammed', 'Ibrahim', 'Abraham', 'Musa', 'Moïse', 'Moses',
      'Isa', 'Jésus', 'Jesus', 'Nuh', 'Noé', 'Noah', 'Adam', 'Yusuf', 'Joseph',
      'Sulayman', 'Salomon', 'Solomon', 'Dawud', 'David', 'Yunus', 'Jonas', 'Jonah',
      'Ayyub', 'Job', 'Yaqub', 'Jacob', 'Ismail', 'Ishmael', 'Ishaq', 'Isaac',
      'Harun', 'Aaron', 'Zakariyya', 'Zacharie', 'Yahya', 'Jean-Baptiste', 'John',
      'Maryam', 'Marie', 'Mary', 'Hajar', 'Agar', 'Hagar', 'Sara', 'Sarah',
      'Jibril', 'Gabriel', 'Mikail', 'Michael', 'Israfil', 'Azrael', 'Malik',
      'Ridwan', 'Iblis', 'Satan', 'Shaytan', 'Fir\'awn', 'Pharaon', 'Pharaoh',
      'Qarun', 'Korah', 'Hamman', 'Goliath', 'Jalut', 'Talut', 'Saul',
      'Dhul-Qarnayn', 'Luqman', 'Uzayr', 'Ezra', 'Zulaykha',
      'Abu Bakr', 'Umar', 'Omar', 'Uthman', 'Othman', 'Ali', 'Aisha', 'Aïcha',
      'Khadija', 'Fatima', 'Hassan', 'Hussein', 'Husayn', 'Bilal',
      'Abu Hurayra', 'Anas', 'Ibn Abbas', 'Ibn Umar', 'Ibn Mas\'ud',
      'Ibn Kathir', 'At-Tabari', 'Tabari', 'Al-Qurtubi', 'Qurtubi', 'Al-Bukhari', 'Bukhari',
      'Muslim', 'At-Tirmidhi', 'Tirmidhi', 'Abu Dawud', 'An-Nasa\'i', 'Ibn Majah',
      'Imam Malik', 'Imam Ahmad', 'Imam Shafi\'i', 'Imam Abu Hanifa',
      'Al-Ghazali', 'Ibn Taymiyyah', 'Ibn Al-Qayyim', 'An-Nawawi',
      'Hamidullah', 'Montada', 'Rachid Maach', 'Sa\'di',
    ];
    final pattern = names.map((n) => RegExp.escape(n)).join('|');
    return RegExp('\\b($pattern)\\b', caseSensitive: false);
  }

  static bool _isSourceLine(String line) {
    if (line.trim().isEmpty) return false;
    final arabicChars = line.runes.where((r) => r >= 0x0600 && r <= 0x06FF).length;
    final totalChars = line.trim().length;
    if (totalChars > 0 && arabicChars > totalChars * 0.4) return true;
    if (_verseRefRegex.hasMatch(line)) return true;
    return false;
  }

  static List<TextSpan> _formatText(String text, ThemeColors colors) {
    final spans = <TextSpan>[];

    // Step 1: Handle [SOURCE] blocks
    int lastEnd = 0;
    for (final match in _sourceRegex.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.addAll(_formatLines(text.substring(lastEnd, match.start), colors));
      }
      spans.add(TextSpan(
        text: match.group(1)!.trim(),
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.accent, height: 1.8),
      ));
      lastEnd = match.end;
    }
    if (lastEnd < text.length) {
      spans.addAll(_formatLines(text.substring(lastEnd), colors));
    }

    if (spans.isEmpty) {
      spans.addAll(_formatLines(text, colors));
    }

    return spans;
  }

  static List<TextSpan> _formatLines(String text, ThemeColors colors) {
    final spans = <TextSpan>[];
    final lines = text.split('\n');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final isLast = i == lines.length - 1;
      final lineText = isLast ? line : '$line\n';

      if (_isSourceLine(line)) {
        spans.add(TextSpan(
          text: lineText,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.accent, height: 1.8),
        ));
      } else {
        final parts = _highlightNames(lineText);
        if (parts != null) {
          spans.addAll(parts);
        } else {
          spans.add(TextSpan(text: lineText));
        }
      }
    }

    return spans;
  }

  static List<TextSpan>? _highlightNames(String text) {
    final spans = <TextSpan>[];
    int lastEnd = 0;

    for (final match in _nameRegex.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }
      spans.add(TextSpan(
        text: match.group(0),
        style: const TextStyle(fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),
      ));
      lastEnd = match.end;
    }
    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }

    return spans.isEmpty ? null : spans;
  }

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatRole.user;
    final maxWidth = MediaQuery.of(context).size.width * 0.88;
    final colors = ThemeColors.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isUser)
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onLongPress: (onCopy != null || onEdit != null) ? () => _showUserActions(context) : null,
                child: Container(
                  constraints: BoxConstraints(maxWidth: maxWidth * 0.85),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFE8C547), Color(0xFFC5A028), Color(0xFF9B7B1C)]),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(6),
                    ),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFFC5A028).withValues(alpha: 0.3), blurRadius: 14, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.imagePath != null)
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                          child: Image.file(File(message.imagePath!), fit: BoxFit.cover, width: double.infinity),
                        ),
                      if (message.fromVoice) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.mic_rounded, size: 13, color: Colors.white),
                              const SizedBox(width: 5),
                              Text(
                                AppLocalizations.of(context).chatVoiceTranscriptionLabel,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.3),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],
                      Padding(
                        padding: message.imagePath != null ? const EdgeInsets.all(12) : const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        child: message.audioPath != null
                            ? VoiceBubble(
                                audioPath: message.audioPath!,
                                barColor: Colors.white,
                              )
                            : Text(
                                message.content,
                                style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.5),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset('assets/muslimia.jpeg', width: 28, height: 28, fit: BoxFit.cover),
                    ),
                    const SizedBox(width: 8),
                    Text('Muslim IA', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: colors.textPrimary)),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  width: message.audioPath != null ? null : double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.audioPath != null) ...[
                        const SizedBox(height: 4),
                        VoiceBubble(
                          audioPath: message.audioPath!,
                          barColor: AppColors.accent,
                          autoplay: autoplayAudio,
                          onAutoplayTriggered: onAutoplayTriggered,
                        ),
                        const SizedBox(height: 10),
                      ],
                      if (isStreaming && message.audioPath == null)
                        TypeWriterText(
                          text: message.content,
                          animate: true,
                          style: TextStyle(fontSize: 15, height: 1.7, color: colors.textPrimary),
                          formatter: (t) => _formatText(t, colors),
                        )
                      else
                        SelectableText.rich(
                            TextSpan(
                              style: TextStyle(fontSize: 15, height: 1.7, color: colors.textPrimary),
                              children: _formatText(message.content, colors),
                            ),
                          ),
                      if (message.sources != null && message.sources!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.accent.withValues(alpha: 0.1)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(children: [
                                Icon(Icons.menu_book_rounded, size: 15, color: AppColors.accent),
                                SizedBox(width: 6),
                                Text('Sources', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.accent)),
                              ]),
                              const SizedBox(height: 8),
                              ...message.sources!.map((s) => Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: InkWell(
                                      onTap: onSourceTap,
                                      child: Text(
                                        '📖 ${s.reference}',
                                        style: TextStyle(fontSize: 12, color: colors.textSecondary),
                                      ),
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ],
                      if (message.isIncomplete) ...[
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: isLoading
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                  child: SizedBox(
                                    width: 18, height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2.2, color: AppColors.accent.withValues(alpha: 0.7)),
                                  ),
                                )
                              : InkWell(
                                  onTap: onContinue,
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(colors: [Color(0xFFC5A028), Color(0xFF9B7B1C)]),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [BoxShadow(color: const Color(0xFFC5A028).withValues(alpha: 0.25), blurRadius: 10, offset: const Offset(0, 3))],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.play_arrow_rounded, size: 16, color: Colors.white),
                                        const SizedBox(width: 6),
                                        Text(AppLocalizations.of(context).chatContinue, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                                      ],
                                    ),
                                  ),
                                ),
                        ),
                      ],
                      if (!isLoading && !message.isIncomplete) ...[
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            _ActionIcon(
                              tooltip: AppLocalizations.of(context).chatCopy,
                              icon: Icons.copy_rounded,
                              onTap: onCopy,
                            ),
                            const SizedBox(width: 6),
                            _ActionIcon(
                              tooltip: AppLocalizations.of(context).chatShare,
                              icon: Icons.share_rounded,
                              onTap: onShare,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
    );
  }

  void _showUserActions(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = ThemeColors.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy_rounded, color: AppColors.accent),
              title: Text(l10n.chatCopy, style: TextStyle(fontWeight: FontWeight.w600, color: colors.textPrimary)),
              onTap: () {
                Navigator.pop(ctx);
                onCopy?.call();
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_rounded, color: AppColors.accent),
              title: Text(l10n.chatEdit, style: TextStyle(fontWeight: FontWeight.w600, color: colors.textPrimary)),
              onTap: () {
                Navigator.pop(ctx);
                onEdit?.call();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback? onTap;

  const _ActionIcon({required this.tooltip, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = ThemeColors.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Tooltip(
          message: tooltip,
          child: Icon(icon, size: 17, color: colors.textSecondary),
        ),
      ),
    );
  }
}
