import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../config/theme.dart';
import '../l10n/app_localizations.dart';
import '../models/chat_message.dart';
import '../providers/chat_provider.dart';
import '../providers/internet_status_provider.dart';
import '../providers/memory_provider.dart';
import '../services/api_service.dart';
import '../utils/logger.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/thinking_animation.dart';
import '../widgets/voice_bubble.dart';

/// Voix Mistral sauvegardée à utiliser pour la synthèse vocale.
/// Fournir via --dart-define=MISTRAL_VOICE_ID=<voice_id> (laissée vide = voix par défaut).
const _kMistralVoiceId = String.fromEnvironment('MISTRAL_VOICE_ID');

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _focus = FocusNode();
  late final AnimationController _pulse;
  final _audioRecorder = FlutterSoundRecorder();
  final _tts = FlutterTts();
  bool _showFab = false;
  int _lastMsgCount = 0;
  bool _isRecording = false;
  bool _isEditingMessage = false;
  bool _voiceMode = false;
  bool _audioTranscriptionMode = false;
  String? _lastSpokenMessageId;
  String? _autoplayAudioId;
  String? _pendingImage;
  String? _recordedAudioPath;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..repeat(reverse: true);
    _scrollCtrl.addListener(() {
      final show = _scrollCtrl.hasClients && _scrollCtrl.offset >= 200;
      if (show != _showFab) setState(() => _showFab = show);
    });
    context.read<ChatProvider>().addListener(_onChatChanged);
    _initAudio();
    _initTts();
  }

  @override
  void dispose() {
    context.read<ChatProvider>().removeListener(_onChatChanged);
    _tts.stop();
    _ctrl.dispose(); _scrollCtrl.dispose(); _focus.dispose(); _pulse.dispose();
    _audioRecorder.closeRecorder();
    super.dispose();
  }

  void _onChatChanged() {
    final chat = context.read<ChatProvider>();
    AppLogger.info('ChatScreen', 'onChatChanged: voiceMode=$_voiceMode loading=${chat.isLoading} msgs=${chat.messages.length}');
    if (chat.isLoading) return;
    _maybeSynthesizeLast(chat);
  }

  void _maybeSynthesizeLast(ChatProvider chat) {
    if (!_voiceMode) return;
    if (chat.messages.isEmpty) return;
    final last = chat.messages.last;
    if (last.role != ChatRole.assistant || last.isIncomplete) return;
    if (last.id == _lastSpokenMessageId) return;
    if (last.audioPath != null) return;
    _lastSpokenMessageId = last.id;
    AppLogger.info('ChatScreen', 'Réponse vocale déclenchée');
    _synthesizeResponse(chat, last);
  }

  Future<void> _synthesizeResponse(ChatProvider chat, ChatMessage message) async {
    chat.setSynthesizing(true);
    try {
      final api = context.read<ApiService>();
      final lang = Localizations.localeOf(context).languageCode;
      final result = await api.textToSpeech(
        _cleanForShare(message.content),
        language: lang,
        voiceId: _kMistralVoiceId.isEmpty ? null : _kMistralVoiceId,
      );
      final audio = result['audio'];
      if (result['success'] == true && audio is String && audio.isNotEmpty) {
        final bytes = base64Decode(audio);
        final docs = await getApplicationDocumentsDirectory();
        final dir = Directory('${docs.path}/voice_messages');
        await dir.create(recursive: true);
        final dest = '${dir.path}/reply_${message.id}.mp3';
        await File(dest).writeAsBytes(bytes);
        if (!mounted) return;
        setState(() => _autoplayAudioId = message.id);
        chat.setMessageAudio(message.id, dest);
        return;
      }
      AppLogger.warn('ChatScreen', 'TTS serveur sans audio, repli TTS local');
      _speak(_cleanForShare(message.content));
    } catch (e) {
      AppLogger.warn('ChatScreen', 'TTS serveur échoué, repli TTS local: $e');
      _speak(_cleanForShare(message.content));
    } finally {
      chat.setSynthesizing(false);
    }
  }

  Future<void> _initTts() async {
    try {
      await _tts.setSpeechRate(0.45);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
    } catch (e) {
      AppLogger.warn('ChatScreen', 'TTS indisponible: $e');
    }
  }

  Future<void> _speak(String text) async {
    try {
      final lang = Localizations.localeOf(context).languageCode;
      await _tts.setLanguage(lang == 'ar' ? 'ar-SA' : lang == 'en' ? 'en-US' : lang == 'es' ? 'es-ES' : lang == 'pt' ? 'pt-PT' : lang == 'ru' ? 'ru-RU' : lang == 'zh' ? 'zh-CN' : 'fr-FR');
      final clean = _cleanForShare(text);
      if (clean.trim().isNotEmpty) {
        await _tts.stop();
        await _tts.speak(clean);
      }
    } catch (e) {
      AppLogger.warn('ChatScreen', 'Erreur synthèse vocale: $e');
    }
  }

  Future<void> _send() async {
    final t = _ctrl.text.trim();
    final hasImage = _pendingImage != null;
    if (t.isEmpty && !hasImage) return;
    final chat = context.read<ChatProvider>();
    if (chat.isLoading) return;

    if (!chat.canSendMessage) {
      AppLogger.warn('ChatScreen', 'Limite de messages atteinte');
      _showLimitDialog();
      return;
    }

    AppLogger.info('ChatScreen', 'Message envoyé: ${t.length > 40 ? '${t.substring(0, 40)}...' : t}');
    _tts.stop();
    _ctrl.clear();
    if (_audioTranscriptionMode) {
      setState(() {
        _audioTranscriptionMode = false;
        _voiceMode = true;
      });
    } else if (_isEditingMessage || _voiceMode) {
      setState(() {
        _isEditingMessage = false;
        _voiceMode = false;
      });
    }

    if (hasImage) {
      final imagePath = _pendingImage!;
      final message = t.isNotEmpty ? t : '';
      setState(() => _pendingImage = null);
      chat.sendImage(imagePath, message: message);
    } else {
      // Extraire la mémoire avant d'envoyer
      try {
        context.read<MemoryProvider>().rememberFact('${DateTime.now().toIso8601String().substring(5, 10)} - Utilisateur: "$t"');
      } catch (_) {}
      await chat.sendMessage(t);
      if (mounted) _maybeSynthesizeLast(chat);
    }
    _focus.requestFocus();
  }

  void _showLimitDialog() {
    final l10n = AppLocalizations.of(context);
    AppLogger.warn('ChatScreen', 'Dialogue limite affiché');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.chatLimitTitle),
        content: Text(l10n.chatLimitBody(ChatProvider.maxFreeMessages)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.later)),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  void _scrollDown() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chat, _) {
        // Auto-scroll uniquement quand nouveau message détecté
        if (chat.messages.length > _lastMsgCount && _scrollCtrl.hasClients) {
          _lastMsgCount = chat.messages.length;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollCtrl.hasClients) {
              _scrollCtrl.animateTo(0, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
            }
          });
        }

        final colors = ThemeColors.of(context);
        final l10n = AppLocalizations.of(context);
        final offline = context.watch<InternetStatusProvider>().isOffline;

        return Column(
          children: [
            if (offline) _offlineBanner(colors, l10n),
            Expanded(child: chat.messages.isEmpty ? _empty() : _list(chat)),
            _input(chat),
          ],
        );
      },
    );
  }

  Widget _offlineBanner(ThemeColors colors, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.error.withValues(alpha: 0.10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off_rounded, size: 16, color: AppColors.error),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              l10n.offlineBanner,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _empty() {
    final colors = ThemeColors.of(context);
    final l10n = AppLocalizations.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            AnimatedBuilder(
              animation: _pulse,
              builder: (_, child) => Opacity(opacity: 0.5 + _pulse.value * 0.3, child: child),
              child: Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: const Color(0xFFC5A028).withValues(alpha: 0.25), blurRadius: 20)],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset('assets/muslimia.jpeg', fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Muslim IA', textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: colors.textPrimary, letterSpacing: -0.3)),
            const SizedBox(height: 8),
            Text(l10n.appTagline, textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: colors.textSecondary)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
              decoration: BoxDecoration(
                gradient: Theme.of(context).brightness == Brightness.dark
                    ? const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF16286B), Color(0xFF1E3A8A)])
                    : const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFFFF8E1), Color(0xFFF5E6B8)]),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.accent.withValues(alpha: 0.18)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      gradient: AppGradients.gold,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: AppColors.accent.withValues(alpha: 0.3), blurRadius: 10)],
                    ),
                    child: const Icon(Icons.wb_sunny_rounded, size: 20, color: Color(0xFF0F1B4C)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      l10n.chatWelcomeTitle,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: colors.textPrimary, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _suggestion('📖', l10n.chatSuggestionQuran, colors),
            _suggestion('🕌', l10n.chatSuggestionSurah, colors),
            _suggestion('🧠', l10n.chatSuggestionWord, colors),
            _suggestion('💡', l10n.chatSuggestionAdvice, colors),
            _suggestion('📝', l10n.chatSuggestionVocab, colors),
            _suggestion('🕊️', l10n.chatSuggestionProphet, colors),
          ],
        ),
      ),
    );
  }

  Widget _suggestion(String icon, String text, ThemeColors colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => context.read<ChatProvider>().sendMessage(text),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 16, 12),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.18)),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 3)),
            ],
          ),
          child: Row(children: [
            Container(
              width: 40, height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFFFF8E1), Color(0xFFF5E6B8)]),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.accent.withValues(alpha: 0.15)),
              ),
              child: Text(icon, style: const TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 14),
            Expanded(child: Text(text, style: TextStyle(fontSize: 14, color: colors.textSecondary))),
            const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: AppColors.textLight),
          ]),
        ),
      ),
    );
  }

  Widget _list(ChatProvider chat) {
    // En mode vocal, la réponse ne s'affiche qu'une fois la voix générée :
    // le message reste sur « réflexion en cours » tant que le texte n'est pas
    // terminé (isLoading) OU que la voix est encore en cours (isSynthesizing),
    // et tant que audioPath est absent.
    final voiceBusy = chat.isLoading || chat.isSynthesizing;
    final voicePending = _voiceMode &&
        voiceBusy &&
        chat.messages.isNotEmpty &&
        chat.messages.last.role == ChatRole.assistant &&
        chat.messages.last.audioPath == null;
    final showThinking = voiceBusy && !voicePending;
    return Stack(
      children: [
        ListView.builder(
          controller: _scrollCtrl,
          reverse: true,
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: chat.messages.length + (showThinking ? 1 : 0),
          itemBuilder: (context, i) {
            if (showThinking && i == 0) return const ThinkingAnimation();
            final idx = chat.messages.length - 1 - i + (showThinking ? 1 : 0);
            if (voicePending && idx == chat.messages.length - 1) {
              return const ThinkingAnimation();
            }
            final msg = chat.messages[idx];
            final isLastAssistant = msg.role == ChatRole.assistant && idx == chat.messages.length - 1;
            return ChatBubble(
              message: msg,
              autoplayAudio: _autoplayAudioId != null && msg.id == _autoplayAudioId,
              isStreaming: isLastAssistant && chat.isLoading && !voicePending,
              onSourceTap: () {
                if (msg.sources != null && msg.sources!.isNotEmpty) {
                  _showSourceSheet(context, msg.sources!.first);
                }
              },
              onContinue: () => chat.continueResponse(),
              onCopy: () => _copyText(msg.content),
              onEdit: () => _editMessage(chat, idx),
              onShare: () => _shareText(msg.content),
              isLoading: chat.isLoading,
            );
          },
        ),
        if (_showFab)
          Positioned(
            bottom: 8, right: 16,
            child: GestureDetector(
              onTap: _scrollDown,
              child: Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: AppColors.surface, shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFEBE5D7)),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                ),
                child: const Icon(Icons.keyboard_arrow_down_rounded, size: 22, color: AppColors.textSecondary),
              ),
            ),
          ),
      ],
    );
  }

  Widget _input(ChatProvider chat) {
    final hasText = _ctrl.text.trim().isNotEmpty || _pendingImage != null;
    final colors = ThemeColors.of(context);
    final l10n = AppLocalizations.of(context);
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(10, 8, 10, 8 + bottomInset),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, -4))],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Recording indicator
        if (_isRecording)
          Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              Expanded(
                child: Center(child: _RecordingWave(stream: _audioRecorder.onProgress)),
              ),
              GestureDetector(
                onTap: _onRecordCancel,
                child: Container(padding: const EdgeInsets.all(3), decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                  child: const Icon(Icons.close_rounded, size: 14, color: AppColors.error)),
              ),
            ]),
          ),
        if (_isEditingMessage)
          Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              const Icon(Icons.edit_rounded, size: 15, color: AppColors.accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.chatEditing,
                  style: const TextStyle(fontSize: 12, color: AppColors.accent, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: _cancelEdit,
                child: Container(padding: const EdgeInsets.all(3), decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                  child: const Icon(Icons.close_rounded, size: 14, color: AppColors.accent),
                ),
              ),
            ]),
          ),
        if (_audioTranscriptionMode)
          GestureDetector(
            onTap: _isRecording ? _onRecordEnd : _onRecordStart,
            child: Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                Icon(_isRecording ? Icons.stop_circle_rounded : Icons.mic_rounded, size: 18, color: _isRecording ? AppColors.error : AppColors.accent),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.chatAudioTranscriptionActive,
                    style: TextStyle(fontSize: 13, color: _isRecording ? AppColors.error : AppColors.accent, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (_isRecording) _onRecordCancel();
                    setState(() => _audioTranscriptionMode = false);
                  },
                  child: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(5)),
                    child: const Icon(Icons.close_rounded, size: 18, color: AppColors.accent),
                  ),
                ),
              ]),
            ),
          ),
        if (_pendingImage != null)
          Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: colors.primarySurface, borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(File(_pendingImage!), height: 36, width: 36, fit: BoxFit.cover)),
              const SizedBox(width: 8),
              Expanded(child: Text(l10n.chatPhotoSelected, style: TextStyle(fontSize: 11, color: colors.textSecondary))),
              GestureDetector(
                onTap: () => setState(() => _pendingImage = null),
                child: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(5)),
                  child: const Icon(Icons.close_rounded, size: 16, color: AppColors.error)),
              ),
            ]),
          ),
        if (_recordedAudioPath != null)
          _voicePreview(colors, l10n)
        else
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        GestureDetector(
          onTap: _showAttachSheet,
          child: Container(
            width: 40, height: 48,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.add_circle_outline_rounded, size: 22, color: AppColors.accent),
          ),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(color: colors.background, borderRadius: BorderRadius.circular(28), border: Border.all(color: colors.cardBorder)),
            child: TextField(
              controller: _ctrl, focusNode: _focus,
              textInputAction: TextInputAction.send, onSubmitted: (_) => _send(),
              onChanged: (_) => setState(() {}),
              maxLines: 4, minLines: 1,
              style: TextStyle(fontSize: 14.5, color: colors.textPrimary),
              decoration: InputDecoration(
                hintText: l10n.chatInputHint,
                hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 14.5),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Mic / Send toggle
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: hasText
              ? GestureDetector(
                  key: const ValueKey('send'),
                  onTap: chat.isLoading ? null : _send,
                  child: Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      gradient: chat.isLoading ? null : const LinearGradient(colors: [Color(0xFFC5A028), Color(0xFF9B7B1C)]),
                      color: chat.isLoading ? const Color(0xFFEBE5D7) : null,
                      shape: BoxShape.circle,
                      boxShadow: chat.isLoading ? null : [BoxShadow(color: const Color(0xFFC5A028).withValues(alpha: 0.35), blurRadius: 14, offset: const Offset(0, 4))],
                    ),
                    child: chat.isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.textLight))
                        : const Icon(Icons.send_rounded, size: 20, color: Colors.white),
                  ),
                )
              : _audioTranscriptionMode
                  ? const SizedBox.shrink()
                  : GestureDetector(
                  key: const ValueKey('mic'),
                  onLongPressStart: (_) => _onRecordStart(),
                  onLongPressEnd: (_) => _onRecordEnd(),
                  onLongPressCancel: () => _onRecordCancel(),
                  child: AnimatedBuilder(
                    animation: _pulse,
                    builder: (context, child) => Transform.scale(
                      scale: _isRecording ? 1.15 + _pulse.value * 0.55 : 1.0,
                      child: child,
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        gradient: _isRecording
                            ? const LinearGradient(colors: [Color(0xFFE74C3C), Color(0xFFC0392B)])
                            : const LinearGradient(colors: [Color(0xFFC5A028), Color(0xFF9B7B1C)]),
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(
                          color: _isRecording ? const Color(0xFFE74C3C).withValues(alpha: 0.4) : const Color(0xFFC5A028).withValues(alpha: 0.35),
                          blurRadius: _isRecording ? 20 : 14, offset: const Offset(0, 4),
                        )],
                      ),
                      child: Icon(
                        Icons.mic_rounded,
                        size: _isRecording ? 26 : 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
          ), // AnimatedSwitcher
        ]), // fin Row (input)
        ], // fin Column du conteneur
      ),
    );
  }

  Future<void> _initAudio() async {
    try {
      await _audioRecorder.openRecorder();
    } catch (_) {}
  }

  Future<void> _onRecordStart() async {
    _tts.stop();
    try {
      final mic = Permission.microphone;
      var status = await mic.status;
      if (status.isPermanentlyDenied) {
        _showMicSettingsDialog();
        return;
      }
      if (!status.isGranted) {
        status = await mic.request();
        if (status.isPermanentlyDenied) {
          _showMicSettingsDialog();
          return;
        }
        if (!status.isGranted) {
          AppLogger.warn('ChatScreen', 'Permission micro refusée: $status');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(AppLocalizations.of(context).chatMicPermission),
            ));
          }
          return;
        }
      }
      final dir = Directory.systemTemp.createTempSync('muslim_ia_audio_');
      final path = '${dir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.wav';
      await _audioRecorder.startRecorder(
        toFile: path,
        codec: Codec.pcm16WAV,
        sampleRate: 16000,
        numChannels: 1,
      );
      await _audioRecorder.setSubscriptionDuration(const Duration(milliseconds: 100));
      if (!mounted) return;
      setState(() {
        _isRecording = true;
      });
      AppLogger.info('ChatScreen', 'Enregistrement démarré');
    } catch (e) {
      AppLogger.error('ChatScreen', 'Erreur enregistrement', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context).chatRecordError(e.toString())),
        ));
      }
      setState(() => _isRecording = false);
    }
  }

  void _showMicSettingsDialog() {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(l10n.chatMicPermissionTitle),
        content: Text(l10n.chatMicPermissionDenied),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
            child: Text(l10n.chatMicSettings),
          ),
        ],
      ),
    );
  }

  Future<void> _onRecordEnd() async {
    if (!_isRecording) return;
    try {
      final path = await _audioRecorder.stopRecorder();
      setState(() => _isRecording = false);
      if (path != null && File(path).existsSync()) {
        if (_audioTranscriptionMode) {
          await _transcribeToField(path);
        } else {
          setState(() => _recordedAudioPath = path);
          AppLogger.info('ChatScreen', 'Enregistrement prêt pour aperçu vocal');
        }
      }
    } catch (e) {
      AppLogger.error('ChatScreen', 'Erreur arrêt enregistrement', e);
      setState(() => _isRecording = false);
    }
  }

  /// Transcrit l'audio enregistré et l'insère dans le champ de saisie
  Future<void> _transcribeToField(String path) async {
    final l10n = AppLocalizations.of(context);
    try {
      final bytes = await File(path).readAsBytes();
      final base64Str = base64Encode(bytes);
      final api = context.read<ApiService>();
      final lang = Localizations.localeOf(context).languageCode;
      final result = await api.transcribeAudio(base64Str, language: lang);
      try { File(path).delete(); } catch (_) {}
      if (!mounted) return;
      final text = result['text'] ?? '';
      if (text.trim().isNotEmpty) {
        final current = _ctrl.text;
        final newText = current.trim().isEmpty ? text.trim() : '$current ${text.trim()}';
        _ctrl.text = newText;
        _ctrl.selection = TextSelection.collapsed(offset: newText.length);
        setState(() {});
        _focus.requestFocus();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.chatNoTextDetected)));
      }
    } catch (e) {
      AppLogger.error('ChatScreen', 'Erreur transcription dictée', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.chatTranscriptionError(e.toString()))));
      }
    }
  }

  Future<void> _onRecordCancel() async {
    if (!_isRecording) return;
    try {
      await _audioRecorder.stopRecorder();
      if (_recordedAudioPath != null && File(_recordedAudioPath!).existsSync()) {
        File(_recordedAudioPath!).delete();
      }
    } catch (_) {}
    setState(() {
      _isRecording = false;
      _recordedAudioPath = null;
    });
  }

  void _copyText(String content) {
    final l10n = AppLocalizations.of(context);
    final cleaned = _cleanForShare(content);
    Clipboard.setData(ClipboardData(text: cleaned));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.chatCopied), duration: const Duration(seconds: 2)));
  }

  Future<void> _shareText(String content) async {
    final cleaned = _cleanForShare(content);
    await Share.share(cleaned);
  }

  void _editMessage(ChatProvider chat, int idx) {
    final text = chat.editMessage(chat.messages[idx]);
    if (text.isEmpty) return;
    _ctrl.text = text;
    _ctrl.selection = TextSelection.collapsed(offset: text.length);
    setState(() => _isEditingMessage = true);
    _focus.requestFocus();
  }

  void _cancelEdit() {
    _ctrl.clear();
    setState(() => _isEditingMessage = false);
    _focus.unfocus();
  }

  String _cleanForShare(String content) {
    return content
        .replaceAll(RegExp(r'\[SOURCE\](.*?)\[/SOURCE\]', dotAll: true), r'$1')
        .trim();
  }

  void _showSourceSheet(BuildContext context, QuranSource source) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.menu_book_rounded, color: AppColors.accent, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '📖 ${source.reference}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (source.texteArabe != null && source.texteArabe!.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.accent.withValues(alpha: 0.12)),
                  ),
                  child: Text(
                    source.texteArabe!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, height: 1.9, color: Color(0xFFC5A028), fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (source.traduction != null && source.traduction!.isNotEmpty)
                Text(
                  source.traduction!,
                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.6),
                ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accent,
                    side: BorderSide(color: AppColors.accent.withValues(alpha: 0.4)),
                  ),
                  child: Text(AppLocalizations.of(ctx).close),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _voicePreview(ThemeColors colors, AppLocalizations l10n) {
    final path = _recordedAudioPath!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accent.withValues(alpha: 0.18),
            AppColors.accent.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _cancelVoice,
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: colors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: colors.cardBorder),
              ),
              child: Icon(Icons.close_rounded, size: 20, color: colors.textSecondary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: VoiceBubble(
              audioPath: path,
              barColor: AppColors.accent,
              autoplay: true,
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _sendVoiceMessage(path),
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFC5A028), Color(0xFF9B7B1C)]),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: const Color(0xFFC5A028).withValues(alpha: 0.35), blurRadius: 14, offset: const Offset(0, 4))],
              ),
              child: const Icon(Icons.send_rounded, size: 20, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _cancelVoice() {
    final path = _recordedAudioPath;
    setState(() => _recordedAudioPath = null);
    if (path != null) {
      try { File(path).delete(); } catch (_) {}
    }
  }

  Future<void> _sendVoiceMessage(String path) async {
    final l10n = AppLocalizations.of(context);

    // Copier l'audio vers un emplacement persistant pour la bulle vocale
    String? persistentPath;
    try {
      final docs = await getApplicationDocumentsDirectory();
      final voiceDir = Directory('${docs.path}/voice_messages');
      await voiceDir.create(recursive: true);
      final dest = '${voiceDir.path}/${DateTime.now().millisecondsSinceEpoch}.wav';
      await File(path).copy(dest);
      persistentPath = dest;
    } catch (e) {
      AppLogger.warn('ChatScreen', 'Persistance audio impossible: $e');
    }
    try { File(path).delete(); } catch (_) {}

    // Afficher immédiatement le message vocal dans la conversation
    final audioPath = persistentPath ?? path;
    final chat = context.read<ChatProvider>();
    final userMessageId = chat.sendVoice(audioPath);

    if (mounted) {
      setState(() {
        _voiceMode = true;
        _lastSpokenMessageId = null;
        _recordedAudioPath = null;
      });
    }

    // Transcrire en arrière-plan puis générer la réponse
    try {
      final bytes = await File(audioPath).readAsBytes();
      final base64Str = base64Encode(bytes);
      final api = context.read<ApiService>();
      final lang = Localizations.localeOf(context).languageCode;
      final result = await api.transcribeAudio(base64Str, language: lang);
      final text = result['text'] ?? '';
      if (text.trim().isNotEmpty) {
        await chat.attachVoiceText(text, userMessageId);
      } else {
        chat.finishProcessing();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.chatNoTextDetected)));
        }
      }
    } catch (e) {
      AppLogger.error('ChatScreen', 'Erreur transcription', e);
      chat.finishProcessing();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.chatTranscriptionError(e.toString()))));
      }
    }
  }

  void _showAttachSheet() {
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
            const SizedBox(height: 12),
            Row(children: [
              const SizedBox(width: 20),
              Expanded(child: Text(l10n.chatAttachTitle, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: colors.textPrimary))),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textLight),
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                ),
              ),
            ]),
            const SizedBox(height: 8),
            _attachTile(ctx, Icons.photo_library_rounded, l10n.chatChooseImage, () {
              Navigator.pop(ctx);
              _pickImage();
            }),
            _attachTile(ctx, Icons.photo_camera_rounded, l10n.chatTakePhoto, () {
              Navigator.pop(ctx);
              _takePhoto();
            }),
            _attachTile(ctx, Icons.mic_rounded, l10n.chatAudioTranscription, () {
              Navigator.pop(ctx);
              setState(() => _audioTranscriptionMode = true);
              _focus.requestFocus();
            }),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _attachTile(BuildContext ctx, IconData icon, String title, VoidCallback onTap) {
    final colors = ThemeColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.cardBorder),
            ),
            child: Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFFFF8E1), Color(0xFFF5E6B8)]),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
                ),
                child: Icon(icon, size: 20, color: AppColors.accent),
              ),
              const SizedBox(width: 14),
              Expanded(child: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: colors.textPrimary, fontSize: 14))),
              const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: AppColors.textLight),
            ]),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (picked != null) {
        AppLogger.info('ChatScreen', 'Image sélectionnée: ${picked.path}');
        setState(() => _pendingImage = picked.path);
        _focus.requestFocus();
      }
    } catch (e) {
      debugPrint('Erreur image: $e');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
      if (picked != null) {
        AppLogger.info('ChatScreen', 'Photo prise: ${picked.path}');
        setState(() => _pendingImage = picked.path);
        _focus.requestFocus();
      }
    } catch (e) {
      debugPrint('Erreur photo: $e');
    }
  }
}

