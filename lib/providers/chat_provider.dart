import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../utils/logger.dart';
import '../l10n/app_localizations.dart';
import 'internet_status_provider.dart';

enum ChatMode {
  general,
  quran,
  arabic,
  quiz,
  memorize,
  dailyLesson,
}

extension ChatModeExtension on ChatMode {
  String get label {
    switch (this) {
      case ChatMode.general:
        return 'Général';
      case ChatMode.quran:
        return 'Coran';
      case ChatMode.arabic:
        return 'Arabe';
      case ChatMode.quiz:
        return 'Quiz';
      case ChatMode.memorize:
        return 'Mémorisation';
      case ChatMode.dailyLesson:
        return 'Leçon';
    }
  }

  IconData get icon {
    switch (this) {
      case ChatMode.general:
        return Icons.chat_bubble_outline;
      case ChatMode.quran:
        return Icons.menu_book;
      case ChatMode.arabic:
        return Icons.language;
      case ChatMode.quiz:
        return Icons.quiz;
      case ChatMode.memorize:
        return Icons.memory;
      case ChatMode.dailyLesson:
        return Icons.today;
    }
  }

  Color get color {
    switch (this) {
      case ChatMode.general:
        return const Color(0xFFC5A028);
      case ChatMode.quran:
        return const Color(0xFF9B7B1C);
      case ChatMode.arabic:
        return const Color(0xFFB8860B);
      case ChatMode.quiz:
        return const Color(0xFFA0841C);
      case ChatMode.memorize:
        return const Color(0xFF8B6914);
      case ChatMode.dailyLesson:
        return const Color(0xFFD4AF37);
    }
  }

  String get apiValue {
    switch (this) {
      case ChatMode.general:
        return 'general';
      case ChatMode.quran:
        return 'chat';
      case ChatMode.arabic:
        return 'arabic_teacher';
      case ChatMode.quiz:
        return 'quiz';
      case ChatMode.memorize:
        return 'memorize';
      case ChatMode.dailyLesson:
        return 'daily_lesson';
    }
  }
}

class ChatProvider extends ChangeNotifier {
  final ApiService _api;
  final StorageService _storage;
  final   List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isSynthesizing = false;
  ChatMode _currentMode = ChatMode.general;
  String? _error;
  int _messagesSentToday = 0;
  static const int maxFreeMessages = 5;
  bool _isSubscribed = false;
  final InternetStatusProvider? internetStatus;

  ChatProvider({required ApiService api, required StorageService storage, InternetStatusProvider? internetStatus})
      : _api = api,
        _storage = storage,
        internetStatus = internetStatus {
    _loadMessageCount();
  }

  set isSubscribed(bool value) {
    _isSubscribed = value;
    notifyListeners();
  }

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading || _isSynthesizing;
  bool get isSynthesizing => _isSynthesizing;
  ChatMode get currentMode => _currentMode;
  String? get error => _error;
  int get messagesSentToday => _messagesSentToday;
  int get messagesLeft => _isSubscribed ? 999 : maxFreeMessages - _messagesSentToday;
  bool get canSendMessage => _isSubscribed || _messagesSentToday < maxFreeMessages;

  void _loadMessageCount() {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final stored = _storage.prefs.getString('msg_count');
    if (stored != null) {
      try {
        final data = jsonDecode(stored);
        if (data['date'] == today) {
          _messagesSentToday = data['count'] ?? 0;
        }
      } catch (_) {}
    }
  }

  void _incrementMessageCount() {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    _messagesSentToday++;
    _storage.prefs.setString('msg_count', jsonEncode({'date': today, 'count': _messagesSentToday}));
    notifyListeners();
  }