class _RecordingWave extends StatefulWidget {
  final Stream<RecordingDisposition>? stream;
  const _RecordingWave({this.stream});

  @override
  State<_RecordingWave> createState() => _RecordingWaveState();
}

class _RecordingWaveState extends State<_RecordingWave>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  StreamSubscription<RecordingDisposition>? _sub;
  double _level = 0;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 1300))
          ..repeat();
    _sub = widget.stream?.listen((e) {
      final db = e.decibels ?? 0;
      final target = (db / 120).clamp(0.0, 1.0).toDouble();
      setState(() => _level = _level * 0.5 + target * 0.5);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value * 2 * math.pi;
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(5, (i) {
              final wave = 0.5 + 0.5 * math.sin(t + i * 0.9);
              final speech = _level * (0.6 + 0.4 * math.sin(t * 1.3 + i * 1.1));
              final height = (4 + wave * 6 + speech * 18).clamp(4.0, 30.0);
              return Container(
                width: 4,
                height: height,
                margin: const EdgeInsets.symmetric(horizontal: 2.5),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

class _TypingDot extends StatefulWidget {
  const _TypingDot();

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  @override
  void initState() { super.initState(); _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(); }
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEBE5D7)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _c,
          builder: (_, child) {
            final t = (_c.value - i * 0.2).clamp(0.0, 1.0);
            return Opacity(opacity: 0.3 + 0.7 * (0.5 + 0.5 * (1 - t)), child: child);
          },
          child: Container(width: 7, height: 7, margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
        );
      })),
    );
  }
}