  String _cleanMarkdown(String text) {
    return text
        .replaceAll('**', '')
        .replaceAll('__', '')
        .replaceAll('*', '')
        .replaceAll('~~', '')
        .replaceAll(RegExp(r'#{1,6}\s'), '')
        .replaceAll(RegExp(r'`{1,3}[^`]*`{1,3}'), '')
        .replaceAll(RegExp(r'\[([^\]]+)\]\([^)]+\)'), '')
        .replaceAll(RegExp(r'^\s*[-*+]\s', multiLine: true), '• ')
        .replaceAll(RegExp(r'^\s*\d+\.\s', multiLine: true), '')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }

  void setMode(ChatMode mode) {
    _currentMode = mode;
    notifyListeners();
  }

  String _userLanguage() {
    // 1) Langue choisie dans l'app (LanguageProvider) si présente
    final stored = _storage.prefs.getString('app_language');
    final storedWord = _languageWord(stored);
    if (storedWord != null) return storedWord;
    // 2) Repli sur la langue de l'appareil
    final locale = ui.PlatformDispatcher.instance.locale;
    return _languageWord(locale.languageCode) ?? 'français';
  }

  String? _languageWord(String? code) {
    switch (code) {
      case 'ar': return 'arabe';
      case 'fr': return 'français';
      case 'en': return 'anglais';
      case 'es': return 'espagnol';
      case 'pt': return 'portugais';
      case 'ru': return 'russe';
      case 'zh': return 'chinois';
      case 'de': return 'allemand';
      case 'tr': return 'turc';
      case 'id': return 'indonésien';
      case 'ur': return 'ourdou';
      case 'bn': return 'bengali';
      case 'ha': return 'haoussa';
      case 'sw': return 'swahili';
      case 'wo': return 'wolof';
      default: return null;
    }
  }

  Locale _chatLocale() {
    final code = _storage.prefs.getString('app_language');
    const supported = {'ar', 'en', 'es', 'fr', 'pt', 'ru', 'zh'};
    if (code != null && supported.contains(code)) return Locale(code);
    return ui.PlatformDispatcher.instance.locale;
  }

  /// Message localisé affiché quand le réseau est indisponible.
  String _offlineMessage() => lookupAppLocalizations(_chatLocale()).offlineMessage;

  /// Vrai si l'utilisateur est hors ligne (signal connu) ou si l'erreur
  /// ressemble à une panne réseau/DNS (wifi sans internet, etc.).
  bool _isOfflineOrNetworkError(Object? error) {
    if (internetStatus?.isOffline == true) return true;
    if (error == null) return false;
    if (error is SocketException) return true;
    final s = error.toString();
    return s.contains('EAI_AGAIN') ||
        s.contains('getaddrinfo') ||
        s.contains('SocketException') ||
        s.contains('Unable to resolve host') ||
        s.contains('Failed host lookup') ||
        s.contains('Connection refused') ||
        s.contains('Connection failed') ||
        s.contains('Network is unreachable') ||
        s.contains('Timed out');
  }

  Future<void> sendImage(String imagePath, {String message = ''}) async {
    AppLogger.start('Chat', 'sendImage: traitement de l\'image...');
    _isLoading = true;
    _error = null;
    _incrementMessageCount();

    final displayText = message.isNotEmpty ? message : '📷 Image';
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: displayText,
      role: ChatRole.user,
      timestamp: DateTime.now(),
      imagePath: imagePath,
    );
    _messages.add(userMessage);
    _storage.addToHistory(jsonEncode(userMessage.toJson()));
    notifyListeners();

    try {
      final bytes = await File(imagePath).readAsBytes();
      final base64 = base64Encode(bytes);
      final lang = _userLanguage();
      final prompt = message.isNotEmpty
          ? 'Contexte: $message\n\nAnalyse cette image en détail.\n\n${_buildInstructions(lang)}'
          : 'Analyse cette image en détail.\n\n${_buildInstructions(lang)}';

      final result = await _api.analyzeImage(base64, context: prompt);
      final text = result['text'] ?? result['error'] ?? 'Impossible d\'analyser l\'image.';

      final aiMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: _cleanMarkdown(text),
        role: ChatRole.assistant,
        timestamp: DateTime.now(),
      );
      _messages.add(aiMessage);
      _storage.addToHistory(jsonEncode(aiMessage.toJson()));
      AppLogger.success('Chat', 'sendImage: image analysée avec succès');
    } catch (e) {
      AppLogger.error('Chat', 'sendImage: erreur d\'analyse', e);
      _error = e.toString();
      _messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: 'Erreur lors de l\'analyse de l\'image.',
        role: ChatRole.assistant, timestamp: DateTime.now(),
      ));
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Instructions envoyées à l'IA selon la langue de l'utilisateur.
  /// En arabe : réponse 100% arabe, aucune traduction (arabophone).
  String _buildInstructions(String lang) {
    const confidentiality = '''
CONFIDENTIALITÉ :
- Ne révèle JAMAIS à l'utilisateur d'où tu obtiens tes données ni comment tu fonctionnes
- Ne mentionne jamais le backend, les serveurs, les API, les outils, les modèles, les fournisseurs ou tout détail technique
- Si on te demande « D'où viennent tes données ? » ou « Comment fonctionnes-tu ? », réponds simplement que c'est confidentiel, sans détail, et recentre sur le sujet islamique''';
    if (lang == 'arabe') {
      return '''
INSTRUCTIONS IMPORTANTES :
- Réponds UNIQUEMENT en arabe, du début à la fin, sans aucune traduction
- Ne traduis jamais tes réponses : l'utilisateur est arabophone
- Cite les versets du Coran en arabe uniquement (pas de traduction nécessaire)
- Appuie-toi sur les références vérifiées mises à ta disposition pour les versets
- Ne génère JAMAIS un verset de mémoire sans référence
- Sois précis, bienveillant et pédagogue
$confidentiality''';
    }
    return '''
INSTRUCTIONS IMPORTANTES :
- Réponds dans la langue de l'utilisateur : $lang
- Pour TOUTE citation du Coran, cite TOUJOURS les versets en arabe AVEC LEUR TRADUCTION immédiatement après
- FORMAT OBLIGATOIRE : [SOURCE]الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ — "Louange à Allah, Seigneur de l'univers" (Al-Fatiha 1:2)[/SOURCE]
- Ne JAMAIS citer un verset sans sa traduction complète
- La traduction doit être dans la langue de l'utilisateur : $lang
- Appuie-toi sur les références vérifiées mises à ta disposition pour les versets
- Ne génère JAMAIS un verset de mémoire sans référence
- Sois précis, bienveillant et pédagogue
$confidentiality''';
  }

  Future<void> sendMessage(String question, {String? audioPath}) async {
    if (question.trim().isEmpty && audioPath == null) return;
    if (!canSendMessage) return;

    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: question.trim(),
      role: ChatRole.user,
      timestamp: DateTime.now(),
      audioPath: audioPath,
    );

    _messages.add(userMessage);
    _storage.addToHistory(jsonEncode(userMessage.toJson()));
    _isLoading = true;
    _error = null;
    _incrementMessageCount();
    notifyListeners();

    await _streamAssistantReply(question.trim());

    _isLoading = false;
    notifyListeners();
  }

  /// Affiche immédiatement le message vocal dans la conversation
  /// (la transcription se fait ensuite en arrière-plan). Retourne l'id du message.
  String sendVoice(String audioPath) {
    if (audioPath.isEmpty) return '';
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: '',
      role: ChatRole.user,
      timestamp: DateTime.now(),
      audioPath: audioPath,
    );

    _messages.add(userMessage);
    _storage.addToHistory(jsonEncode(userMessage.toJson()));
    _isLoading = true;
    _error = null;
    _incrementMessageCount();
    notifyListeners();
    return userMessage.id;
  }

  /// Met à jour le message vocal avec le texte transcrit puis génère la réponse
  Future<void> attachVoiceText(String text, String userMessageId) async {
    final index = _messages.indexWhere((m) => m.id == userMessageId);
    if (index >= 0) {
      _messages[index].content = text.trim();
      _upsertHistory(_messages[index]);
    }
    if (text.trim().isEmpty) {
      finishProcessing();
      return;
    }
    await _streamAssistantReply(text.trim());
    _isLoading = false;
    notifyListeners();
  }

  /// Termine l'indicateur de chargement (ex: transcription échouée)
  void finishProcessing() {
    _isLoading = false;
    notifyListeners();
  }

  /// Indique que la voix de la réponse IA est en cours de génération
  void setSynthesizing(bool value) {
    if (_isSynthesizing == value) return;
    _isSynthesizing = value;
    notifyListeners();
  }

  Future<void> _streamAssistantReply(String question) async {
    try {
      final history = _messages
          .sublist(0, _messages.length - 1)
          .where((m) => m.content.trim().isNotEmpty)
          .map((m) => {'role': m.role == ChatRole.user ? 'user' : 'assistant', 'content': m.content})
          .toList();

      final lang = _userLanguage();
      final contextualQuestion = '''[Réponds en $lang]

$question

${_buildInstructions(lang)}''';

      // Créer le message AI vide qui sera rempli en streaming
      final aiMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: '',
        role: ChatRole.assistant,
        timestamp: DateTime.now(),
      );
      _messages.add(aiMessage);
      notifyListeners();

      // Stream the response (with timeout fallback)
      AppLogger.stream('Chat', 'Début du streaming...');
      int chunkCount = 0;
      final buffer = StringBuffer();
      bool streamCompleted = false;
      bool interrupted = false;
      try {
        await for (final chunk in _api.askQuestionStream(
          contextualQuestion,
          history: history,
        ).timeout(const Duration(seconds: 30))) {
          chunkCount++;
          if (chunk.startsWith('ERROR:')) {
            AppLogger.warn('Chat', 'Stream interrompu (erreur): ${chunk.substring(6)}');
            interrupted = true;
            break;
          }
          if (chunk == 'TRUNCATED') {
            AppLogger.warn('Chat', 'Réponse tronquée (limite de tokens atteinte)');
            interrupted = true;
            break;
          }
          buffer.write(chunk);
          aiMessage.content = _cleanMarkdown(buffer.toString());
          notifyListeners();
        }
        streamCompleted = true;
        AppLogger.success('Chat', 'Stream terminé ($chunkCount chunks)');
      } catch (streamError) {
        AppLogger.warn('Chat', 'Erreur stream: $streamError');
        final offline = _isOfflineOrNetworkError(streamError);
        // If streaming fails, try regular API call
        if (!streamCompleted && buffer.isEmpty) {
          try {
            final result = await _api.askQuestion(question: contextualQuestion, history: history);
            final text = result['answer'] ?? result['message'] ?? 'Désolé, je n\'ai pas pu répondre.';
            aiMessage.content = _cleanMarkdown(text);
          } catch (fallbackError) {
            aiMessage.content = _cleanMarkdown(
              offline || _isOfflineOrNetworkError(fallbackError)
                  ? _offlineMessage()
                  : (buffer.isNotEmpty ? buffer.toString() : 'Désolé, impossible de contacter le serveur.'),
            );
          }
        } else {
          // Réponse partielle coupée par erreur/réseau/timeout
          interrupted = true;
          aiMessage.content = offline
              ? _offlineMessage()
              : _cleanMarkdown(buffer.toString());
        }
        notifyListeners();
      }

      if (interrupted && buffer.isNotEmpty) {
        aiMessage.isIncomplete = true;
      }
      if (interrupted && buffer.isEmpty) {
        aiMessage.content = aiMessage.content.isEmpty
            ? 'Désolé, une erreur est survenue.'
            : aiMessage.content;
      }

      _upsertHistory(aiMessage);
      AppLogger.info('Chat', 'Message sauvegardé dans l\'historique');
    } catch (e) {
      AppLogger.warn('Chat', 'Erreur globale chat: $e');
      _error = e.toString();
      final errorMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: _isOfflineOrNetworkError(e)
            ? _offlineMessage()
            : 'Impossible de contacter le serveur. Vérifiez votre connexion internet.',
        role: ChatRole.assistant,
        timestamp: DateTime.now(),
      );
      _messages.add(errorMessage);
    }
  }

  /// Retrouve le dernier message assistant incomplet
  ChatMessage? get _lastIncompleteMessage {
    for (final m in _messages.reversed) {
      if (m.role == ChatRole.assistant && m.isIncomplete) return m;
    }
    return null;
  }

  /// Continue la dernière réponse interrompue (tronquée ou coupée par erreur)
  Future<void> continueResponse() async {
    if (_isLoading) return;
    final target = _lastIncompleteMessage;
    if (target == null) return;

    AppLogger.info('Chat', 'continueResponse: reprise de la réponse interrompue');
    _isLoading = true;
    _error = null;
    notifyListeners();

    final partial = target.content;
    final tail = partial.length > 1200 ? partial.substring(partial.length - 1200) : partial;
    final lang = _userLanguage();

    final continuePrompt = '''[Réponds en $lang]

Je te donne la FIN d'une réponse qui a été interrompue (coupée). Continue exactement là où elle s'est arrêtée. Ne répète AUCUNE partie du texte déjà écrit ci-dessous.

--- FIN DE LA RÉPONSE INTERROMPUE ---
$tail
--- FIN ---

Continue cette réponse à partir de ce point. Respecte le même style, la même langue et le format [SOURCE]...[/SOURCE] pour toute citation coranique. Termine proprement la réponse.
${_buildInstructions(lang)}''';

    final history = _messages
        .where((m) => m.id != target.id && m.content.trim().isNotEmpty)
        .map((m) => {'role': m.role == ChatRole.user ? 'user' : 'assistant', 'content': m.content})
        .toList();

    final buffer = StringBuffer(partial);
    bool stillIncomplete = false;
    try {
      await for (final chunk in _api.askQuestionStream(
        continuePrompt,
        history: history,
      ).timeout(const Duration(seconds: 30))) {
        if (chunk.startsWith('ERROR:')) {
          AppLogger.warn('Chat', 'Erreur pendant la continuation: ${chunk.substring(6)}');
          stillIncomplete = true;
          break;
        }
        if (chunk == 'TRUNCATED') {
          AppLogger.warn('Chat', 'Continuation encore tronquée');
          stillIncomplete = true;
          break;
        }
        buffer.write(chunk);
        target.content = _cleanMarkdown(buffer.toString());
        notifyListeners();
      }
      target.isIncomplete = stillIncomplete;
      AppLogger.success('Chat', stillIncomplete ? 'Réponse encore incomplète' : 'Réponse continuée et terminée');
    } catch (e) {
      AppLogger.warn('Chat', 'Erreur continuation: $e');
      target.isIncomplete = true;
    }

    _upsertHistory(target);
    _isLoading = false;
    notifyListeners();
  }

  /// Associe un fichier audio à un message (réponse vocale de l'assistant)
  void setMessageAudio(String id, String audioPath) {
    final idx = _messages.indexWhere((m) => m.id == id);
    if (idx == -1) return;
    _messages[idx].audioPath = audioPath;
    _upsertHistory(_messages[idx]);
    notifyListeners();
  }

  /// Sauvegarde/mise à jour d'un message dans l'historique local (sans doublon)
  void _upsertHistory(ChatMessage msg) {    final history = _storage.history;
    final updated = history.where((s) {
      try {
        final parsed = jsonDecode(s) as Map;
        return parsed['id'] != msg.id;
      } catch (_) {
        return true;
      }
    }).toList();
    updated.add(jsonEncode(msg.toJson()));
    _storage.prefs.setStringList('chat_history', updated);
  }

  void clearMessages() {
    AppLogger.info('Chat', 'clearMessages: ${_messages.length} messages supprimés');
    // Save current conversation before clearing
    _saveCurrentConversation();
    _messages.clear();
    _storage.clearHistory();
    notifyListeners();
  }

  void _saveCurrentConversation() {
    if (_messages.isEmpty) return;
    final title = _messages.first.content.length > 50
        ? '${_messages.first.content.substring(0, 50)}...'
        : _messages.first.content;
    final conversation = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'createdAt': DateTime.now().toIso8601String(),
      'messageCount': _messages.length,
      'preview': _messages.last.content.length > 100
          ? _messages.last.content.substring(0, 100)
          : _messages.last.content,
      'messages': _messages.map((m) => jsonEncode(m.toJson())).toList(),
    };
    final saved = _storage.prefs.getStringList('conversations') ?? [];
    saved.insert(0, jsonEncode(conversation));
    if (saved.length > 50) saved.removeRange(50, saved.length);
    _storage.prefs.setStringList('conversations', saved);

    // Sync to Firestore
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        FirebaseFirestore.instance
            .collection('users').doc(user.uid)
            .collection('conversations').doc(conversation['id'] as String)
            .set(conversation);
      }
    } catch (_) {}
  }

  /// Charge une conversation sauvegardée dans le chat courant
  void loadConversation(String id) {
    final saved = _storage.prefs.getStringList('conversations') ?? [];
    for (final s in saved) {
      try {
        final c = jsonDecode(s) as Map<String, dynamic>;
        if (c['id'] == id) {
          final msgs = (c['messages'] as List?) ?? const [];
          if (msgs.isEmpty) {
            AppLogger.warn('Chat', 'Conversation $id sans messages sauvegardés (ancienne version)');
            return;
          }
          _messages
            ..clear()
            ..addAll(msgs.map((m) => ChatMessage.fromJson(jsonDecode(m as String))));
          _storage.prefs.setStringList('chat_history', msgs.cast<String>());
          _isLoading = false;
          _error = null;
          notifyListeners();
          AppLogger.info('Chat', 'Conversation chargée: ${_messages.length} messages');
          return;
        }
      } catch (e) {
        AppLogger.error('Chat', 'Erreur chargement conversation', e);
      }
    }
    AppLogger.warn('Chat', 'Conversation $id introuvable');
  }

  /// Retire un message utilisateur (et sa réponse associée) et retourne son texte
  /// pour que l'utilisateur puisse le modifier et le renvoyer.
  String editMessage(ChatMessage message) {
    final idx = _messages.indexWhere((m) => m.id == message.id);
    if (idx == -1 || _messages[idx].role != ChatRole.user) return '';
    final text = _messages[idx].content;
    var end = _messages.length;
    for (int i = idx + 1; i < _messages.length; i++) {
      if (_messages[i].role == ChatRole.user) {
        end = i;
        break;
      }
    }
    _messages.removeRange(idx, end);
    _storage.prefs.setStringList(
      'chat_history',
      _messages.map((m) => jsonEncode(m.toJson())).toList(),
    );
    notifyListeners();
    AppLogger.info('Chat', 'editMessage: ${end - idx} message(s) retiré(s) avant renvoi');
    return text;
  }

  List<Map<String, dynamic>> getSavedConversations() {
    final saved = _storage.prefs.getStringList('conversations') ?? [];
    return saved
        .map((s) {
          try {
            return jsonDecode(s) as Map<String, dynamic>;
          } catch (_) {
            return null;
          }
        })
        .whereType<Map<String, dynamic>>()
        .where((c) => (c['messages'] as List?)?.isNotEmpty ?? false)
        .toList();
  }

  void deleteConversation(String id) {
    final saved = _storage.prefs.getStringList('conversations') ?? [];
    saved.removeWhere((s) {
      try { return (jsonDecode(s) as Map)['id'] == id; } catch (_) { return false; }
    });
    _storage.prefs.setStringList('conversations', saved);
    notifyListeners();
  }

  void deleteAllConversations() {
    _storage.prefs.remove('conversations');
    notifyListeners();
  }
}
